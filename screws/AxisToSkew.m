function W=AxisToSkew(A)
if nargin~=1,error('函数AxisToSkew_S的输入变量个数错误，只能有一个输入变量');end
if nargout>1,error('函数AxisToSkew_S的输出变量个数过多，最多只能有一个输出变量');end

if(isvector(A))
    A=ToColumnVector(A);
    nr=size(A,1);
    if(nr==3)
        r1=A(1,1);r2=A(2,1);r3=A(3,1);
        W=[0,-r3,r2;
           r3,0,-r1;
           -r2,r1,0];
    else
    error('输入参数不是三维向量');
    end
else
    error('输入参数不是向量');
end