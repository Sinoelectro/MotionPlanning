function out=LieX_cord(LX,G,LR)
%����ĳ��ͨ���������û�õ���������LX��size��4x4���������ڸõ㣨SE3������������� component
%G:SE(3)
%LR: 'L'or 'R',LX���󲻱������������Ҳ���������
if nargin~=3,error('���������������ֻ���������������');end
if nargout>1,error('��������������������࣬���ֻ����һ���������');end
 
if ~IsRotation(G(1:3,1:3)) || ~ischar(LR) 
    error('�������ʹ���');
end
[r,n]=size(LX);
if isa(LX,'sym')
    LX=simplify(LX);
    carry=LX(end,:)==sym(zeros(1,4)); %
else
    carry=LX(end,:)==zeros(1,4); %
end
if r~=4 || n~=4 || ~all(carry(:))%����isequal (isequal�Է��ž����޷�������ȷ�ж�)
    error('�������ʹ���');
end

if LR=='L'
    tmp=G\LX;
elseif LR=='R'
    tmp=LX/G;
else
    error('�������');
end
if isa(LX,'sym')
    tmp=simplify(tmp);
end
w=SkewToAxis(tmp(1:3,1:3));%%�����Գƾ���ת��Ϊ��ʸ��
v=tmp(1:3,end);
out=[w;v];

return

    
