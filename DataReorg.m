function out=DataReorg()
% ���������Ȼ�˶����ݽ���������ͬ�Ķ�������һ���ṹ�����棨�����Ĵ�����NaN�ָ�����һ�б�ʾһ��ؽڽǶ�Ӧһ����̬
% ��������������뷴��ع��ڽṹ���ڵ�����������ʾ
% out��һ������Ĵ�ṹ�壬�����������ṹ��tls,lear,mouse,head,rear ��ͬ�����ĽǶȣ����ȣ����ݶ�Ӧ�Ľṹ��

folder={'E:\project\Motion Planning\C3D data\ChenWenrui\',...
         'E:\project\Motion Planning\C3D data\LianHaitao\',...
         'E:\project\Motion Planning\C3D data\LvMing\'};
     
%����洢����
tls.forward=[];   tls.backward=[];
lear.forward=[];  lear.backward=[];
mouse.forward=[]; mouse.backward=[];
head.forward=[];  head.backward=[];
rear.forward=[];  rear.backward=[];

for indx=1:length(folder)
    filesinfo=what(folder{indx});% �ҳ�ָ��Ŀ¼������matlab��ʶ����ļ�
    listing=filesinfo.mat;% �������ļ���ɸѡ��mat��ʽ���ļ���
    for ind=1:length(listing)
        fddata=[];
        bkdata=[];
        filename=listing{ind};
        tmp=load([folder{indx},filename]);%���������ļ�data��tmp���(ĳ����������ĳ������)
        tmp=(tmp.data/180*pi)';% ���ݵ�λת������-������
        
        [ks,acttype]=getKeyframe(folder{indx},filename);% ͬһ������Σ�5�Σ�ִ�еĹؼ���ʼ֡���
        for ii=1:size(ks,1)
            forward=ks(ii,1):ks(ii,2);%�����˶���֡��
            if ii+1>size(ks,1)
                backward=ks(ii,2)+1:max(size(tmp));%�����˶���֡��
            else
                backward=ks(ii,2)+1:ks(ii+1,1)-1;
            end
            fddata=[fddata,tmp(:,forward),NaN*ones(min(size(tmp)),1)];%ÿ�ζ���֮����NaN����
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