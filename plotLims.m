function plotLims(Humerus,SimpleLimb,Q,Ps,spts)
% Ps:肩关节中心坐标
%Ps=ToColumnVector(Human.Ps);
for ind=1:length(spts)
    pnum=spts(ind);
    Ge=fkine(Humerus,Q(1:3,pnum));
    Gw=fkine(SimpleLimb,Q(1:4,pnum));
    Pe=Ge(1:3,end);    
    Pw=Gw(1:3,end);
    uL=[Ps,Pe];
    fL=[Pe,Pw];
    plot3(uL(1,:),uL(2,:),uL(3,:),'LineWidth',2.0,'Color','blue');hold on
    plot3(fL(1,:),fL(2,:),fL(3,:),'LineWidth',2.0,'Color','black');hold on
end
hold off
return
