function outV=plotWVandP(FullLimb,Qrobot,fmrg,Qhuman_fd,Qhuman_bk,stp)
% ������������ϵ�б�ʾ���ٶȱ�ʾ����������ϵ�������������һ��ƹ���ϵ���������ͼ
% fmrg: �����ɵ�Qrobot�켣��ѡȡ���ʵ����䣬���������ٶȹ켣������
% Qhuman �м京��NaN���������Ը��������˶��켣��ĩβҲ��NaN������

rows=size(Qrobot,1);%�ؽڸ���
dQrobot=zeros(size(Qrobot));
dQhuman=zeros(size(Qhuman_fd));
for ind=1:rows
    dQrobot(ind,:)=diff7(Qrobot(ind,:),stp);
    dQhuman(ind,:)=mydiff7(Qhuman_fd(ind,:),stp);
end

Vrobot=zeros(6,size(Qrobot,2));
for ind=1:size(Qrobot,2) %���������ĩ���ٶ�
    Vrobot(:,ind)=bjacob(FullLimb,Qrobot(:,ind))*dQrobot(:,ind);
end
Vrobot=[Vrobot(4:6,:);Vrobot(1:3,:)];%���ٶ����ϣ����ٶ�����

Vhuman=zeros(6,size(Qhuman_fd,2));
for ind=1:size(Qhuman_fd,2) %��������ĩ���ٶ�
    if all(isnan(Qhuman_fd(:,ind)))
        Vhuman(:,ind)=NaN*ones(6,1);
    else
        Vhuman(:,ind)=bjacob(FullLimb,Qhuman_fd(:,ind))*dQhuman(:,ind);
    end
end
Vhuman=[Vhuman(4:6,:);Vhuman(1:3,:)];%���ٶ����ϣ����ٶ�����

Grobot=fkine(FullLimb,Qrobot);
Ghuman_fd=fkine(FullLimb,Qhuman_fd);
Ghuman_bk=fkine(FullLimb,Qhuman_bk);

lbs={'X(m)','Y(m)','Z(m)'};
axhd=FigAxis(1,3);%ĩ��ƽ���˶��켣�Լ�ƽ���˶�����
pr=squeeze(Grobot(1:3,4,:)); % robot
pf=squeeze(Ghuman_fd(1:3,4,:)); % human �����˶�
pb=squeeze(Ghuman_bk(1:3,4,:)); % human �����˶�
for ind=1:3 %�ֱ���������ͼ�ϻ�    
    plot(axhd(ind),pf(ind,:),pf(mod(ind,3)+1,:));
    plot(axhd(ind),pb(ind,:),pb(mod(ind,3)+1,:));
    plot(axhd(ind),pr(ind,:),pr(mod(ind,3)+1,:),'linewidth',2,'color','red');
    xlabel(axhd(ind),lbs{ind});
    ylabel(axhd(ind),lbs{mod(ind,3)+1});
end
fh=figure; 
ah=gca;
set(fh,'Position',[100 100 200 200],'resize','off');
plotv(ah,Vhuman(4:6,:));% human�����ٶȹ켣��������Ĭ�Ϻ�������[0,1]
set(ah,'FontSize',2);   hold(ah,'on');
plot(ah,linspace(0,1,fmrg(2)-fmrg(1)+1), sqrt(sum(Vrobot(4:6,fmrg(1):fmrg(2)).^2)), 'linewidth',2,'color','red'); % robot�����ٶȹ켣������һ��
xlabel(ah,'time(s)');
ylabel(ah,'speed(m/s)');


lbs={'Z(rad)','Y(rad)','X(rad)'};
axhd=FigAxis(1,3);%ĩ��ת���˶��켣
R=Grobot(1:3,1:3,:); % robot
rr=InvEuler(R,'ZYX')';
R=Ghuman_fd(1:3,1:3,:); % human �����˶�
rf=InvEuler(R,'ZYX')';
R=Ghuman_bk(1:3,1:3,:); % human �����˶�
R=flipdim(R,3);
rb=InvEuler(R,'ZYX')'; 
for ind=1:3 %�ֱ���������ͼ�ϻ�    
    plot(axhd(ind),rf(ind,:),rf(mod(ind,3)+1,:));
    plot(axhd(ind),rb(ind,:),rb(mod(ind,3)+1,:));
    plot(axhd(ind),rr(ind,:),rr(mod(ind,3)+1,:),'linewidth',2,'color','red');
    xlabel(axhd(ind),lbs{ind});
    ylabel(axhd(ind),lbs{mod(ind,3)+1});
end
fh=figure;  
ah=gca;
set(fh,'Position',[100 100 200 200],'resize','off');
plotv(ah,Vhuman(1:3,:));% human�Ľ��ٶȹ켣��������Ĭ�Ϻ�������[0,1]
set(ah,'FontSize',2);   hold(ah,'on');
plot(ah,linspace(0,1,fmrg(2)-fmrg(1)+1), sqrt(sum(Vrobot(1:3,fmrg(1):fmrg(2)).^2)), 'linewidth',2,'color','red'); % robot�Ľ��ٶȹ켣������һ��
xlabel(ah,'time(s)');
ylabel(ah,'speed(rad/s)');

return

function axhd=FigAxis(row,column)
%����һ������row�к�column�и���ͼ��figure,���趨�������
%������ÿ����ͼ������
figure
set(gcf,'Position',[100 100 450 200],'resize','off');
axhd=zeros(row,column);%��ͼ�ľ��
for indi=1:row
    for indj=1:column
        axhd(indi,indj)=subplot(row,column,column*(indi-1)+indj);
        set(gca,'FontSize',2);
        axis(gca,'equal');
        hold(gca,'on');
    end
end
return

%figure;%ĩ��ƽ���˶��켣
%p=squeeze(Grobot(1:3,4,:)); % robot
%plot3(p(1,:),p(2,:),p(3,:),'linewidth',4,'color','red');hold on
%p=squeeze(Ghuman_fd(1:3,4,:)); % human �����˶�
%plot3(p(1,:),p(2,:),p(3,:)); hold on
%p=squeeze(Ghuman_bk(1:3,4,:)); % human �����˶�
%plot3(p(1,:),p(2,:),p(3,:)); 
%title('Trajectory of hand in reference system');
%hold off
%axis equal; axis tight
%grid on

%figure;%ĩ��ת���˶��켣
%R=Grobot(1:3,1:3,:); % robot
%r=InvEuler(R,'ZYX')';
%plot3(r(1,:),r(2,:),r(3,:),'linewidth',4,'color','red'); hold on
%R=Ghuman_fd(1:3,1:3,:); % human �����˶�
%r=InvEuler(R,'ZYX')';
%plot3(r(1,:),r(2,:),r(3,:)); hold on
%R=Ghuman_bk(1:3,1:3,:); % human �����˶�
%R=flipdim(R,3);
%r=InvEuler(R,'ZYX')'; 
%plot3(r(1,:),r(2,:),r(3,:));
%title('Trajectory of hand in reference system');
%hold off
%axis equal; axis tight
%grid on
