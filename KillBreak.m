function out=KillBreak(angle)
%%%%�������ڶ�Ԫ˫��������atan2��2��3��1��4����֮�������
%�Լ��������ӵķ��ű仯���½Ƕ����޵ı仯
%��ȥ�Ƕ������е�����

if length(angle)~=1
    for ind=2:length(angle) %%��һ��Ԫ����ǰһ��Ԫ�ؽ��бȽ�
        if angle(ind)-angle(ind-1)>=3*pi/2  || angle(ind)-angle(ind-1)<=-3*pi/2  %����������ڶ�����
            if angle(ind-1)<0 %�ӵ�������ͻ�䵽�ڶ�����
                if ind-1<=5 && all(-2*pi+angle(ind:end)<-pi)%��һ��Ԫ�ش���ͻ��
                   angle(1:ind-1)=2*pi+angle(1:ind-1);
                else
                    angle(ind)=-2*pi+angle(ind);
                end
            else %�Ӷ�������ͻ�䵽��������
                if ind-1<=5 && all(2*pi+angle(ind:end)>pi)%��һ��Ԫ�ش���ͻ��
                    angle(1:ind-1)=-2*pi+angle(1:ind-1);
                else
                    angle(ind)=2*pi+angle(ind);
                end
            end
        end
        if (angle(ind)-angle(ind-1)>-3*pi/2 && angle(ind)-angle(ind-1)<=-pi/2) || ...
           (angle(ind)-angle(ind-1)>=pi/2 && angle(ind)-angle(ind-1)<3*pi/2) %��һ���ޣ��Ƕ�Ϊ������������ޣ��Ƕ�Ϊ����
            if angle(ind)-angle(ind-1)<0  %�ӵ�һ���޵�pi/2���� ͻ�䵽 �������޵�-pi/2����
                angle(ind)=pi+angle(ind);        
            else %
                angle(ind)=-pi+angle(ind);%�ӵ������޵�-pi/2���� ͻ�䵽 ��һ���޵�pi/2����
            end
        end
        if (angle(ind)-angle(ind-1)<=-1 && angle(ind)-angle(ind-1)>=-pi/2 && abs(angle(ind)+angle(ind-1)+pi)<0.1) || ...
           (angle(ind)-angle(ind-1)>=1 && angle(ind)-angle(ind-1)<=pi/2 && abs(angle(ind)+angle(ind-1)-pi)<0.1) %��һ������ڶ����ޣ��������������ǶȲ���pi/2����,��Ϊpi����-pi�����仯��ȴ����Ծ��  
            if angle(ind)-angle(ind-1)>0  %�ӵ�һ���� ͻ�䵽 �ڶ�����
                angle(ind)=pi-angle(ind);
            else %�ӵ������� ͻ�䵽 ��������
                angle(ind)=-(pi+angle(ind));
            end
        end
    end
end
out=angle;
return
