function out=IsHomogeneous(g)
%检查矩阵g是否为齐次矩阵
if nargin~=1,error('函数IsRotationHomogeneousForskew的输入变量个数错误，只能有一个输入变量');end
if nargout>1,error('函数IsRotationHomogeneousForskew的输出变量个数过多，最多只能有一个输出变量');end

[nr,nc]=size(g);
if nr<4 || nc<4
    out=0;
elseif ~IsRotation(g(1:nr-1,1:nc-1))
    out=0;%disp('不是齐次矩阵');
elseif(~Is3DVector(g(1:nr-1,nc)))
    out=0;
elseif(isa(g,'sym'))
    carry=g(nr,:)==sym([0 0 0 1]); %
    if all(carry(:))  %改良isequal (isequal对符号矩阵无法做出正确判断)
        out=1;
    else
        out=0;
    end
elseif isequal(g(nr,:),[0 0 0 1]) 
    out=1;
else out=0;
end

