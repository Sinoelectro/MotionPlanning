function W=SkewToAxis(S)
%�ɸ����ķ��Գƾ�������һ��ʸ��
if nargin~=1,error('����SkewToAxis�����������������ֻ����һ���������');end
if nargout>1,error('����SkewToAxis����������������ֻ࣬����һ���������');end

[r,c]=size(S);
if ~IsSkew(S)
    error('���Ƿ��Գƾ���');
end
r1=-S(2,3);r2=S(1,3);r3=-S(1,2);
W=[r1,r2,r3].';%���Ϊ��ʸ��