function out=IsRotation(R)
%检查输入矩阵是否为旋转矩阵
if nargin~=1,error('函数IsRotation的输入变量个数错误，只能有一个输入变量');end
if nargout>1,error('函数IsRotation的输出变量个数过多，最多只能有一个输出变量');end

[nr,nc]=size(R);

if(isa(R,'sym'))%如果是符号矩阵
    if(nr==3 && nc==3)
        out=1;
    else
        out=0;
    end
else
    if(nr==3)&&(nc==3)
        c1=R(:,1);c2=R(:,2);c3=R(:,3);
        if (abs(dot(c1,c2))<10e-5)&&(abs(dot(c1,c3))<10e-5)&&(abs(dot(c2,c3))<10e-5)&&(abs(det(R)-1)<10e-5)
            out=1;
        else
            out=0;
        end
    elseif(nr~=3||nc~=3)
        out=0;%disp('输入矩阵的维数不正确');
    elseif(abs(dot(c1,c2))>1e-5||abs(dot(c1,c3))>1e-5||abs(dot(c2,c3))>1e-5)
        out=0;%disp('输入矩阵不是正交矩阵');
    elseif(abs(det(R)-1)>1e-010)
        out=0;%disp('输入矩阵的行列式值非1');
    else out=0;
    end
end
