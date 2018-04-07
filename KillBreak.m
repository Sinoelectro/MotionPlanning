function out=KillBreak(angle)
%%%%消除由于二元双变量函数atan2在2和3、1和4象限之间的跳动
%以及乘数因子的符号变化导致角度象限的变化
%除去角度序列中的跳变

if length(angle)~=1
    for ind=2:length(angle) %%后一个元素与前一个元素进行比较
        if angle(ind)-angle(ind-1)>=3*pi/2  || angle(ind)-angle(ind-1)<=-3*pi/2  %第三象限与第二象限
            if angle(ind-1)<0 %从第三象限突变到第二象限
                if ind-1<=5 && all(-2*pi+angle(ind:end)<-pi)%第一个元素处有突变
                   angle(1:ind-1)=2*pi+angle(1:ind-1);
                else
                    angle(ind)=-2*pi+angle(ind);
                end
            else %从二第象限突变到第三象限
                if ind-1<=5 && all(2*pi+angle(ind:end)>pi)%第一个元素处有突变
                    angle(1:ind-1)=-2*pi+angle(1:ind-1);
                else
                    angle(ind)=2*pi+angle(ind);
                end
            end
        end
        if (angle(ind)-angle(ind-1)>-3*pi/2 && angle(ind)-angle(ind-1)<=-pi/2) || ...
           (angle(ind)-angle(ind-1)>=pi/2 && angle(ind)-angle(ind-1)<3*pi/2) %第一象限（角度为正）与第四象限（角度为负）
            if angle(ind)-angle(ind-1)<0  %从第一象限的pi/2附近 突变到 第四象限的-pi/2附近
                angle(ind)=pi+angle(ind);        
            else %
                angle(ind)=-pi+angle(ind);%从第四象限的-pi/2附近 突变到 第一象限的pi/2附近
            end
        end
        if (angle(ind)-angle(ind-1)<=-1 && angle(ind)-angle(ind-1)>=-pi/2 && abs(angle(ind)+angle(ind-1)+pi)<0.1) || ...
           (angle(ind)-angle(ind-1)>=1 && angle(ind)-angle(ind-1)<=pi/2 && abs(angle(ind)+angle(ind-1)-pi)<0.1) %第一象限与第二象限（特征：相邻两角度不在pi/2附近,和为pi或者-pi，但变化率却有跳跃）  
            if angle(ind)-angle(ind-1)>0  %从第一象限 突变到 第二象限
                angle(ind)=pi-angle(ind);
            else %从第四象限 突变到 第三象限
                angle(ind)=-(pi+angle(ind));
            end
        end
    end
end
out=angle;
return
