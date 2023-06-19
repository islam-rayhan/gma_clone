% for i=1:103
% im(:,:,i)=(paviaU(:,:,i)-min(min(paviaU(:,:,i))))./(max(max(paviaU(:,:,i)))-min(min(paviaU(:,:,i))));
% end
% 
% for i=1:103
% for j=1:103
% b = corrcoef(im(:,:,i), im(:,:,j));
% corr_matrix(i)=b(1,2);
% corr_matrix2(i,j)=b(1,2);
% end
% end

% HSI = paviaU;
% m = 610;
% n = 340;
% c = 103;
clc;clear all
%=====================================================
% load 'PaviaU.mat';
% HSI = paviaU;

% load 'Houston.mat';
% HSI = img;

% load 'Indian_pines_corrected.mat';
% HSI = indian_pines_corrected;

load 'Salinas_corrected.mat';
HSI = salinas_corrected;

% load 'Botswana.mat';
% HSI = Botswana;

% load 'KSC.mat';
% HSI = KSC;
%=====================================================

HSI_size = size(HSI);
m = HSI_size(1);
n = HSI_size(2);
c = HSI_size(3);

% �𲨶�չƽ
im2 = double(zeros(c,m*n));
for i=1:c
    im2(i,:) = reshape(HSI(:,:,i),1,m*n);
end

% �𲨶ι�һ��
for i=1:c
    im2(i,:)=(im2(i,:)-min(im2(i,:)))./(max(im2(i,:))-min(im2(i,:)));
end

% �����ڽ����ε�һά���������
im2_corr1 = ones(c-1,1);
for i=1:c-1
   b = corrcoef(im2(i,:), im2(i+1,:));
   im2_corr1(i)=b(1,2);
end
% figure(1)
% plot(1:c-1,im2_corr1)

im2_corr1_mean = mean(im2_corr1);
% im2_corr0=[im2_corr1(1);im2_corr1];
% im2_corr1=[im2_corr1;im2_corr1(end)];
% im2_corr_diff=im2_corr1-im2_corr0;

localMinPoints = ones();  % ��ʼ�ֲ���Сֵ��
%=======================MinDiff=================================
MinDiff =0.0025; % 0.005; %0.01 0.002; %ƽ������Բ���������MinDiff������ָ��
%=======================MinDiff=================================
critical_value = im2_corr1_mean*0.05; %0.05; %����Բ���С��critical_value��ֱ����Ϊ�ָ��ָ��
for i=5:c-6 %c-2
    %�ҳ����еľֲ���Сֵ�㣬����ʼ�ָ��
   if(im2_corr1(i)<im2_corr1(i-1))
       if(im2_corr1(i)<im2_corr1(i+1))
           left_average = (im2_corr1(i-4)+im2_corr1(i-3)+im2_corr1(i-2)+im2_corr1(i-1))/4;
           right_average = (im2_corr1(i+1)+im2_corr1(i+2)+im2_corr1(i+3)+im2_corr1(i+4))/4;
           if left_average-im2_corr1(i)>MinDiff && right_average-im2_corr1(i)>MinDiff % ����Բ���������MinDiff������ָ��
               localMinPoints = [localMinPoints i];
%            elseif im2_corr1(i)<=critical_value
%                localMinPoints = [localMinPoints i];
           end
       end
   end
end
localMinPoints = [localMinPoints c]; %����ĩβ
% localMinPoints
localMinPoints
flag = 0; % ��ֹ����
%=======================setCorrValue=================================
setCorrValue = 0.995;  %����Դ���setCorrValue�����Ǻϲ�����
localMinPoints_size = size(localMinPoints); %[1,22] һ��22����   1...103
numGroups = localMinPoints_size(2)-1; % ���α��ָ�Ϊ������ 21
numGroups
% ������ƽ�������������Ժϲ�
%=======================Min_interval=================================
Min_interval = uint8(c*0.1); %������С�����������С��Min_interval�����Ǻϲ�����

while(flag==0)
    %�������м�ֵ��ָ�������εĲ���ƽ��ֵ,������ͼ��
    newIm = ones(numGroups,m*n);  % ���յõ�numGroups=21����ͼ��
    for i=1:numGroups
        length = localMinPoints(i+1)-localMinPoints(i);
        if i~=numGroups
            if length>10 %10  % ���ֶ��ڲ�����̫�ֻ࣬ȡ���м��50%�Ĳ��μ���ƽ��ֵ
                newIm(i,:) = sum(im2(localMinPoints(i)+(length*0.25):localMinPoints(i)+(length*0.75)-1,:))./(length*0.5); %ȡ���м��50%�Ĳ��μ���ƽ��ֵ
                
            else
                newIm(i,:) = sum(im2(localMinPoints(i):localMinPoints(i+1)-1,:))./(localMinPoints(i+1)-localMinPoints(i));
            end
        else %���һ���������
            if length>10 %10  % ���ֶ��ڲ�����̫�ֻ࣬ȡ���м��50%�Ĳ��μ���ƽ��ֵ
                newIm(i,:) = sum(im2(localMinPoints(i)+(length*0.25):localMinPoints(i)+(length*0.75)-1,:))./(length*0.5); %ȡ���м��50%�Ĳ��μ���ƽ��ֵ
            else
                newIm(i,:) = sum(im2(localMinPoints(i):localMinPoints(i+1),:))./(localMinPoints(i+1)-localMinPoints(i)+1);
            end
        end
    end
    %���㲨��ƽ��ֵ֮��������ϵ��
    newIm_corr = zeros(numGroups-1,1);
    for i=1:(numGroups-1)
        b = corrcoef(newIm(i,:), newIm(i+1,:));
        newIm_corr(i)=b(1,2);    % ���յõ�numGroups-1=20�������ϵ��
    end

    for i=1:(numGroups-1)
            %��������ϵ������setCorrValue����ɾ���÷ָ��
        if newIm_corr(i)>=setCorrValue && im2_corr1(i)>critical_value  %�������Դ����ٽ�ֵ
            localMinPoints(i+1)=[];        %��ɾ���÷ָ��
            numGroups = numGroups-1;
            break;
        end
             %������̫С����ɾ���÷ָ��
        if localMinPoints(1,i+1)-localMinPoints(1,i)<=Min_interval && localMinPoints(1,i+2)-localMinPoints(1,i+1)<=Min_interval && im2_corr1(i)>critical_value
            if (newIm_corr(i) >= newIm_corr(i+1)) %�Ķ���ǰһ�θ����
                localMinPoints(i+1)=[];        %��ɾ���÷ָ��
                numGroups = numGroups-1;
            elseif (newIm_corr(i+1) >= newIm_corr(i) && i~=numGroups-1  && im2_corr1(i)>critical_value)
                localMinPoints(i+2)=[];        %��ɾ���÷ָ��
                numGroups = numGroups-1;
            end
            break;
        end
        
        if (localMinPoints(1,i+1)-localMinPoints(1,i)<Min_interval && im2_corr1(i)>critical_value)  % ����÷ָ��ǰ������С
            localMinPoints(i+1)=[];        %��ɾ���÷ָ��
            numGroups = numGroups-1;
            break;
        end
        
        if (localMinPoints(1,i+2)-localMinPoints(1,i+1)<Min_interval && i~=numGroups-1 && im2_corr1(i)>critical_value)  % ����÷ָ���������С
            localMinPoints(i+2)=[];        %��ɾ������ķָ��
            numGroups = numGroups-1;
            break;
        end
        
        if i ==(numGroups-1)
            flag=1; %����Ѿ����������е�i����ʱi�����һ����=(numGroups-1)��˵�����������ϵ������setCorrValue�ĵ㶼��ɾ�����ͽ�flag��Ϊ1
        end
        if numGroups == 1 || max(size(localMinPoints))==2
            flag=1; %������鵽���ֻʣ��һ����
        end
    end
end
numGroups
localMinPoints

figure(1)
x = 1:c;       %[1��204]
y = im2_corr1';  %[1��203]
y = [y y(1,c-1)];
plot(x,y,'b','LineWidth',1.5);
% grid on
xlabel('Band','FontSize', 12) 
ylabel('���������','FontSize', 16)
localMinPoints = reshape(localMinPoints,1,[]);  %[1��6]
% xp = find(x==localMinPoints);
% yp = find(y==localMinPoints);

% text(localMinPoints,y(localMinPoints),num2str([localMinPoints;y(localMinPoints)].','(%.0f,%.2f)'),'color','r')
text(localMinPoints,y(localMinPoints),'x','color','r')

% text(x(localMinPoints),y(localMinPoints),[num2str(x(localMinPoints)),num2str(y(localMinPoints))]','(%.2f,%.2f)')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%
% % ���̫С�ϲ�
% numGroups = numGroups; %�ϲ�ǰ����ʱ����Ҫ��numGroups����     7
% % localMinPoints [1,58,73,86,89,97,100,103;] 8
% % newIm_corr
% % [0.804622488054651;0.511265078320287;0.873453345585097;0.998455682480242;0.997545249208789;0.997187627420801;0.998016938918438;]
% % 7
% 
% Min_interval = 20;
% delet_points = [];
% for i=2:numGroups  % 2:7
%     % ����÷ָ��ǰ�������鶼��С��ͨ���Ƚ������ϵ����������ϲ�������Դ��һ��
%     if localMinPoints(1,i)-localMinPoints(1,i-1)<=Min_interval && localMinPoints(1,i+1)-localMinPoints(1,i)<=Min_interval
%         if (newIm_corr(i-1) >= newIm_corr(i)) %�Ķ���ǰһ�θ����
% %             localMinPoints(i)=[];        %��ɾ���÷ָ��
% %             numGroups = numGroups-1;
%             delet_points = [delet_points i];
% %             i=i-1;
% %             break;
%         elseif (newIm_corr(i-1)<newIm_corr(i))
% %             localMinPoints(i+1)=[];        %��ɾ������ķָ��
% %             numGroups = numGroups-1;
%             delet_points = [delet_points i+1];
% %             i=i-1;
% %             break;
%         end
%         
%     elseif (localMinPoints(1,i)-localMinPoints(1,i-1)<Min_interval)  % ����÷ָ��ǰ������С
% %         localMinPoints(i)=[];        %��ɾ���÷ָ��
% %         numGroups = numGroups-1;
%         delet_points = [delet_points i];
% %         i=i-1;
% %         break;
%         
%     elseif (localMinPoints(1,i+1)-localMinPoints(1,i)<Min_interval)  % ����÷ָ���������С
% %         localMinPoints(i+1)=[];        %��ɾ������ķָ��
% %         numGroups = numGroups-1;
%         delet_points = [delet_points i+1];
% %         i=i-1;
% %         break;
%     end
% end
% 
% % ����ȫ�����εĶ�ά����Ծ���
% im2_corr2 = ones(103,103);
% for i=1:102
%    b = corrcoef(im2(i,:), im2(i+1,:));
%    im2_corr1(i)=b(1,2);
% end
% 
% 
% for i=1:103
%     for j=1:103      
%         a =corrcoef(im2(i,:), im2(j,:)); 
%         im2_corr2(i,j) =a(1,2);
%     end
% end
% 
% figure(1)
% plot(1:102,im2_corr1)
% figure(2)
% imshow(uint8(im2_corr2*255))
% figure(3)
% imagesc(im2_corr2)



