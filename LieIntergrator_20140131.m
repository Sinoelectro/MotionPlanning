function [outG,outV]=LieIntergrator_20140131(Statefun,S0,tspan,step,LR,PotForce)
% Lie group intergrator, MK method
% 'Geometric integration on Euclidean group with application to articulated multibody systems. 2005 IEEE'
% Statefun: 二阶微分方程句柄 '@**'
% S0{1}-- G0: SE(3) 初始状态
% S0{2}-- V0: se(3) 初始速度
% tspan: [t0 tf] 总时间隔
% step: 时间步长
% LR: SE(3)上的向量场是左平移还是右平移
% PotForce: 势能场的相关结构体

if nargin~=6,error('输入变量个数错误，只能有7个输入变量');end
if nargout>2,error('函数的输出变量个数过多，只能有2个输出变量');end

if ~isa(Statefun,'function_handle')
    error('Please input funtion handle');
end
if ~IsHomogeneous(S0{1}) || ~isvector(S0{2})|| ~ischar(LR)
    error('输入参数类型错误');
end

%tableaux
c=[0 1/2 1/2 1];
b=[1/6 2/6 2/6 1/6];
a=zeros(4,4);
a(2,1)=1/2; a(3,2)=1/2; a(4,3)=1;
%

h=step;%步长
t0=tspan(1); tf=tspan(2);
steps=floor((tf-t0)/step);%总时长内迭代的步数

G0=S0{1};%几何积分初值
V0=ToColumnVector(S0{2});%几何积分初值

outG=NaN([size(G0),steps]);
outV=NaN(length(V0),steps);

inc=1;
outG(:,:,inc)=G0;
outV(:,inc)=V0;

while inc<steps;  
    inc=inc+1;
    THc=[];Gc=[];Vc=[];Kc=[];Fc=[];
    for ind=1:4 % Munthe-Kaas method (MK method)
        t1=t0+h*c(ind);
        if ind==1
            Gc(:,:,ind)=G0;
            Vc(:,ind)=V0;
            Kc(:,ind)=feval(Statefun,t1,G0,V0,PotForce);
            THc(:,ind)=zeros(length(V0),1);
            Fc(:,ind)=dexpV_inv(-THc(:,ind))*V0;
        else
            THc(:,ind)=h*sum( repmat(a(ind,1:ind-1),length(V0),1).*Fc ,2);
            if LR=='L'
                Gc(:,:,ind)=G0*twistexp(THc(:,ind),1);
            elseif LR=='R'
                Gc(:,:,ind)=twistexp(THc(:,ind),1)*G0;
            else
                error('must be "L"or "R" ');
            end
            Vc(:,ind)=V0+h*sum( repmat(a(ind,1:ind-1),length(V0),1).*Kc ,2); 
            Kc(:,ind)=feval(Statefun,t1,Gc(:,:,ind),Vc(:,ind),PotForce);
            Fc(:,ind)=dexpV_inv(-THc(:,ind))*Vc(:,ind);
        end
    end
    TH=h*sum( repmat(b,length(V0),1).*Fc ,2);
    if LR=='L'
        outG(:,:,inc)=G0*twistexp(TH,1);
    elseif LR=='R'
        outG(:,:,inc)=twistexp(TH,1)*G0;
    else
        error('must be "L"or "R" ');
    end    
    outV(:,inc)=V0+h*sum( repmat(b,length(V0),1).*Kc ,2); 
    V0=outV(:,inc);
    G0=outG(:,:,inc);
    t0=t1;
    
    if Mdis(outG(:,:,inc),PotForce.Gf,PotForce.scale)<5e-4 
        break;
    end
end
tag=find(isnan(outV(1,:)),1,'first');
if ~isempty(tag)
    outG(:,:,tag:end)=[];
    outV(:,tag:end)=[];
end
return;
function out=Mdis(G0,G1,scale)
Rl=G0(1:3,1:3);Pl=G0(1:3,end);%位形范围的积分下限
Ru=G1(1:3,1:3);Pu=G1(1:3,end);%位形范围的积分上限
out=sqrt( 0.1+(norm(Pu-Pl))^2 + scale^2*acos(0.5*(trace(Rl\Ru)-1))^2 );%距离表达式
return

function out=dexpV(V)
% V=[v,w]
if ~isvector(V)
    error('please input vector');
end
w=V(1:3);
v=V(4:6);
if abs(norm(w))<1e-10;
    C=zeros(3,3);
else
    tmp=0.5*norm(w);
    s=sin(tmp)/tmp; c=cos(tmp);
    gama=c/s;
    alpha=s*c;
    beta=s^2;
    ATvw=AxisToSkew(v)*AxisToSkew(w)+AxisToSkew(w)*AxisToSkew(v);
    C=-0.5*(1-beta)*AxisToSkew(v)+4*(1-alpha)/tmp^2*ATvw+4*(alpha-beta)/tmp^2*dot(v,w)*AxisToSkew(w)...
        +4/tmp^2*(0.5*beta-12*(1-alpha)/tmp^2)*dot(v,w)*AxisToSkew(v)^2;
end
    out=[dexpw(w) C+0.5*AxisToSkew(v); zeros(3,3)  dexpw(w)];    
return

function out=dexpV_inv(V)
% V=[v,w]
if ~isvector(V)
    error('please input vector');
end
w=V(1:3);
v=V(4:6);
if abs(sin(norm(w)/2))<1e-16 && abs(norm(w))>1e-10 %sin(|w|/2)=0 并且w~=0, dexpv 变成singular
    disp('exponential matrix is singular !!');
    out=NaN; 
else
    if abs(norm(w))<1e-10
        D=zeros(3,3);
    else
        tmp=0.5*norm(w);
        s=sin(tmp)/tmp; c=cos(tmp);
        gama=c/s;
        alpha=s*c;
        beta=s^2;
        ATvw=AxisToSkew(v)*AxisToSkew(w)+AxisToSkew(w)*AxisToSkew(v);
        D=(1-gama)/(4*tmp^2)*ATvw+(1/beta+gama-2)/(16*tmp^4)*dot(v,w)*AxisToSkew(w)^2;
    end
    out=[dexpw_inv(w) D-0.5*AxisToSkew(v); zeros(3,3)  dexpw_inv(w)];
end
return

function out=dexpw(w)
% w: 角速度
if ~isvector(w)
    error('please input vector');
end
tmp=norm(w);
if abs(tmp)<1e-10;
    out=eye(3);
else
    x1=sin(tmp/2)^2;
    x2=tmp^2/2;
    x3=(tmp-sin(tmp))/tmp^3;
    out=eye(3)+x1/x2*AxisToSkew(w)+x3/x4*(AxisToSkew(w))^2;
end
return

function out=dexpw_inv(w)
% w: 角速度
if ~isvector(w)
    error('please input vector');
end
tmp=norm(w);
if abs(tmp)<1e-10;
    out=eye(3);
else
    x1=tmp/tan(tmp/2)-2;
    x2=2*tmp^2;
    out=eye(3)-AxisToSkew(w)/2-x1/x2*AxisToSkew(w)^2;
end
return

