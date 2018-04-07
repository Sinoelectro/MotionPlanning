function [LXb2E,oneFb2Wb]=Mat_BasisMap(G,LR)
%求从SE(3)切空间的基映射到流行基的系数矩阵,见原文公式19，LXb2E
%求从F（one-form）基映射到余切空间（力旋量）基的系数矩阵,见原文公式20，oneFb2Wb
%%2002 ASME A geometrical approach to the study of the Cartesian stiffness matrix
%G:SE(3)
%%LR: 'L'or 'R',LX是左不变向量场还是右不变向量场

if nargin~=2,error('输入变量个数错误，只能有三个输入变量');end
if nargout~=2,error('输出变量个数错误，只能有2个输出变量');end

if ~IsRotation(G(1:3,1:3))
    error('输入参数类型错误');
end
smbs=symvar(G);% 默认 [th1, th2, th3, x, y, z]
%syms E
for ind=1:6
    tmp=simplify(diff(G,smbs(ind)));
    E(:,ind)=LieX_cord(tmp,G,LR); %每一列为Lie向量场在基下的坐标
end
LXb2E=E.';
oneFb2Wb=E;

return
