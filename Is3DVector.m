function out=Is3DVector(p)
%������������Ƿ�Ϊ3ά����(����������������)
if nargin~=1,error('����Is3DVector�����������������ֻ����һ���������');end
if nargout>1,error('����Is3DVector����������������࣬���ֻ����һ���������');end

if(isvector(p))
    p=ToColumnVector(p);
    nr=size(p,1);
    if(nr==3)
        out=1;
    else
        out=0;%disp('�������������������3ά����');
    end
else
    out=0;%disp('���������������');
end
