function [ accu_F_U,accu_F_T ] = Func_BvSB( X_L,Y_L,X_U,Y_U,X_T,Y_T,Number_Iter )

%  X_L: the feature of the labeled data, which \in R^N*dim ,N is the number
%  of examples,and dim is dimension of the feature.

%  Y_L: the label of the labeled data, which in \in R^N*C
%  X_U: the feature of the unlabeled data (offline exmple pool)
%  Y_U: the label of the unlabeled data (for  evaluation)
%  X_T:  the feature of the unlabeled data (online exmple pool)
%  Y_T: the label of the unlabeled data (for  evaluation)

%  Number_Iter: the number of iteration.

       l=size(X_L,1);%��עѵ����������
    u=size(X_U,1);%δ��ע����ѵ����������
    t=size(X_T,1);%���Լ�������Ŀ
    C=size(Y_L,2);%�����Ŀ
    n=l+u;
    
    X_train=[X_L;X_U];
    Y_train=[Y_L;Y_U];%ѵ������goundTruth
    Set_train_L=1:l;%��¼ѵ�������ѱ��û���ע��������X_train�е�Index����ʼΪ��ע���е�����1:l��
    Set_test_L=[];%��¼�����������ѱ��û���ע��������X_test�е�Index.��ʼΪ��
    Theta=144400;
    Alpha=0.89;
    
    disp('start to excute LGC...');
    W=getAffinityMatrix_diag_0(X_train,Theta);%����affinity����
    sumW=sum(W);
    isD=diag(sumW.^(-1/2));
    S=isD*W*isD;
    P_trans=(1-Alpha)*inv((eye(n)-Alpha*S));%���촫������
% ����F_train    
    Y_unlabel=zeros(u,C);%������unlabeled������Y����0��
    Y_0=[Y_L;Y_unlabel];
    F_train=P_trans*Y_0;% ѵ����������LGC�㷨��õ���Ԥ��ֵ

  % ��ѵ�����е�δ��ע���ݽ�������
    accu_F_U(1)=evaluate_accuracy(Y_train,F_train,Set_train_L);
     disp(strcat('the intional accuracy on training set is: ',num2str(accu_F_U(1))));
    % ����F_test,�������������
     F_train_nom=F_train./repmat(sum(F_train,2),[1 size(F_train,2)]);%��Ԥ��ֵ���й�һ��
     
     DIST=distMat(X_T,X_train); 
     W_test_train=exp(-DIST/Theta);%����Test����ѵ������Ȩ�ؾ������ڼ�����Լ���Ԥ��ֵ��
    
     F_test = evaluate_testSet_new( W_test_train,Y_train,F_train_nom, Set_train_L);
     accu_F_T(1)=evaluate_accuracy(Y_T,F_test,Set_test_L);
     
      disp(strcat('the intional accuracy on test set is: ',num2str(accu_F_T(1))));
   %% ��ʼ��������ѧϰ
     epsilo=1e-300;%Ϊ�˷�ֹ����0*log0�������

    for k=1:Number_Iter
     %   Hx_min=1e300;
        K_UL=5;
        disp(strcat('the Iterate: ',num2str(k)));
        %���ѡ��һ���㣻
        Set_train_U=setdiff(1:n,Set_train_L);
        Set_test_U=setdiff(1:t,Set_test_L);
        u_train=length(Set_train_U);
        u_test=length(Set_test_U);
        
        Hx_min_train=1e300;
        for i=1:u_train
            F_i=F_train_nom(i,:)+epsilo;
            H_i= calculateBvSB( F_i);%��������ֵ��ߵ�����Ĳ�
            if (H_i<Hx_min_train)
               Hx_min_train=H_i;
               index_train=i;
            end
        end
     
       Hx_min_test=1e300;
        for i=1:u_test
            F_i=F_test(i,:)+epsilo;
            H_i= calculateBvSB( F_i);%��������ֵ��ߵ�����Ĳ�
            if (H_i<Hx_min_test)
               Hx_min_test=H_i;
               index_test=i;
            end
        end 
          % ѡ�����ݸ��˱�ע����ñ�ǩ����뵽��עѵ������������һ�����ݼ�
          if(Hx_min_test<Hx_min_train)
             % �Ӳ��Լ��м��뵽��עѵ������
              example=Set_test_U(index_test);
              Set_test_L=[Set_test_L,example];%��ʶ�������ݼ��е��ѱ�ע����
              disp(strcat('the active label data is from test set: ',num2str(example)));
              % ����Ԥ��ֵ��
              x=X_T(example,:);%�ҵ��ò������ݵ�����
               DIST=distMat(X_train,x);%����x��X_train֮��ľ���
              [~, IDX] = sort(DIST, 1);%����
              i_KUL=IDX(1:K_UL);%ѡ����������K_UL������Ϊ�����㣻
              W_ul=exp(-DIST(i_KUL)/Theta);%������Ȩ�أ�
              W_ul_nom=W_ul./sum(W_ul);%�������һ��Ȩ�أ�
              
              y=Y_T(example,:);
              j=find(y==1);
              
              for ii=1:K_UL
                    F_train(:,j)=F_train(:,j)+W_ul_nom(ii)*P_trans(:,i_KUL(ii));%���������㷨�����Է���ֻ��Ҫ���µ�j�У�ֵΪP_trans�ĵ�i��
               end
              F_train_nom=F_train./repmat(sum(F_train,2),[1 size(F_train,2)]);%�Ը��µ�Ԥ��ֵ���й�һ��
              F_test = evaluate_testSet_new( W_test_train,Y_train,F_train_nom, Set_train_L); 
              % ��ѵ�����Ͳ��Լ��Ϸֱ��������顣
               accu_F_U(k+1)=evaluate_accuracy(Y_train,F_train,Set_train_L);
               accu_F_T(k+1)=evaluate_accuracy(Y_T,F_test,Set_test_L);
             disp(strcat('the accuracy on training data: ',num2str(accu_F_U(k+1)),...
                 '--the accuracy on test data:',num2str(accu_F_T(k+1))));
          else
              % ��ѵ������ѡ��
             example=Set_train_U(index_train);
             Set_train_L=[Set_train_L,example];%��ʶѵ�����е��ѱ�ע����
             
             disp(strcat('the active label data is from training set: ',num2str(example)));
             y=Y_train(example,:);
             j=find(y==1);
             F_train(:,j)=F_train(:,j)+P_trans(:,example);%���������㷨�����Է���ֻ��Ҫ���µ�j�У�ֵΪP_trans�ĵ�i��
             F_train_nom=F_train./repmat(sum(F_train,2),[1 size(F_train,2)]);%�Ը��µ�Ԥ��ֵ���й�һ��
                    % ��ѵ�����Ͳ��Լ��Ϸֱ��������顣
               F_test = evaluate_testSet_new( W_test_train,Y_train,F_train_nom, Set_train_L); 
              % ��ѵ�����Ͳ��Լ��Ϸֱ��������顣
               accu_F_U(k+1)=evaluate_accuracy(Y_train,F_train,Set_train_L);
               accu_F_T(k+1)=evaluate_accuracy(Y_T,F_test,Set_test_L);
             disp(strcat('the accuracy on training data: ',num2str(accu_F_U(k+1)),...
                 '--the accuracy on test data:',num2str(accu_F_T(k+1))));
          
          end
          
    end
    
    
    


end

