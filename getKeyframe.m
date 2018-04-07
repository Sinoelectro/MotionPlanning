function [Kf,Name]=getKeyframe(folder,filename)
% folder: 包含角度数据的mat文件所在文件夹 eg: 'G:\E\matlab_work\motion analysis data\HUST20110630\C3D data\ChenWenrui\'
% filename: 角度数据的mat文件名 eg: 'tls01.mat'
% Kf: 动作的起始帧和目标到达帧
% Name: 动作的类型 'tls','lear','rear','mouse','head'

% 首先做输入文件夹的合法性检查
indc=find(folder=='\');
subjectName=folder( indc(end-1)+1 : indc(end)-1 );
if ~( strcmp(subjectName,'ChenWenrui')|| strcmp(subjectName,'LianHaitao')|| strcmp(subjectName,'LvMing') )
   error('invalid input'); 
end

% 文件名预处理,去掉后缀名，去掉名中的空格
inddot=find(filename=='.');
indtab=find(filename==' ');
if isempty(indtab) 
    filename=filename(1:inddot-1);
else % 处理文件名为‘top head01.mat’含空格的特殊情况, 同时去掉top
    filename=filename(indtab+1:inddot-1);
end
[ChenWenrui,LianHaitao,LvMing]=mydata();

switch subjectName
    case 'ChenWenrui'
        Kf=getfield(ChenWenrui,filename);
    case 'LianHaitao'
        Kf=getfield(LianHaitao,filename);
    case 'LvMing'
        Kf=getfield(LvMing,filename);
end
Name=filename(1:end-2);%去掉文件名末尾的序号

return


function [ChenWenrui,LianHaitao,LvMing]=mydata()

ChenWenrui=struct;
LianHaitao=struct;
LvMing=struct;

ChenWenrui.tls01=[20,84;150,206;283,339;411,465;533,596];
ChenWenrui.tls02=[19,82;153,209;260,340;416,470;539,601];
ChenWenrui.lear01=[15,76;136,200;267,331;393,457;517,584];
ChenWenrui.lear02=[31,100;161,226;281,355;407,469;527,592];
ChenWenrui.rear01=[10,93;168,246;305,384;443,511;575,644];
ChenWenrui.rear02=[7,86;147,214;278,344;403,470;533,605];
ChenWenrui.mouse01=[14,76;126,205;254,324;387,449;502,571];
ChenWenrui.mouse02=[7,90;158,231;282,360;418,490;550,627];
ChenWenrui.head01=[11,99;174,270;355,452;530,624;701,782];
ChenWenrui.head02=[15,100;160,254;321,414;480,557;626,712];


LianHaitao.tls03=[10,88;164,238;315,394;471,543;617,687];
LianHaitao.tls04=[15,100;175,245;321,393;460,532;605,674];
LianHaitao.lear03=[26,108;181,248;325,393;470,537;611,681];
LianHaitao.lear04=[23,109;167,253;332,396;470,540;615,677];
LianHaitao.rear03=[17,99;162,240;309,380;448,517;580,651];
LianHaitao.rear04=[21,96;155,220;288,356;414,481;543,614];
LianHaitao.mouse03=[19,101;165,247;318,389;452,533;602,677];
LianHaitao.mouse04=[26,105;159,240;311,385;459,527;596,665];
LianHaitao.head03=[21,89;144,223;288,357;412,490;563,628];
LianHaitao.head04=[12,89;158,228;292,363;432,502;569,642];

LvMing.tls01=[15,99;166,234;302,375;438,504;571,646];
LvMing.tls02=[44,115;180,250;318,393;455,527;586,664];
LvMing.lear01=[21,91;163,242;311,387;458,542;613,688];
LvMing.lear02=[22,91;168,243;314,389;457,526;597,665];
LvMing.rear02=[27,113;182,250;325,406;475,553;624,703];
LvMing.rear03=[46,148;228,312;382,460;530,600;669,742];
LvMing.mouse01=[7,90;159,229;295,364;427,492;558,624];
LvMing.mouse02=[22,110;179,248;311,379;442,503;570,641];
LvMing.head02=[18,101;165,241;306,376;440,503;564,635];
LvMing.head03=[21,87;149,221;285,349;423,492;562,630];

return
