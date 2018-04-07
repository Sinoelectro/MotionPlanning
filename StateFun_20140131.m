function out=StateFun_20140131(t,G,V,PotForce)
%% ״̬����

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

% oneFb2Wb=oneFb2Wb(q1,q2,q3,x,y,z);%��1��ʽ�Ļ� ӳ�䵽 �������Ļ� �ı任����
% tf1x=real(tf1(q1,q2,q3,x,y,z));%1-form �ӵ�ǰ��ָ��Ŀ��
% tf0x=real(tf0(q1,q2,q3,x,y,z));%1-form �ӵ�ǰ��ָ�����
% repfx=real(repf(q1,q2,q3,x,y,z)); %�������Ķ��ֵ��ų����� 

%%%����ֱ��д����
oneFb2Wb=eval(oneFb2Wb);%��1��ʽ�Ļ� ӳ�䵽 �������Ļ� �ı任����
tf1x=eval(tf1);%1-form �ӵ�ǰ��ָ��Ŀ��
tf0x=eval(tf0);%1-form �ӵ�ǰ��ָ�����
repfx=eval(repf); %�������Ķ��ֵ��ų����� 



tf=norm(tf0x)*tf1x;%����bell-shaped������Ŀ����������

rf=repfx;%apF_hhx+apF_bhx;%��ǰλ�õĺϳ��ų���
f=rf;%+sf; %��ǰλ�õĺϳɷ�����

[repsC,compsC]=Fading(Gf, G, G0, scale);%���ڷ�������˥��ϵ��
% repsf ��������˥��ϵ��(��Ŀ��Խ����˥����Խ����)
% compsf �������ڳ�ʼ�׶εĵ���ϵ���������ľ�����0.04���ڣ���˥��ϵ��(��Ŀ��Խ����˥����Խ����)

rfs=repsC*norm(tf(4:6))*unit(f(4:6)) ;%repsC�����Ʒ�������ֵ��˥��ϵ�� ������ֵ��ķ�����
%rfs2=repsC*norm(tf(1:3))*unit(f(1:3)) ;
F=tf+[0;0;0;rfs];% �ϳɹ�����������+�� F=tf+[rfs2;rfs];%  
F(1:3)=10*norm(F(4:6))*F(1:3); % ����ת���޷�����Լ�������������ط���ʼ�սϴ󣬽�����������ת�����죬
                            % �޷������Ƶ�ƽ��ͬ��,��������ط�����һ������������������������������
W=ToColumnVector(F.'/oneFb2Wb);%wrench component

a=1.0;b=1.0;%���ڽ��ٶ������ٶȵĶ�����������,act as scaling factor for angular velocities and linear velocities
s1w=50; s1v=50; %���ٶ������ٶȵ���������
s2w=150; s2v=150; %ת����ƽ��������������ϵ��

A=blkdiag(a*eye(3),b*eye(3));
S1=blkdiag(s1w*eye(3),s1v*eye(3));
S2=blkdiag(s2w*eye(3),s2v*eye(3));

out=-[zeros(3,1);cross(V(1:3),V(4:6))]-S1*(A\V)+S2*(A\W);
clear PotForce

return
%%%%%%%
%%���캯��Mdis
function out=Mdis(G0,G1,scale)
Rl=G0(1:3,1:3);Pl=G0(1:3,end);%λ�η�Χ�Ļ�������
Ru=G1(1:3,1:3);Pu=G1(1:3,end);%λ�η�Χ�Ļ�������
out=sqrt( 0.1+(norm(Pu-Pl))^2 + scale^2*acos(0.5*(trace(Rl\Ru)-1))^2 );%������ʽ
return
function [repsf,compsf]=Fading(Gf,G,G0,scale)
% repsf  ���Ʒ�������ֵ��˥��ϵ��(��Ŀ��Խ����˥����Խ����)
% compsf �������ڳ�ʼ�׶εĵ���ϵ���������ľ�����0.04���ڣ�

dis1=Mdis(Gf,G,scale);
dis0=Mdis(G0,G,scale);
ipson=2.3;%
x=dis1/(dis1+dis0);
repsf=(1-exp(-ipson*x^(1+1/ipson)))/(1-exp(-ipson));

K=80;
compsf=1+100*exp(-K*dis0.^(1+1/K));
%% ipsonȡֵ
% ChenWenrui
%.. tls01:   ipson(4.5),s1(50),s2(150)  F(1:3)=10*norm(F(4:6))*F(1:3); ϵ��Ϊ10.. ���ֳ�ֵ�Ŷ�5,5
%.. lear01:  ipson(3.0),s1(50),s2(150)  F(1:3)=10*norm(F(4:6))*F(1:3); ϵ��Ϊ10.. ���ֳ�ֵ�Ŷ�5,5
%.. mouse01: ipson(2.5),s1(50),s2(150)  F(1:3)=30*norm(F(4:6))*F(1:3); ϵ��Ϊ30.. ���ֳ�ֵ�Ŷ�5,5
%            ipson(2.3),s1(50),s2(150)  F(1:3)=10*norm(F(4:6))*F(1:3); ϵ��Ϊ10.. ���ֳ�ֵ�Ŷ�5,5
%            ----seframe: 162,250,3
%.. head01:  ipson(3.0),s1(50),s2(130)  F(1:3)=10*norm(F(4:6))*F(1:3); ϵ��Ϊ10.. ���ֳ�ֵ�Ŷ�5,5
%.. rear01:  ipson(3.5),s1(50),s2(150)  F(1:3)= 5*norm(F(4:6))*F(1:3); ϵ��Ϊ 5.. ���ֳ�ֵ�Ŷ�5,5
function out=unit(V)
%������V ��λ��
out=V/norm(V);
return

