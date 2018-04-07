function out=IsRotation(R)
%�����������Ƿ�Ϊ��ת����
if nargin~=1,error('����IsRotation�����������������ֻ����һ���������');end
if nargout>1,error('����IsRotation����������������࣬���ֻ����һ���������');end

[nr,nc]=size(R);

if(isa(R,'sym'))%����Ƿ��ž���
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
        out=0;%disp('��������ά������ȷ');
    elseif(abs(dot(c1,c2))>1e-5||abs(dot(c1,c3))>1e-5||abs(dot(c2,c3))>1e-5)
        out=0;%disp('�����������������');
    elseif(abs(det(R)-1)>1e-010)
        out=0;%disp('������������ʽֵ��1');
    else out=0;
    end
end
