function W=AxisToSkew(A)
if nargin~=1,error('����AxisToSkew_S�����������������ֻ����һ���������');end
if nargout>1,error('����AxisToSkew_S����������������࣬���ֻ����һ���������');end

if(isvector(A))
    A=ToColumnVector(A);
    nr=size(A,1);
    if(nr==3)
        r1=A(1,1);r2=A(2,1);r3=A(3,1);
        W=[0,-r3,r2;
           r3,0,-r1;
           -r2,r1,0];
    else
    error('�������������ά����');
    end
else
    error('���������������');
end