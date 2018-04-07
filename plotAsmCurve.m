function plotAsmCurve(outG,ObjectShape,spts)%,Nscal
%%spts 要画图的帧编号  数组

head=ObjectShape.head;
body=ObjectShape.body;
hand=ObjectShape.hand;
thumb=ObjectShape.thumb;

figure
plot3(squeeze(outG(1,end,:)),squeeze(outG(2,end,:)),squeeze(outG(3,end,:)),'linewidth',1)
axis equal
grid on
hold on

plotObsObj(head);hold on
plotObsObj(body);hold on
%plotObsObj(hand);hold on

plotHandSnap(outG,hand,spts,'hand');hold on%绘制连续捕捉
plotHandSnap(outG,thumb,spts,'thumb');%绘制连续捕捉
axis equal
axis tight
hold off
return


