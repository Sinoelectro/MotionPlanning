function out=IsSkew(S)
%�ж���������Ƿ�Ϊ���Գƾ���
if nargin~=1,error('����IsSkew�����������������ֻ����һ���������');end
if nargout>1,error('����IsSkew����������������࣬���ֻ����һ���������');end

[nr,nc]=size(S);
if(nr~=1&&nc~=1)%ȷ��S�Ǿ���
    if isa(S,'sym')
        S=simplify(S);
        carry=S.'==-1.*S; %
        if all(carry(:))  %����isequal (isequal�Է��ž����޷�������ȷ�ж�)
            out=1;
        else
            out=0;
        end    
    else %��ֵ����
        carry=(S+S')<1e-10 ; 
        if all(carry(:))  
            out=1;
        else
            out=0;
        end    
    
    end

else
    out=0;%disp('����������Ǿ���');
end
