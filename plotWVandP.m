function outV=plotWVandP(FullLimb,Qrobot,fmrg,Qhuman_fd,Qhuman_bk,stp)
% 将在物体坐标系中表示的速度表示到惯性坐标系下来描述，并且绘制惯性系下面的曲线图
% fmrg: 从生成的Qrobot轨迹中选取合适的区间，用来表现速度轨迹的特征
% Qhuman 中间含有NaN向量，用以隔开多条运动轨迹，末尾也有NaN列向量

rows=size(Qrobot,1);%关节个数
dQrobot=zeros(size(Qrobot));
dQhuman=zeros(size(Qhuman_fd));
for ind=1:rows
    dQrobot(ind,:)=diff7(Qrobot(ind,:),stp);
    dQhuman(ind,:)=mydiff7(Qhuman_fd(ind,:),stp);
end

Vrobot=zeros(6,size(Qrobot,2));
for ind=1:size(Qrobot,2) %计算机器人末端速度
    Vrobot(:,ind)=bjacob(FullLimb,Qrobot(:,ind))*dQrobot(:,ind);
end
Vrobot=[Vrobot(4:6,:);Vrobot(1:3,:)];%角速度在上，线速度在下

Vhuman=zeros(6,size(Qhuman_fd,2));
for ind=1:size(Qhuman_fd,2) %计算人手末端速度
    if all(isnan(Qhuman_fd(:,ind)))
        Vhuman(:,ind)=NaN*ones(6,1);
    else
        Vhuman(:,ind)=bjacob(FullLimb,Qhuman_fd(:,ind))*dQhuman(:,ind);
    end
end
Vhuman=[Vhuman(4:6,:);Vhuman(1:3,:)];%角速度在上，线速度在下

Grobot=fkine(FullLimb,Qrobot);
Ghuman_fd=fkine(FullLimb,Qhuman_fd);
Ghuman_bk=fkine(FullLimb,Qhuman_bk);

lbs={'X(m)','Y(m)','Z(m)'};
axhd=FigAxis(1,3);%末端平移运动轨迹以及平移运动速率
pr=squeeze(Grobot(1:3,4,:)); % robot
pf=squeeze(Ghuman_fd(1:3,4,:)); % human 正向运动
pb=squeeze(Ghuman_bk(1:3,4,:)); % human 反向运动
for ind=1:3 %分别在三个子图上画    
    plot(axhd(ind),pf(ind,:),pf(mod(ind,3)+1,:));
    plot(axhd(ind),pb(ind,:),pb(mod(ind,3)+1,:));
    plot(axhd(ind),pr(ind,:),pr(mod(ind,3)+1,:),'linewidth',2,'color','red');
    xlabel(axhd(ind),lbs{ind});
    ylabel(axhd(ind),lbs{mod(ind,3)+1});
end
fh=figure; 
ah=gca;
set(fh,'Position',[100 100 200 200],'resize','off');
plotv(ah,Vhuman(4:6,:));% human的线速度轨迹，多条，默认横轴区间[0,1]
set(ah,'FontSize',2);   hold(ah,'on');
plot(ah,linspace(0,1,fmrg(2)-fmrg(1)+1), sqrt(sum(Vrobot(4:6,fmrg(1):fmrg(2)).^2)), 'linewidth',2,'color','red'); % robot的线速度轨迹，仅仅一条
xlabel(ah,'time(s)');
ylabel(ah,'speed(m/s)');


lbs={'Z(rad)','Y(rad)','X(rad)'};
axhd=FigAxis(1,3);%末端转动运动轨迹
R=Grobot(1:3,1:3,:); % robot
rr=InvEuler(R,'ZYX')';
R=Ghuman_fd(1:3,1:3,:); % human 正向运动
rf=InvEuler(R,'ZYX')';
R=Ghuman_bk(1:3,1:3,:); % human 反向运动
R=flipdim(R,3);
rb=InvEuler(R,'ZYX')'; 
for ind=1:3 %分别在三个子图上画    
    plot(axhd(ind),rf(ind,:),rf(mod(ind,3)+1,:));
    plot(axhd(ind),rb(ind,:),rb(mod(ind,3)+1,:));
    plot(axhd(ind),rr(ind,:),rr(mod(ind,3)+1,:),'linewidth',2,'color','red');
    xlabel(axhd(ind),lbs{ind});
    ylabel(axhd(ind),lbs{mod(ind,3)+1});
end
fh=figure;  
ah=gca;
set(fh,'Position',[100 100 200 200],'resize','off');
plotv(ah,Vhuman(1:3,:));% human的角速度轨迹，多条，默认横轴区间[0,1]
set(ah,'FontSize',2);   hold(ah,'on');
plot(ah,linspace(0,1,fmrg(2)-fmrg(1)+1), sqrt(sum(Vrobot(1:3,fmrg(1):fmrg(2)).^2)), 'linewidth',2,'color','red'); % robot的角速度轨迹，仅仅一条
xlabel(ah,'time(s)');
ylabel(ah,'speed(rad/s)');

return

function axhd=FigAxis(row,column)
%生成一个含有row行和column列个子图的figure,并设定相关属性
%并返回每个子图的轴句柄
figure
set(gcf,'Position',[100 100 450 200],'resize','off');
axhd=zeros(row,column);%子图的句柄
for indi=1:row
    for indj=1:column
        axhd(indi,indj)=subplot(row,column,column*(indi-1)+indj);
        set(gca,'FontSize',2);
        axis(gca,'equal');
        hold(gca,'on');
    end
end
return

%figure;%末端平移运动轨迹
%p=squeeze(Grobot(1:3,4,:)); % robot
%plot3(p(1,:),p(2,:),p(3,:),'linewidth',4,'color','red');hold on
%p=squeeze(Ghuman_fd(1:3,4,:)); % human 正向运动
%plot3(p(1,:),p(2,:),p(3,:)); hold on
%p=squeeze(Ghuman_bk(1:3,4,:)); % human 反向运动
%plot3(p(1,:),p(2,:),p(3,:)); 
%title('Trajectory of hand in reference system');
%hold off
%axis equal; axis tight
%grid on

%figure;%末端转动运动轨迹
%R=Grobot(1:3,1:3,:); % robot
%r=InvEuler(R,'ZYX')';
%plot3(r(1,:),r(2,:),r(3,:),'linewidth',4,'color','red'); hold on
%R=Ghuman_fd(1:3,1:3,:); % human 正向运动
%r=InvEuler(R,'ZYX')';
%plot3(r(1,:),r(2,:),r(3,:)); hold on
%R=Ghuman_bk(1:3,1:3,:); % human 反向运动
%R=flipdim(R,3);
%r=InvEuler(R,'ZYX')'; 
%plot3(r(1,:),r(2,:),r(3,:));
%title('Trajectory of hand in reference system');
%hold off
%axis equal; axis tight
%grid on
