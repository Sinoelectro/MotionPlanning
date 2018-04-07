function out=IsHomogeneous(g)
%������g�Ƿ�Ϊ��ξ���
if nargin~=1,error('����IsRotationHomogeneousForskew�����������������ֻ����һ���������');end
if nargout>1,error('����IsRotationHomogeneousForskew����������������࣬���ֻ����һ���������');end

[nr,nc]=size(g);
if nr<4 || nc<4
    out=0;
elseif ~IsRotation(g(1:nr-1,1:nc-1))
    out=0;%disp('������ξ���');
elseif(~Is3DVector(g(1:nr-1,nc)))
    out=0;
elseif(isa(g,'sym'))
    carry=g(nr,:)==sym([0 0 0 1]); %
    if all(carry(:))  %����isequal (isequal�Է��ž����޷�������ȷ�ж�)
        out=1;
    else
        out=0;
    end
elseif isequal(g(nr,:),[0 0 0 1]) 
    out=1;
else out=0;
end

