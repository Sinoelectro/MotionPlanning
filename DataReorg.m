function out=DataReorg()
% 对人体的自然运动数据进行整理，相同的动作放在一个结构体里面（动作的次数用NaN分隔），一列表示一组关节角对应一个姿态
% 动作的正向过程与反向回归在结构体内的两个变量表示
% out是一个整体的大结构体，里面包含具体结构体tls,lear,mouse,head,rear 不同动作的角度（弧度）数据对应的结构体

folder={'E:\project\Motion Planning\C3D data\ChenWenrui\',...
         'E:\project\Motion Planning\C3D data\LianHaitao\',...
         'E:\project\Motion Planning\C3D data\LvMing\'};
     
%定义存储数据
tls.forward=[];   tls.backward=[];
lear.forward=[];  lear.backward=[];
mouse.forward=[]; mouse.backward=[];
head.forward=[];  head.backward=[];
rear.forward=[];  rear.backward=[];

for indx=1:length(folder)
    filesinfo=what(folder{indx});% 找出指定目录下所有matlab可识别的文件
    listing=filesinfo.mat;% 从所有文件中筛选出mat格式的文件名
    for ind=1:length(listing)
        fddata=[];
        bkdata=[];
        filename=listing{ind};
        tmp=load([folder{indx},filename]);%载入数据文件data给tmp存放(某人连续做的某个动作)
        tmp=(tmp.data/180*pi)';% 数据单位转换：度-》弧度
        
        [ks,acttype]=getKeyframe(folder{indx},filename);% 同一动作多次（5次）执行的关键起始帧编号
        for ii=1:size(ks,1)
            forward=ks(ii,1):ks(ii,2);%正向运动的帧号
            if ii+1>size(ks,1)
                backward=ks(ii,2)+1:max(size(tmp));%反向运动的帧号
            else
                backward=ks(ii,2)+1:ks(ii+1,1)-1;
            end
            fddata=[fddata,tmp(:,forward),NaN*ones(min(size(tmp)),1)];%每次动作之间用NaN隔开
            bkdata=[bkdata,tmp(:,backward),NaN*ones(min(size(tmp)),1)];
        end
        switch acttype
            case 'tls'
                tls.forward=[tls.forward,fddata];
                tls.backward=[tls.backward,bkdata];
            case 'lear'
                lear.forward=[lear.forward,fddata];
                lear.backward=[lear.backward,bkdata];
            case 'mouse'
                mouse.forward=[mouse.forward,fddata];
                mouse.backward=[mouse.backward,bkdata];
            case 'head'
                head.forward=[head.forward,fddata];
                head.backward=[head.backward,bkdata];
            case 'rear'
                rear.forward=[rear.forward,fddata];
                rear.backward=[rear.backward,bkdata];    
        end
    end
end

out.tls=tls;
out.lear=lear;
out.mouse=mouse;
out.head=head;
out.rear=rear;

return