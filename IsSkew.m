function out=IsSkew(S)
%判断输入参数是否为反对称矩阵
if nargin~=1,error('函数IsSkew的输入变量个数错误，只能有一个输入变量');end
if nargout>1,error('函数IsSkew的输出变量个数过多，最多只能有一个输出变量');end

[nr,nc]=size(S);
if(nr~=1&&nc~=1)%确定S是矩阵
    if isa(S,'sym')
        S=simplify(S);
        carry=S.'==-1.*S; %
        if all(carry(:))  %改良isequal (isequal对符号矩阵无法做出正确判断)
            out=1;
        else
            out=0;
        end    
    else %数值矩阵
        carry=(S+S')<1e-10 ; 
        if all(carry(:))  
            out=1;
        else
            out=0;
        end    
    
    end

else
    out=0;%disp('输入参数不是矩阵');
end
