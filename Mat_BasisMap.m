function [LXb2E,oneFb2Wb]=Mat_BasisMap(G,LR)
%���SE(3)�пռ�Ļ�ӳ�䵽���л���ϵ������,��ԭ�Ĺ�ʽ19��LXb2E
%���F��one-form����ӳ�䵽���пռ䣨������������ϵ������,��ԭ�Ĺ�ʽ20��oneFb2Wb
%%2002 ASME A geometrical approach to the study of the Cartesian stiffness matrix
%G:SE(3)
%%LR: 'L'or 'R',LX���󲻱������������Ҳ���������

if nargin~=2,error('���������������ֻ���������������');end
if nargout~=2,error('���������������ֻ����2���������');end

if ~IsRotation(G(1:3,1:3))
    error('����������ʹ���');
end
smbs=symvar(G);% Ĭ�� [th1, th2, th3, x, y, z]
%syms E
for ind=1:6
    tmp=simplify(diff(G,smbs(ind)));
    E(:,ind)=LieX_cord(tmp,G,LR); %ÿһ��ΪLie�������ڻ��µ�����
end
LXb2E=E.';
oneFb2Wb=E;

return
