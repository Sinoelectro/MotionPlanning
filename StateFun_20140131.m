function out=StateFun_20140131(t,G,V,PotForce)
%% 状态方程

tf1=PotForce.tf1;
tf0=PotForce.tf0;
oneFb2Wb=PotForce.oneFb2Wb; 
repf=PotForce.repf;


Gf=PotForce.Gf;
G0=PotForce.G0;
scale=PotForce.scale;

R=G(1:3,1:3); P=G(1:3,end);

x=P(1);y=P(2);z=P(3);
TH=InvEuler(R,'XYZ');
q1=TH(1);q2=TH(2);q3=TH(3);

% oneFb2Wb=oneFb2Wb(q1,q2,q3,x,y,z);%力1形式的基 映射到 力旋量的基 的变换矩阵
% tf1x=real(tf1(q1,q2,q3,x,y,z));%1-form 从当前点指向目标
% tf0x=real(tf0(q1,q2,q3,x,y,z));%1-form 从当前点指向起点
% repfx=real(repf(q1,q2,q3,x,y,z)); %连线中心对手的排斥势力 

%%%尝试直接写出来
oneFb2Wb=eval(oneFb2Wb);%力1形式的基 映射到 力旋量的基 的变换矩阵
tf1x=eval(tf1);%1-form 从当前点指向目标
tf0x=eval(tf0);%1-form 从当前点指向起点
repfx=eval(repf); %连线中心对手的排斥势力 



tf=norm(tf0x)*tf1x;%具有bell-shaped特征的目标吸引向量

rf=repfx;%apF_hhx+apF_bhx;%当前位置的合成排斥力
f=rf;%+sf; %当前位置的合成反冲力

[repsC,compsC]=Fading(Gf, G, G0, scale);%关于反冲力的衰减系数
% repsf 反冲力的衰减系数(离目标越近，衰减得越厉害)
% compsf 合力的在初始阶段的调幅系数（与起点的距离在0.04以内），衰减系数(离目标越近，衰减得越厉害)

rfs=repsC*norm(tf(4:6))*unit(f(4:6)) ;%repsC：控制反冲力幅值的衰减系数 调整幅值后的反冲力
%rfs2=repsC*norm(tf(1:3))*unit(f(1:3)) ;
F=tf+[0;0;0;rfs];% 合成广义力：力矩+力 F=tf+[rfs2;rfs];%  
F(1:3)=10*norm(F(4:6))*F(1:3); % 由于转动无反冲力约束，导致其力矩分量始终较大，进而导致手腕转动过快，
                            % 无法与手掌的平移同步,因而对力矩分量做一个调幅操作（利用力分量来调幅）
W=ToColumnVector(F.'/oneFb2Wb);%wrench component

a=1.0;b=1.0;%关于角速度与线速度的度量矩阵因子,act as scaling factor for angular velocities and linear velocities
s1w=50; s1v=50; %角速度与线速度的阻尼因子
s2w=150; s2v=150; %转动与平移力旋量的增益系数

A=blkdiag(a*eye(3),b*eye(3));
S1=blkdiag(s1w*eye(3),s1v*eye(3));
S2=blkdiag(s2w*eye(3),s2v*eye(3));

out=-[zeros(3,1);cross(V(1:3),V(4:6))]-S1*(A\V)+S2*(A\W);
clear PotForce

return
%%%%%%%
%%构造函数Mdis
function out=Mdis(G0,G1,scale)
Rl=G0(1:3,1:3);Pl=G0(1:3,end);%位形范围的积分下限
Ru=G1(1:3,1:3);Pu=G1(1:3,end);%位形范围的积分上限
out=sqrt( 0.1+(norm(Pu-Pl))^2 + scale^2*acos(0.5*(trace(Rl\Ru)-1))^2 );%距离表达式
return
function [repsf,compsf]=Fading(Gf,G,G0,scale)
% repsf  控制反冲力幅值的衰减系数(离目标越近，衰减得越厉害)
% compsf 合力的在初始阶段的调幅系数（与起点的距离在0.04以内）

dis1=Mdis(Gf,G,scale);
dis0=Mdis(G0,G,scale);
ipson=2.3;%
x=dis1/(dis1+dis0);
repsf=(1-exp(-ipson*x^(1+1/ipson)))/(1-exp(-ipson));

K=80;
compsf=1+100*exp(-K*dis0.^(1+1/K));
%% ipson取值
% ChenWenrui
%.. tls01:   ipson(4.5),s1(50),s2(150)  F(1:3)=10*norm(F(4:6))*F(1:3); 系数为10.. 积分初值扰动5,5
%.. lear01:  ipson(3.0),s1(50),s2(150)  F(1:3)=10*norm(F(4:6))*F(1:3); 系数为10.. 积分初值扰动5,5
%.. mouse01: ipson(2.5),s1(50),s2(150)  F(1:3)=30*norm(F(4:6))*F(1:3); 系数为30.. 积分初值扰动5,5
%            ipson(2.3),s1(50),s2(150)  F(1:3)=10*norm(F(4:6))*F(1:3); 系数为10.. 积分初值扰动5,5
%            ----seframe: 162,250,3
%.. head01:  ipson(3.0),s1(50),s2(130)  F(1:3)=10*norm(F(4:6))*F(1:3); 系数为10.. 积分初值扰动5,5
%.. rear01:  ipson(3.5),s1(50),s2(150)  F(1:3)= 5*norm(F(4:6))*F(1:3); 系数为 5.. 积分初值扰动5,5
function out=unit(V)
%对向量V 单位化
out=V/norm(V);
return

