function [outGh,ObjectShape,Qrobot,allQhuman,FullLimb,SimpleLimb,Humerus]=MotionPlanning_20140131(ActionType) 
% LieIntergrator_20140131.m 
% StateFun_20140131.m
% ActionType: 'tls','lear','mouse','head','rear'


%% ------------------几何参数与位置参数-----------------------%%%%%
unt=1e2;%cm->m
Lu=(31.5)/unt;% 大臂长度  Motco Database：24 (170cm,65Kg)    cwr:27.6
Lf=(24.6)/unt;% 小臂长度  Motco Database：23 (170cm,65Kg)    cwr:24
Lh=5.0/unt;%手掌一半的长度

%AR文章的坐标轴定义
XI{1}=createtwist([0;1;0],[0;0;0]);
XI{2}=createtwist([1;0;0],[0;0;0]);
XI{3}=createtwist([0;0;1],[0;0;0]);%肩关节的三个运动旋量
XI{4}=createtwist([0;1;0],[0;0;-Lu]);%肘关节的运动旋量
XI{5}=createtwist([0;0;1],[0;0;-Lu-Lf]);
XI{6}=createtwist([0;1;0],[0;0;-Lu-Lf]);
XI{7}=createtwist([1;0;0],[0;0;-Lu-Lf]);%腕关节的三个运动旋量
Gst_elbow=transl(0,0,-Lu);
Gst_wrist=transl(0,0,-Lu-Lf);
Gst_hand=transl(0,0,-Lu-Lf-Lh);%末端执行器初始形位

Humerus=robot(XI(1:3),Gst_elbow);
Humerus.name='Humerus';
SimpleLimb=robot(XI(1:4),Gst_wrist);
SimpleLimb.name='SimpleLimb';
FullLimb=robot(XI,Gst_hand);
FullLimb.name='FullLimb';

%%  -----目标位姿与初始位姿定义区
%% 这一步从人手臂真实动作中提取运动初始位姿和目标位姿

XD=DataReorg();% 调入经过整理后的动作数据,一列表示一组关节角(弧度单位)对应一个姿态,
               % 动作与动作之间用NaN隔开,同类动作数据的末尾也为NaN,结构体内将正向运动与反向回位分开存放
action=getfield(XD,ActionType); % 依据输入筛选动作数据

indnan=find(isnan( action.forward(1,:) ));%找出某类动作（正向运动）中用以分隔各次运动分隔号

allQhuman_fd=action.forward([1,2,3,4,7,8,9],:);% 所有人的action动作的正向运动,取所需的7个关节：肩，肘，腕
allQhuman_fd=ISB2AR(allQhuman_fd); % 将ISB坐标下的欧拉角 转为 AR文章坐标下的欧拉角

allQhuman_bk=action.backward([1,2,3,4,7,8,9],:);% 所有人的action动作的正向运动,取所需的7个关节：肩，肘，腕
allQhuman_bk=ISB2AR(allQhuman_bk); % 将ISB坐标下的欧拉角 转为 AR文章坐标下的欧拉角

allQhuman=[action.forward([1,2,3,4,7,8,9],:),action.backward([1,2,3,4,7,8,9],:)];% 所有人的action动作的正向与反向运动,取所需的7个关节：肩，肘，腕
allQhuman=ISB2AR(allQhuman); % 将ISB坐标下的欧拉角 转为 AR文章坐标下的欧拉角
%%以上两步可简化，减少计算时间
Qhuman=action.forward( [1,2,3,4,7,8,9], 1:indnan(1)-1 ); %cwr的action动作的第一个正向运动,取所需的7个关节：肩，肘，腕
%%indnan（1）-1指第一个运动序列

Qhuman=ISB2AR(Qhuman); % 将ISB坐标下的欧拉角 转为 AR文章坐标下的欧拉角

% ----目标值（平均）
qf=sum( allQhuman_fd(:,indnan-1),2 )/length(indnan);
%%qf30次目标值的行平均值 allQhuman_fd(:,indnan-1)为 7×30 single 矩阵
Gf=fkine(FullLimb,qf);%终点手的绝对位姿
Gwf=fkine(SimpleLimb,qf(1:4));%终点手腕的绝对位姿
Pwf=Gwf(1:3,end);%终点手腕的绝对位置

dRf=Gwf(1:3,1:3)\Gf(1:3,1:3);%终点手的相对姿态%%Gf(3*3)为终点手旋转矩阵，Gwf（3*3）为终点手腕旋转矩阵，此步求从手腕到手的旋转矩阵
dGf=rp2t(dRf,Pwf);%终点手的相对位姿

% ----起始值（平均）
q0=sum( allQhuman_fd(:,[0,indnan(1:end-1)]+1),2 )/length(indnan); %q0(4)=0;蛤？为什么？
%%%qf30次起始值的行平均值 allQhuman_fd(:,[0,indnan(1:end-1)]+1)为 7×30 single 矩阵
G0=fkine(FullLimb,q0);%手的绝对初始形位
Gw0=fkine(SimpleLimb,q0(1:4));%手腕的绝对初始形位
Pw0=Gw0(1:3,end); %腕关节绝对初始的位置
 
dR0=Gw0(1:3,1:3)\G0(1:3,1:3); % 初始手的相对姿态
dG0=rp2t(dR0,Pw0); % 初始手的相对位姿

%%  ---避障势场与势力
ObjectShape=BodyShape(Pw0,Pwf);%%Pw0 Pwf两个参数只影响球障碍物的轴参数和位置，对身体其他参数不影响

scale=Scale(dG0,dGf);%norm(Pwf-Pw0)/( (3-trace(dR0\dRf))/4 );%%%起始点与终点参与运算，结果为ε2
[tf0,tf1,oneFb2Wb]=AttForce(dG0,dGf,scale); %tf1，tf0用于让手向目标运动的势力向量 1-形式
repf=RepForce(dG0,dGf,scale);% 用于让手偏离直线运动的反冲力向量 1-形式
%%不太懂@和reshape的作用
%  -------封装
PotForce.oneFb2Wb=oneFb2Wb;  %势力基 向 力旋量基变换的 符号变量
PotForce.tf1=tf1;            %指向目标的势力  符号变量
PotForce.tf0=tf0;            %指向启动位置的势力  符号变量
PotForce.repf=repf;          %连线中心对手势力方向 符号变量

PotForce.G0=dG0; 
PotForce.Gf=dGf;
PotForce.scale=scale;
%%  --几何积分
qx0=q0+[0; 0/180*pi; 0/180*pi; 5/180*pi; 0/180*pi; 0; 0];%在初始角度的基础上给一个小的扰动，【可靠积分的需要】;
Gx0=fkine(FullLimb,qx0);
Gwx0=fkine(SimpleLimb,qx0(1:4));
dRx0=Gwx0(1:3,1:3)\Gx0(1:3,1:3);
Pwx0=Gwx0(1:3,end);
X0{1}=rp2t(dRx0,Pwx0);%积分初值 (手的相对姿态 + 手腕位置)
w=zeros(3,1);v=zeros(3,1);%w=dRx0\[0; 0.1; 0]; v=dRx0\[-0.5; 0; 0];%  
X0{2}=[w(1:3); v(1:3)];%手的初始速度,运动旋量 **** 初始速度对轨迹起始阶段有影响 *****
tspan=[0,20];%总时间
stp=0.02;%时间步长
%---积分求解：outG中的各个元素为：R 手的相对姿态， P 手腕的空间位置
tic
[outdG,outV]=LieIntergrator_20140131(@StateFun_20140131,X0,tspan,stp,'L',PotForce); 
toc
%%  ---运动学反解
%___(1)利用线性回归求解
%[~,~,coef]=GetArmOrientation();%获得人体大臂（theta1, theta2）和小臂(theta3, theta4)的姿态角与腕部球坐标之间的线性回归关系 10 x 4
coef=load('coef_linear_regression.mat');
coef=coef.coef;

rcf=CoordinateChange(squeeze(outdG(1:3,end,:)));%将腕部的空间笛卡尔坐标转为球坐标：R,Ce,Fai  3 x n，每一列表示一组球坐标

X0=ones(size(rcf(1,:)))';
X1=rcf(1,:)';
X2=rcf(2,:)';
X3=rcf(3,:)';
RCF=[X0,X1,X2,X3,X1.*X2,X1.*X3,X2.*X3,X1.*X1,X2.*X2,X3.*X3];%为直观显示多变量回归结果作准备

tiba=(RCF*coef)';% 得到这里规划出来的大臂和小臂的姿态角 4 x n, 每一列表示一组姿态角
th1=tiba(1,:);
th2=tiba(2,:);
Pe=[-Lu*sin(th1).*cos(th2); Lu*sin(th1).*sin(th2); -Lu*cos(th1)];

Qrobot=qfun(Pe,squeeze(outdG(1:3,end,:)),Lu,Lf,outdG(1:3,1:3,:));%求出对应的关节角，每一列表示一组关节角，AR文章
%Qrobot=[q0,Qrobot];%把扰动之前的初值包含进来

outGh=fkine(FullLimb,Qrobot);%末端手的位姿矩阵

%%  ---对结果可视化
fmrg=seframe(ActionType);%从生成的轨迹中选取合适的区间，用来表现速度轨迹的特征
spts=fmrg(1):fmrg(3):fmrg(2);
% plotWVandP(FullLimb,Qrobot,fmrg,allQhuman_fd,allQhuman_bk,stp); %绘制速度和位置轨迹
% plotAsmCurve(outGh, ObjectShape,spts);hold on %绘制末端手的空间轨迹。spts：需要绘制的帧编号构成的向量
% plotLims(Humerus,SimpleLimb,Qrobot,[0;0;0],spts);hold off %绘制肢体形位的空间轨迹
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%---------------拟人运动规划程序结束------------%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%_____________________________________________________________________________
function ObjectShape=BodyShape(P0,Pf)
% 手腕的起始位置和目标位置：Pf,P0
center=0.5*(Pf+P0);
radius=0.5*norm(Pf-P0);%%norm欧几里得范数
sphereObs.A=0.5*radius*ones(1,3);% 球障碍物的轴参数
sphereObs.I=[1,1];% 球障碍物的幂参数
sphereObs.G=rp2t(eye(3),center);% 球障碍物在全局坐标系下的位姿%%姿态为单位阵，位置为起始与终点的中心


bodycorner=[-120;-32+25;68];

unt3=1e3;%mm->m
head.A=0.5*[200,170,250]/unt3;%头的轴参数
head.I=[1,1];%头的幂参数
head.G=rp2t(eye(3),(bodycorner+[-30;-85;15]+0.5*[200;-170;250])/unt3);%头在全局坐标系下的位姿

body.A=0.5*[230,340,680]/unt3;%身体障碍物的轴参数[117.5,155,375]/unt3;[135,155,375]/unt3;
body.I=[1,1];%身体障碍物的幂参数
body.G=rp2t(eye(3),(bodycorner+0.5*[230;-340;-680])/unt3);%障碍物在全局坐标系下的位姿

hand.A=[10,30,50]/unt3;%（手）物体的轴参数
hand.I=[0.5,0.5];%物体的幂参数
syms x y z
hand.G=rp2t(eye(3),[x;y;z]);%G0;%物体在全局坐标系下的位置（不考虑姿态的影响）

thumb.A=[7.5,7.5,25]/unt3;%（拇指）物体的轴参数
thumb.I=[1,1];%物体的幂参数
thumb.G=rp2t(eye(3),[0;37.5;10]/unt3);%G0;%拇指在'手坐标系'下的位姿  

ObjectShape.sphereObs=sphereObs;
ObjectShape.head=head;
ObjectShape.body=body;
ObjectShape.hand=hand;
ObjectShape.thumb=thumb;
return

%%%%%%________________________________________________________________________________
function f=RepForce(G0,Gf,scale)
% 反冲势力向量
Rl=G0(1:3,1:3);Pl=G0(1:3,end);%位形范围的积分下限
Ru=Gf(1:3,1:3);Pu=Gf(1:3,end);%位形范围的积分上限

angc=0.5*(InvEuler(Rl,'XYZ')+InvEuler(Ru,'XYZ'));
 Rc=rotx(angc(1))*roty(angc(2))*rotz(angc(3));
Pc=0.5*(Pl+Pu);

syms q1 q2 q3 x y z 
R=rotx(q1)*roty(q2)*rotz(q3);
P=[x;y;z];

Pot=sqrt( sum((P-Pc).*(P-Pc)) + scale^2*acos(0.5*(trace(Rc\R)-1))^2 );%距离表达式
Pot=simplify(Pot);

f=jacobian(Pot,[q1 q2 q3 x y z]).';%力 1-形式 
%%%%%尝试修改
%f=@(q1, q2, q3, x, y, z)reshape(sym2str(f),6,1);
%f=@(q1, q2, q3, x, y, z)f;


return

%%%%%________________________________________________________________________________
function [tf0,tf1,oneFb2Wb]=AttForce(G0,Gf,scale)
% 吸引势力向量 与 伴随势力向量 1-form
Rl=G0(1:3,1:3);Pl=G0(1:3,end);%位形范围的积分下限
Ru=Gf(1:3,1:3);Pu=Gf(1:3,end);%位形范围的积分上限

syms q1 q2 q3 x y z 
R=rotx(q1)*roty(q2)*rotz(q3);
P=[x;y;z];
G=transl(x,y,z)*rp2t(R,zeros(3,1));%%符号计算，x.y.z作为平移的齐次阵乘以q1q2q3作为旋转的齐次阵
[LXb2E,oneFb2Wb]=Mat_BasisMap(G,'L');%%得到6维矩阵与转置

LXb2E=@(q1, q2, q3, x, y, z)reshape(sym2str(LXb2E),6,6); %%后面一半为转换为字符串
%oneFb2Wb=@(q1, q2, q3, x, y, z)reshape(sym2str(oneFb2Wb),6,6); 
%%上面两步不懂啥意思
%%%尝试修改
%oneFb2Wb=@(q1, q2, q3, x, y, z)oneFb2Wb; 

Pot1=sqrt(0.1+ sum((Pu-P).*(Pu-P)) + scale^2*acos(0.5*(trace(R\Ru)-1))^2 )-0.1;%距离表达式
Pot0=sqrt(0.1+ sum((P-Pl).*(P-Pl)) + scale^2*acos(0.5*(trace(Rl\R)-1))^2 )-0.1;

Pot1=simplify(Pot1);
Pot0=simplify(Pot0);

tf1=-jacobian(Pot1,[q1 q2 q3 x y z ]).';%力 1-形式           
tf0=-jacobian(Pot0,[q1 q2 q3 x y z ]).';
tf1=simplify(tf1);
tf0=simplify(tf0);
%%%%%%%%%%%%%%%尝试修改
% tf1=@(q1, q2, q3, x, y, z)reshape(sym2str(tf1),6,1);
%tf1=@(q1, q2, q3, x, y, z)tf1;
%tf0=@(q1, q2, q3, x, y, z)reshape(sym2str(tf0),6,1);
%tf0=@(q1, q2, q3, x, y, z)tf0;
return

%%%%%%________________________________________________________________________________
function rcf=CoordinateChange(Pw)
% Pw：腕部的空间笛卡尔坐标，每一列均表示一个坐标点 AR文章的坐标系
% rcf: 腕部的球坐标(radius,ce,fai)，每一列表示一组坐标点
if size(Pw,1)~=3
    error('invalid input!!');
end
rcf=zeros(3,size(Pw,2));

for ind=1:size(Pw,2) %逐个计算手腕的球坐标(radius,ce,fai) 
    pwx=Pw(1,ind);
    pwy=Pw(2,ind);
    pwz=Pw(3,ind);    
    rcf(1,ind)=sqrt(pwx^2+pwy^2+pwz^2);
    rcf(2,ind)=atan2(pwy,-pwx);
    tmp=sqrt(pwx^2+pwy^2);
    rcf(3,ind)=atan2(-pwz,tmp);
end
return

%%%%%%________________________________________________________________________________
function Qar=ISB2AR(Q)
% 将ISB坐标下的欧拉角 转为 AR文章坐标下的欧拉角，一列表示一组关节角(弧度单位)对应一个姿态
% Q为ISB坐标下的欧拉角
Rs=ones(3,3,size(Q,2));
Rw=ones(3,3,size(Q,2));
for ind=1:size(Q,2)% 从ISB坐标 转为AR文章的坐标  欧拉角转换
    a=Q(1,ind);
    b=Q(2,ind);
    c=Q(3,ind);
    Rs(:,:,ind)=rotx(a)*roty(b)*rotz(c);% 从肩关节坐标系（ISB）对应到AR文章的姿态矩阵
    a=Q(5,ind);
    b=Q(6,ind);
    c=Q(7,ind);
    Rw(:,:,ind)=rotz(a)*roty(b)*rotx(-c);%从腕关节坐标系（ISB）对应到AR文章的姿态矩阵        
end
Qs=InvEuler(Rs,'YXZ')';
Qw=InvEuler(Rw,'ZYX')';
Qar=[Qs;   Q(4,:);   Qw];%坐标对应AR文章
return

%%%%%%________________________________________________________________________________
function Q=qfun(PE,PW,Lu,Lf,dRW)
% 求肩,肘,腕关节的角度 AR文章的坐标系
% PE,PW的每一列均表示一组空间坐标,dRW的每一层均表示一个SO(3),
% Q 每一列表示一组关节角，定义见AR文章

Q=ones(7, size(PE,2));
Ps=0;
for ind=1:size(PE,2)
    Pe=PE(:,ind);
    Pw=PW(:,ind);
    dRw=dRW(:,:,ind);
	%%%%%%%*************求肩关节转角*************%%%%%%%%%%%%%%%%%%
    sz=(Ps-Pe)/norm(Ps-Pe);
    sy=cross(sz,Ps-Pw);
    sy=sy/norm(sy);
    sx=cross(sy,sz);
    Rs=[sx,sy,sz];
    tmp=InvEuler(Rs,'YXZ');
    q1=tmp(1);%假设 -90< q2< 90,需要使用killbreak
    q2=tmp(2);
    q3=tmp(3);

	%%%%%%%*************求机器人肘关节转角*************%%%%%%%%%%%%%%%%%%%
    q4=pi-acos((Lu^2+Lf^2-norm(Pw-Ps)^2)/(2*Lu*Lf));

	%%%%%%%*************求机器人腕关节转角*************%%%%%%%%%%%%%%%%%%%
    tmp=InvEuler(dRw,'ZYX');%机器人腕关节欧拉角度
    q5=tmp(1);%假设 -90< q2< 90,需要使用killbreak
    q6=tmp(2);
    q7=tmp(3);
    
    Q(:,ind)=[q1,q2,q3,q4,q5,q6,q7]';
end
return

function out=seframe(ActionType)
% [a b c] 从生成的轨迹中选取合适的区间(前面两个数a,b)，用来表现速度轨迹的特征.第三个数c表示绘图时的帧间隔
% Actiontype：'tls','lear','mouse','head','rear'
SEframe.tls=[67, 123,2];
SEframe.lear=[173, 249,2];
SEframe.mouse=[169, 240,2];%
SEframe.head=[191, 269, 3];
SEframe.rear=[79, 146, 2];
out=getfield(SEframe,ActionType);
return