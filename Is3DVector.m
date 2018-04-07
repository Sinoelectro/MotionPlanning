function out=Is3DVector(p)
%检查输入向量是否为3维向量(行向量或作列向量)
if nargin~=1,error('函数Is3DVector的输入变量个数错误，只能有一个输入变量');end
if nargout>1,error('函数Is3DVector的输出变量个数过多，最多只能有一个输出变量');end

if(isvector(p))
    p=ToColumnVector(p);
    nr=size(p,1);
    if(nr==3)
        out=1;
    else
        out=0;%disp('输入参数是向量但不是3维向量');
    end
else
    out=0;%disp('输入参数不是向量');
end
