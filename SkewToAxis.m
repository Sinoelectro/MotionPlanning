function W=SkewToAxis(S)
%由给定的反对称矩阵生成一个矢量
if nargin~=1,error('函数SkewToAxis的输入变量个数错误，只能有一个输入变量');end
if nargout>1,error('函数SkewToAxis的输出变量个数过多，只能有一个输出变量');end

[r,c]=size(S);
if ~IsSkew(S)
    error('不是反对称矩阵');
end
r1=-S(2,3);r2=S(1,3);r3=-S(1,2);
W=[r1,r2,r3].';%输出为列矢量