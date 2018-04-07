function out=Scale(G0,G1)
%求从G0到G1差别程度的比例系数
P0=G0(1:3,4); P1=G1(1:3,4);%%提取位置
R0=G0(1:3,1:3);R1=G1(1:3,1:3);%%提取姿态
out=norm(P1-P0)/acos(0.5*(trace(R0\R1)-1));%%SE（3）上两点间距离的度量ε2
return 