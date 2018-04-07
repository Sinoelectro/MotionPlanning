function [outGh,ObjectShape,Qrobot,allQhuman,FullLimb,SimpleLimb,Humerus]=MotionPlanning_20140131(ActionType) 
% LieIntergrator_20140131.m 
% StateFun_20140131.m
% ActionType: 'tls','lear','mouse','head','rear'


%% ------------------���β�����λ�ò���-----------------------%%%%%
unt=1e2;%cm->m
Lu=(31.5)/unt;% ��۳���  Motco Database��24 (170cm,65Kg)    cwr:27.6
Lf=(24.6)/unt;% С�۳���  Motco Database��23 (170cm,65Kg)    cwr:24
Lh=5.0/unt;%����һ��ĳ���

%AR���µ������ᶨ��
XI{1}=createtwist([0;1;0],[0;0;0]);
XI{2}=createtwist([1;0;0],[0;0;0]);
XI{3}=createtwist([0;0;1],[0;0;0]);%��ؽڵ������˶�����
XI{4}=createtwist([0;1;0],[0;0;-Lu]);%��ؽڵ��˶�����
XI{5}=createtwist([0;0;1],[0;0;-Lu-Lf]);
XI{6}=createtwist([0;1;0],[0;0;-Lu-Lf]);
XI{7}=createtwist([1;0;0],[0;0;-Lu-Lf]);%��ؽڵ������˶�����
Gst_elbow=transl(0,0,-Lu);
Gst_wrist=transl(0,0,-Lu-Lf);
Gst_hand=transl(0,0,-Lu-Lf-Lh);%ĩ��ִ������ʼ��λ

Humerus=robot(XI(1:3),Gst_elbow);
Humerus.name='Humerus';
SimpleLimb=robot(XI(1:4),Gst_wrist);
SimpleLimb.name='SimpleLimb';
FullLimb=robot(XI,Gst_hand);
FullLimb.name='FullLimb';

%%  -----Ŀ��λ�����ʼλ�˶�����
%% ��һ�������ֱ���ʵ��������ȡ�˶���ʼλ�˺�Ŀ��λ��

XD=DataReorg();% ���뾭��������Ķ�������,һ�б�ʾһ��ؽڽ�(���ȵ�λ)��Ӧһ����̬,
               % �����붯��֮����NaN����,ͬ�ද�����ݵ�ĩβҲΪNaN,�ṹ���ڽ������˶��뷴���λ�ֿ����
action=getfield(XD,ActionType); % ��������ɸѡ��������

indnan=find(isnan( action.forward(1,:) ));%�ҳ�ĳ�ද���������˶��������Էָ������˶��ָ���

allQhuman_fd=action.forward([1,2,3,4,7,8,9],:);% �����˵�action�����������˶�,ȡ�����7���ؽڣ��磬�⣬��
allQhuman_fd=ISB2AR(allQhuman_fd); % ��ISB�����µ�ŷ���� תΪ AR���������µ�ŷ����

allQhuman_bk=action.backward([1,2,3,4,7,8,9],:);% �����˵�action�����������˶�,ȡ�����7���ؽڣ��磬�⣬��
allQhuman_bk=ISB2AR(allQhuman_bk); % ��ISB�����µ�ŷ���� תΪ AR���������µ�ŷ����

allQhuman=[action.forward([1,2,3,4,7,8,9],:),action.backward([1,2,3,4,7,8,9],:)];% �����˵�action�����������뷴���˶�,ȡ�����7���ؽڣ��磬�⣬��
allQhuman=ISB2AR(allQhuman); % ��ISB�����µ�ŷ���� תΪ AR���������µ�ŷ����
%%���������ɼ򻯣����ټ���ʱ��
Qhuman=action.forward( [1,2,3,4,7,8,9], 1:indnan(1)-1 ); %cwr��action�����ĵ�һ�������˶�,ȡ�����7���ؽڣ��磬�⣬��
%%indnan��1��-1ָ��һ���˶�����

Qhuman=ISB2AR(Qhuman); % ��ISB�����µ�ŷ���� תΪ AR���������µ�ŷ����

% ----Ŀ��ֵ��ƽ����
qf=sum( allQhuman_fd(:,indnan-1),2 )/length(indnan);
%%qf30��Ŀ��ֵ����ƽ��ֵ allQhuman_fd(:,indnan-1)Ϊ 7��30 single ����
Gf=fkine(FullLimb,qf);%�յ��ֵľ���λ��
Gwf=fkine(SimpleLimb,qf(1:4));%�յ�����ľ���λ��
Pwf=Gwf(1:3,end);%�յ�����ľ���λ��

dRf=Gwf(1:3,1:3)\Gf(1:3,1:3);%�յ��ֵ������̬%%Gf(3*3)Ϊ�յ�����ת����Gwf��3*3��Ϊ�յ�������ת���󣬴˲���������ֵ���ת����
dGf=rp2t(dRf,Pwf);%�յ��ֵ����λ��

% ----��ʼֵ��ƽ����
q0=sum( allQhuman_fd(:,[0,indnan(1:end-1)]+1),2 )/length(indnan); %q0(4)=0;��Ϊʲô��
%%%qf30����ʼֵ����ƽ��ֵ allQhuman_fd(:,[0,indnan(1:end-1)]+1)Ϊ 7��30 single ����
G0=fkine(FullLimb,q0);%�ֵľ��Գ�ʼ��λ
Gw0=fkine(SimpleLimb,q0(1:4));%����ľ��Գ�ʼ��λ
Pw0=Gw0(1:3,end); %��ؽھ��Գ�ʼ��λ��
 
dR0=Gw0(1:3,1:3)\G0(1:3,1:3); % ��ʼ�ֵ������̬
dG0=rp2t(dR0,Pw0); % ��ʼ�ֵ����λ��

%%  ---�����Ƴ�������
ObjectShape=BodyShape(Pw0,Pwf);%%Pw0 Pwf��������ֻӰ�����ϰ�����������λ�ã�����������������Ӱ��

scale=Scale(dG0,dGf);%norm(Pwf-Pw0)/( (3-trace(dR0\dRf))/4 );%%%��ʼ�����յ�������㣬���Ϊ��2
[tf0,tf1,oneFb2Wb]=AttForce(dG0,dGf,scale); %tf1��tf0����������Ŀ���˶����������� 1-��ʽ
repf=RepForce(dG0,dGf,scale);% ��������ƫ��ֱ���˶��ķ��������� 1-��ʽ
%%��̫��@��reshape������
%  -------��װ
PotForce.oneFb2Wb=oneFb2Wb;  %������ �� ���������任�� ���ű���
PotForce.tf1=tf1;            %ָ��Ŀ�������  ���ű���
PotForce.tf0=tf0;            %ָ������λ�õ�����  ���ű���
PotForce.repf=repf;          %�������Ķ����������� ���ű���

PotForce.G0=dG0; 
PotForce.Gf=dGf;
PotForce.scale=scale;
%%  --���λ���
qx0=q0+[0; 0/180*pi; 0/180*pi; 5/180*pi; 0/180*pi; 0; 0];%�ڳ�ʼ�ǶȵĻ����ϸ�һ��С���Ŷ������ɿ����ֵ���Ҫ��;
Gx0=fkine(FullLimb,qx0);
Gwx0=fkine(SimpleLimb,qx0(1:4));
dRx0=Gwx0(1:3,1:3)\Gx0(1:3,1:3);
Pwx0=Gwx0(1:3,end);
X0{1}=rp2t(dRx0,Pwx0);%���ֳ�ֵ (�ֵ������̬ + ����λ��)
w=zeros(3,1);v=zeros(3,1);%w=dRx0\[0; 0.1; 0]; v=dRx0\[-0.5; 0; 0];%  
X0{2}=[w(1:3); v(1:3)];%�ֵĳ�ʼ�ٶ�,�˶����� **** ��ʼ�ٶȶԹ켣��ʼ�׶���Ӱ�� *****
tspan=[0,20];%��ʱ��
stp=0.02;%ʱ�䲽��
%---������⣺outG�еĸ���Ԫ��Ϊ��R �ֵ������̬�� P ����Ŀռ�λ��
tic
[outdG,outV]=LieIntergrator_20140131(@StateFun_20140131,X0,tspan,stp,'L',PotForce); 
toc
%%  ---�˶�ѧ����
%___(1)�������Իع����
%[~,~,coef]=GetArmOrientation();%��������ۣ�theta1, theta2����С��(theta3, theta4)����̬������������֮������Իع��ϵ 10 x 4
coef=load('coef_linear_regression.mat');
coef=coef.coef;

rcf=CoordinateChange(squeeze(outdG(1:3,end,:)));%���󲿵Ŀռ�ѿ�������תΪ�����꣺R,Ce,Fai  3 x n��ÿһ�б�ʾһ��������

X0=ones(size(rcf(1,:)))';
X1=rcf(1,:)';
X2=rcf(2,:)';
X3=rcf(3,:)';
RCF=[X0,X1,X2,X3,X1.*X2,X1.*X3,X2.*X3,X1.*X1,X2.*X2,X3.*X3];%Ϊֱ����ʾ������ع�����׼��

tiba=(RCF*coef)';% �õ�����滮�����Ĵ�ۺ�С�۵���̬�� 4 x n, ÿһ�б�ʾһ����̬��
th1=tiba(1,:);
th2=tiba(2,:);
Pe=[-Lu*sin(th1).*cos(th2); Lu*sin(th1).*sin(th2); -Lu*cos(th1)];

Qrobot=qfun(Pe,squeeze(outdG(1:3,end,:)),Lu,Lf,outdG(1:3,1:3,:));%�����Ӧ�Ĺؽڽǣ�ÿһ�б�ʾһ��ؽڽǣ�AR����
%Qrobot=[q0,Qrobot];%���Ŷ�֮ǰ�ĳ�ֵ��������

outGh=fkine(FullLimb,Qrobot);%ĩ���ֵ�λ�˾���

%%  ---�Խ�����ӻ�
fmrg=seframe(ActionType);%�����ɵĹ켣��ѡȡ���ʵ����䣬���������ٶȹ켣������
spts=fmrg(1):fmrg(3):fmrg(2);
% plotWVandP(FullLimb,Qrobot,fmrg,allQhuman_fd,allQhuman_bk,stp); %�����ٶȺ�λ�ù켣
% plotAsmCurve(outGh, ObjectShape,spts);hold on %����ĩ���ֵĿռ�켣��spts����Ҫ���Ƶ�֡��Ź��ɵ�����
% plotLims(Humerus,SimpleLimb,Qrobot,[0;0;0],spts);hold off %����֫����λ�Ŀռ�켣
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%---------------�����˶��滮�������------------%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%_____________________________________________________________________________
function ObjectShape=BodyShape(P0,Pf)
% �������ʼλ�ú�Ŀ��λ�ã�Pf,P0
center=0.5*(Pf+P0);
radius=0.5*norm(Pf-P0);%%normŷ����÷���
sphereObs.A=0.5*radius*ones(1,3);% ���ϰ���������
sphereObs.I=[1,1];% ���ϰ�����ݲ���
sphereObs.G=rp2t(eye(3),center);% ���ϰ�����ȫ������ϵ�µ�λ��%%��̬Ϊ��λ��λ��Ϊ��ʼ���յ������


bodycorner=[-120;-32+25;68];

unt3=1e3;%mm->m
head.A=0.5*[200,170,250]/unt3;%ͷ�������
head.I=[1,1];%ͷ���ݲ���
head.G=rp2t(eye(3),(bodycorner+[-30;-85;15]+0.5*[200;-170;250])/unt3);%ͷ��ȫ������ϵ�µ�λ��

body.A=0.5*[230,340,680]/unt3;%�����ϰ���������[117.5,155,375]/unt3;[135,155,375]/unt3;
body.I=[1,1];%�����ϰ�����ݲ���
body.G=rp2t(eye(3),(bodycorner+0.5*[230;-340;-680])/unt3);%�ϰ�����ȫ������ϵ�µ�λ��

hand.A=[10,30,50]/unt3;%���֣�����������
hand.I=[0.5,0.5];%������ݲ���
syms x y z
hand.G=rp2t(eye(3),[x;y;z]);%G0;%������ȫ������ϵ�µ�λ�ã���������̬��Ӱ�죩

thumb.A=[7.5,7.5,25]/unt3;%��Ĵָ������������
thumb.I=[1,1];%������ݲ���
thumb.G=rp2t(eye(3),[0;37.5;10]/unt3);%G0;%Ĵָ��'������ϵ'�µ�λ��  

ObjectShape.sphereObs=sphereObs;
ObjectShape.head=head;
ObjectShape.body=body;
ObjectShape.hand=hand;
ObjectShape.thumb=thumb;
return

%%%%%%________________________________________________________________________________
function f=RepForce(G0,Gf,scale)
% ������������
Rl=G0(1:3,1:3);Pl=G0(1:3,end);%λ�η�Χ�Ļ�������
Ru=Gf(1:3,1:3);Pu=Gf(1:3,end);%λ�η�Χ�Ļ�������

angc=0.5*(InvEuler(Rl,'XYZ')+InvEuler(Ru,'XYZ'));
 Rc=rotx(angc(1))*roty(angc(2))*rotz(angc(3));
Pc=0.5*(Pl+Pu);

syms q1 q2 q3 x y z 
R=rotx(q1)*roty(q2)*rotz(q3);
P=[x;y;z];

Pot=sqrt( sum((P-Pc).*(P-Pc)) + scale^2*acos(0.5*(trace(Rc\R)-1))^2 );%�������ʽ
Pot=simplify(Pot);

f=jacobian(Pot,[q1 q2 q3 x y z]).';%�� 1-��ʽ 
%%%%%�����޸�
%f=@(q1, q2, q3, x, y, z)reshape(sym2str(f),6,1);
%f=@(q1, q2, q3, x, y, z)f;


return

%%%%%________________________________________________________________________________
function [tf0,tf1,oneFb2Wb]=AttForce(G0,Gf,scale)
% ������������ �� ������������ 1-form
Rl=G0(1:3,1:3);Pl=G0(1:3,end);%λ�η�Χ�Ļ�������
Ru=Gf(1:3,1:3);Pu=Gf(1:3,end);%λ�η�Χ�Ļ�������

syms q1 q2 q3 x y z 
R=rotx(q1)*roty(q2)*rotz(q3);
P=[x;y;z];
G=transl(x,y,z)*rp2t(R,zeros(3,1));%%���ż��㣬x.y.z��Ϊƽ�Ƶ���������q1q2q3��Ϊ��ת�������
[LXb2E,oneFb2Wb]=Mat_BasisMap(G,'L');%%�õ�6ά������ת��

LXb2E=@(q1, q2, q3, x, y, z)reshape(sym2str(LXb2E),6,6); %%����һ��Ϊת��Ϊ�ַ���
%oneFb2Wb=@(q1, q2, q3, x, y, z)reshape(sym2str(oneFb2Wb),6,6); 
%%������������ɶ��˼
%%%�����޸�
%oneFb2Wb=@(q1, q2, q3, x, y, z)oneFb2Wb; 

Pot1=sqrt(0.1+ sum((Pu-P).*(Pu-P)) + scale^2*acos(0.5*(trace(R\Ru)-1))^2 )-0.1;%�������ʽ
Pot0=sqrt(0.1+ sum((P-Pl).*(P-Pl)) + scale^2*acos(0.5*(trace(Rl\R)-1))^2 )-0.1;

Pot1=simplify(Pot1);
Pot0=simplify(Pot0);

tf1=-jacobian(Pot1,[q1 q2 q3 x y z ]).';%�� 1-��ʽ           
tf0=-jacobian(Pot0,[q1 q2 q3 x y z ]).';
tf1=simplify(tf1);
tf0=simplify(tf0);
%%%%%%%%%%%%%%%�����޸�
% tf1=@(q1, q2, q3, x, y, z)reshape(sym2str(tf1),6,1);
%tf1=@(q1, q2, q3, x, y, z)tf1;
%tf0=@(q1, q2, q3, x, y, z)reshape(sym2str(tf0),6,1);
%tf0=@(q1, q2, q3, x, y, z)tf0;
return

%%%%%%________________________________________________________________________________
function rcf=CoordinateChange(Pw)
% Pw���󲿵Ŀռ�ѿ������꣬ÿһ�о���ʾһ������� AR���µ�����ϵ
% rcf: �󲿵�������(radius,ce,fai)��ÿһ�б�ʾһ�������
if size(Pw,1)~=3
    error('invalid input!!');
end
rcf=zeros(3,size(Pw,2));

for ind=1:size(Pw,2) %������������������(radius,ce,fai) 
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
% ��ISB�����µ�ŷ���� תΪ AR���������µ�ŷ���ǣ�һ�б�ʾһ��ؽڽ�(���ȵ�λ)��Ӧһ����̬
% QΪISB�����µ�ŷ����
Rs=ones(3,3,size(Q,2));
Rw=ones(3,3,size(Q,2));
for ind=1:size(Q,2)% ��ISB���� תΪAR���µ�����  ŷ����ת��
    a=Q(1,ind);
    b=Q(2,ind);
    c=Q(3,ind);
    Rs(:,:,ind)=rotx(a)*roty(b)*rotz(c);% �Ӽ�ؽ�����ϵ��ISB����Ӧ��AR���µ���̬����
    a=Q(5,ind);
    b=Q(6,ind);
    c=Q(7,ind);
    Rw(:,:,ind)=rotz(a)*roty(b)*rotx(-c);%����ؽ�����ϵ��ISB����Ӧ��AR���µ���̬����        
end
Qs=InvEuler(Rs,'YXZ')';
Qw=InvEuler(Rw,'ZYX')';
Qar=[Qs;   Q(4,:);   Qw];%�����ӦAR����
return

%%%%%%________________________________________________________________________________
function Q=qfun(PE,PW,Lu,Lf,dRW)
% ���,��,��ؽڵĽǶ� AR���µ�����ϵ
% PE,PW��ÿһ�о���ʾһ��ռ�����,dRW��ÿһ�����ʾһ��SO(3),
% Q ÿһ�б�ʾһ��ؽڽǣ������AR����

Q=ones(7, size(PE,2));
Ps=0;
for ind=1:size(PE,2)
    Pe=PE(:,ind);
    Pw=PW(:,ind);
    dRw=dRW(:,:,ind);
	%%%%%%%*************���ؽ�ת��*************%%%%%%%%%%%%%%%%%%
    sz=(Ps-Pe)/norm(Ps-Pe);
    sy=cross(sz,Ps-Pw);
    sy=sy/norm(sy);
    sx=cross(sy,sz);
    Rs=[sx,sy,sz];
    tmp=InvEuler(Rs,'YXZ');
    q1=tmp(1);%���� -90< q2< 90,��Ҫʹ��killbreak
    q2=tmp(2);
    q3=tmp(3);

	%%%%%%%*************���������ؽ�ת��*************%%%%%%%%%%%%%%%%%%%
    q4=pi-acos((Lu^2+Lf^2-norm(Pw-Ps)^2)/(2*Lu*Lf));

	%%%%%%%*************���������ؽ�ת��*************%%%%%%%%%%%%%%%%%%%
    tmp=InvEuler(dRw,'ZYX');%��������ؽ�ŷ���Ƕ�
    q5=tmp(1);%���� -90< q2< 90,��Ҫʹ��killbreak
    q6=tmp(2);
    q7=tmp(3);
    
    Q(:,ind)=[q1,q2,q3,q4,q5,q6,q7]';
end
return

function out=seframe(ActionType)
% [a b c] �����ɵĹ켣��ѡȡ���ʵ�����(ǰ��������a,b)�����������ٶȹ켣������.��������c��ʾ��ͼʱ��֡���
% Actiontype��'tls','lear','mouse','head','rear'
SEframe.tls=[67, 123,2];
SEframe.lear=[173, 249,2];
SEframe.mouse=[169, 240,2];%
SEframe.head=[191, 269, 3];
SEframe.rear=[79, 146, 2];
out=getfield(SEframe,ActionType);
return