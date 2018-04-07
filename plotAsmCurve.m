function plotAsmCurve(outG,ObjectShape,spts)%,Nscal
%%spts Ҫ��ͼ��֡���  ����

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

plotHandSnap(outG,hand,spts,'hand');hold on%����������׽
plotHandSnap(outG,thumb,spts,'thumb');%����������׽
axis equal
axis tight
hold off
return


