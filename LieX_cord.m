function out=LieX_cord(LX,G,LR)
%对于某个通过左右作用获得的切向量场LX（size：4x4），求其在该点（SE3）处的坐标分量 component
%G:SE(3)
%LR: 'L'or 'R',LX是左不变向量场还是右不变向量场
if nargin~=3,error('输入变量个数错误，只能有三个输入变量');end
if nargout>1,error('函数的输出变量个数过多，最多只能有一个输出变量');end
 
if ~IsRotation(G(1:3,1:3)) || ~ischar(LR) 
    error('变量类型错误！');
end
[r,n]=size(LX);
if isa(LX,'sym')
    LX=simplify(LX);
    carry=LX(end,:)==sym(zeros(1,4)); %
else
    carry=LX(end,:)==zeros(1,4); %
end
if r~=4 || n~=4 || ~all(carry(:))%改良isequal (isequal对符号矩阵无法做出正确判断)
    error('变量类型错误！');
end

if LR=='L'
    tmp=G\LX;
elseif LR=='R'
    tmp=LX/G;
else
    error('输入错误');
end
if isa(LX,'sym')
    tmp=simplify(tmp);
end
w=SkewToAxis(tmp(1:3,1:3));%%将反对称矩阵转换为列矢量
v=tmp(1:3,end);
out=[w;v];

return

    
