function out=InvEuler(T,option)
%T:齐次变换矩阵序列
%option：‘XYZ’，‘ZXY’，‘YXZ’，‘ZYX’，‘YXY’，‘XZY’
if ~(strcmp(option,'XYZ') || strcmp(option,'ZXY') || strcmp(option,'YXZ') ||...
   strcmp(option,'ZYX') || strcmp(option,'YXYR') || strcmp(option,'YXYL') ||...
   strcmp(option,'XZY') || strcmp(option,'YXZ0') || strcmp(option,'YZX')) 
  error('invalidated Euler option !');
end

r11=T(1,1,:);r12=T(1,2,:);r13=T(1,3,:);
r21=T(2,1,:);r22=T(2,2,:);r23=T(2,3,:);
r31=T(3,1,:);r32=T(3,2,:);r33=T(3,3,:);
switch option
    case 'XYZ'
        alpha=KillBreak( atan2(-r12,r11) );
        beta=KillBreak( atan2(-r23,r33) );
        gama=KillBreak( atan2(r13,-sin(beta).*r23+cos(beta).*r33) );
        
        out=[squeeze(beta),squeeze(gama),squeeze(alpha)];
    case 'ZXY'
        alpha=KillBreak( atan2(-r12,r22) ); 
        gama=KillBreak( atan2(-r31,r33) );
        beta=KillBreak( atan2(r32,-sin(gama).*r31+cos(gama).*r33) );
        
        out=[squeeze(alpha),squeeze(beta),squeeze(gama)];
    case 'YXZ'
        gama=KillBreak( atan2(r13,r33) );
        alpha=KillBreak( atan2(r21,r22) );
        beta=KillBreak( atan2(-r23,sin(gama).*r13+cos(gama).*r33) );   
        
        out=[squeeze(gama),squeeze(beta),squeeze(alpha)];
    case 'YXZ0'  %最小估计法求锁骨旋转角
        gama=KillBreak( atan2(-r31,r11) );
        beta=KillBreak( atan2(-r23,r22) );
        
        out=[squeeze(gama),squeeze(beta)];
    case 'ZYX'
        alpha=KillBreak( atan2(r21,r11) );
        beta=KillBreak( atan2(r32,r33) );
        gama=KillBreak( atan2(-r31,sin(beta).*r32+cos(beta).*r33) );        
        
        out=[squeeze(alpha),squeeze(gama),squeeze(beta)];
    case 'YXYR'
        gama=KillBreak( atan2(-r12,-r32) );%虽然ISB的beta为负值（2005）,适用于右手
        gamp=KillBreak( atan2(-r21,r23) );
        beta=KillBreak( atan2(sin(gama).*r12+cos(gama).*r32,r22) );        
        
        out=[squeeze(gama),squeeze(beta),squeeze(gamp)];
    case 'YXYL'
        gama=KillBreak( atan2(r12,r32) );%但（complete 3D kinematics...2009)的结果为正值，适用于左手
        gamp=KillBreak( atan2(r21,-r23) );
        beta=KillBreak( atan2(sin(gama).*r12+cos(gama).*r32,r22) );        
        
        out=[squeeze(gama),squeeze(beta),squeeze(gamp)];
    case 'XZY'
        gama=KillBreak( atan2(r13,r11) );
        beta=KillBreak( atan2(r32,r22) );
        alpha=KillBreak( atan2(-r12,cos(beta).*r22+sin(beta).*r32) );
        
        out=[squeeze(beta),squeeze(alpha),squeeze(gama)];
    case 'YZX'
        gama=KillBreak( atan2(-r23,r22) );
        alpha=KillBreak( atan2(-r31,r11) );
        beta=KillBreak( atan2(r21.*cos(gama),r22) );
        
        out=[squeeze(alpha),squeeze(beta),squeeze(gama)];
end



