function [ accu_F_U,accu_F_T ] = Func_MEGU( X_L,Y_L,X_U,Y_U,X_T,Y_T,Number_Iter )
%  X_L: the feature of the labeled data, which \in R^N*dim ,N is the number
%  of examples,and dim is dimension of the feature.

%  Y_L: the label of the labeled data, which in \in R^N*C
%  X_U: the feature of the unlabeled data (offline exmple pool)
%  Y_U: the label of the unlabeled data (for  evaluation)
%  X_T:  the feature of the unlabeled data (online exmple pool)
%  Y_T: the label of the unlabeled data (for  evaluation)

%  Number_Iter: the number of iteration.

    
%% 2.����LGC�㷨�����д����������ʼ�Ĵ�������P_trans��Ԥ��ֵF_train,F_T�Լ�����Ӧ�Ĺ�һ����ֵF_train_nom,F_T_nom;
    l=size(X_L,1);%��עѵ����������
    u=size(X_U,1);%δ��ע����ѵ����������
    t=size(X_T,1);%���Լ�������Ŀ
    C=size(Y_L,2);%�����Ŀ
    n=l+u;
    
    X_train=[X_L;X_U];
    Y_train=[Y_L;Y_U];%ѵ������goundTruth
    Set_train_L=1:l;%��¼ѵ�������ѱ��û���ע��������X_train�е�Index����ʼΪ��ע���е�����1:l��
    Set_test_L=[];%��¼�����������ѱ��û���ע��������X_test�е�Index.��ʼΪ��
    Theta=144000;
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
      
   % �������Ҫ�ı���
   clear W sumW isD S Y_unlabel Y_0 X_L Y_L X_U Y_U;
   % ����һ����Ҫ�õı����� 
   % 1.��Ҫ�����ݼ�
   % X_train
   % Y_train ѵ������ground truth ������ʱҪ�õ�
   % X_T
   % Y_T
   % 2. ��ʶ���ݼ��ı��� 
   % Set_train_L ��¼ѵ������ע������ѵ�����е�������
   % Set_test_L ��¼���Լ��б�ѡ�еı�ע�����ڲ��Լ��е�������
   % 3.�м���������Լ��ټ����Լ�ÿ�ֵ�������Ҫ�ı����
   % P_trans ��������������������ʱ
   % F_train ����ѵ������Ԥ��ֵ�����Ǹ�����ʽ�����б�Ҫʱ������F_train_nom������ʽ
   % F_test ���ڲ��Լ���Ԥ��ֵ���Ǹ�����ʽ
   % W_test_train ���Լ�������ѵ�������ݵ�Ȩ�ؾ�����Ҫ��������Լ���Ԥ��ֵ
   %
        
   
   %% 2 ��ʼ��������ѧϰ
    
  %  Number_Iter=10;
    for k=1:Number_Iter
        tic;
        disp(strcat('the Iterate: ',num2str(k)));
       
        %����ѵ������δ��ע�����ṩ���û���ע��ñ�ǩ�����������ء�
        Set_train_U=setdiff(1:n,Set_train_L);
        u_train=length(Set_train_U);
        H_U_exp=zeros(1,u_train);%��¼δ��ע���ݵ�������
        
        for i=1:u_train
          % Hx_exp=0;
           index=Set_train_U(i);
           % ����X_U(index)�������أ�����X_U(index)��yֵ�޷�ȷ����ֻ�ܲ�����ȡ���������صķ�ʽ
           for j=1:C
               % ���㵱��X_U(i)����ٶ�����yֵ=j�����󣬼����ע���ݼ������´������õ���Ԥ��ֵF_train_plus
               F_train_plus=F_train;%ע������ĸ���ֵ��ԭʼ��δ��һ�����ݣ�Ϊ�˱�֤LGC�㷨��һ����
               F_train_plus(:,j)=F_train(:,j)+P_trans(:,index);%���������㷨�����Է���ֻ��Ҫ���µ�j�У�ֵΪP_trans�ĵ�i��
               F_train_plus_nom=F_train_plus./repmat(sum(F_train_plus,2),[1 size(F_train_plus,2)]);%�Ը��µ�Ԥ��ֵ���й�һ��
              % ���Ƕ�X_train��δ��ע���ݵ�������
                 Hx_exp_j_train=calculateEntropy(F_train_plus_nom);
               % ���Ƕ�X_test��δ��ע���ݵ������� 
 %                F_test_plus=evaluate_testSet_new( W_test_train,Y_train,F_train_plus_nom, Set_train_L);
 %               Hx_exp_j_test=calculateEntropy(F_test_plus);
                 Hx_exp_j=Hx_exp_j_train;
                % ��ÿһ���ܵ����������H_U_exp��
                 H_U_exp(i)=H_U_exp(i)+F_train_nom(index,j)*Hx_exp_j;    
           
           end
        
        end
        
   
         %������Լ���δ��ע�����ṩ���û���ע��ñ�ǩ�����������ء�
       
         Set_test_U=setdiff(1:t,Set_test_L);
         u_test=length(Set_test_U);
         H_T_exp=zeros(1,u_test);%��¼δ��ע���ݵ�������
          for i=1:u_test

              index=Set_test_U(i);
               x=X_T(index,:);%�ҵ��ò������ݵ�����
              % Ѱ������ѵ�����еĴ�������¼Ȩ�ز���
              K_UL=5;%��������Ŀ��
              
              DIST=distMat(X_train,x);%����x��X_train֮��ľ���
              [~, IDX] = sort(DIST, 1);%����
              i_KUL=IDX(1:K_UL);%ѡ����������K_UL������Ϊ�����㣻
              W_ul=exp(-DIST(i_KUL)/Theta);%������Ȩ�أ�
              W_ul_nom=W_ul./sum(W_ul);%�������һ��Ȩ�أ�


                % ����x�������أ�����x��yֵ�޷�ȷ����ֻ�ܲ�����ȡ���������صķ�ʽ
               for j=1:C
               % ���㵱��x����ٶ�����yֵ=j�����󣬼����ע���ݼ������´������õ���Ԥ��ֵF_train_plus
                 F_train_plus=F_train;%ע������ĸ���ֵ��ԭʼ��δ��һ�����ݣ�Ϊ�˱�֤LGC�㷨��һ����
                 
                 for ii=1:K_UL
                    F_train_plus(:,j)=F_train(:,j)+W_ul_nom(ii)*P_trans(:,i_KUL(ii));%���������㷨�����Է���ֻ��Ҫ���µ�j�У�ֵΪP_trans�ĵ�i��
                 end
                 F_train_plus_nom=F_train_plus./repmat(sum(F_train_plus,2),[1 size(F_train_plus,2)]);%�Ը��µ�Ԥ��ֵ���й�һ��
              % ���Ƕ�X_train��δ��ע���ݵ�������
                 Hx_exp_j_train=calculateEntropy(F_train_plus_nom);
               % ���Ƕ�X_test��δ��ע���ݵ������� 
%                  F_test_plus=evaluate_testSet_new( W_test_train,Y_train,F_train_plus_nom, Set_train_L);
%                  Hx_exp_j_test=calculateEntropy(F_test_plus);
                 Hx_exp_j=Hx_exp_j_train;
                % ��ÿһ���ܵ����������H_T_exp��
                 H_T_exp(i)=H_T_exp(i)+F_test(index,j)*Hx_exp_j;       
               end
              
          end
          [min_H_U,index_U]=min(H_U_exp);
          [min_H_T,index_T]=min(H_T_exp);
          
          % ѡ�����ݸ��˱�ע����ñ�ǩ����뵽��עѵ������������һ�����ݼ�
        
          if(min_H_T<min_H_U)
             % �Ӳ��Լ��м��뵽��עѵ������
              example=Set_test_U(index_T);
              Set_test_L=[Set_test_L,example];%��ʶ�������ݼ��е��ѱ�ע����
             
              % ����Ԥ��ֵ��
              x=X_T(example,:);%�ҵ��ò������ݵ�����
               DIST=distMat(X_train,x);%����x��X_train֮��ľ���
              [~, IDX] = sort(DIST, 1);%����
              i_KUL=IDX(1:K_UL);%ѡ����������K_UL������Ϊ�����㣻
              W_ul=exp(-DIST(i_KUL)/Theta);%������Ȩ�أ�
              W_ul_nom=W_ul./sum(W_ul);%�������һ��Ȩ�أ�
              
              y=Y_T(example,:);
              j=find(y==1);
              disp(strcat('the active label data is from test set: ',num2str(example),'--the class is:',num2str(j)));
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
             example=Set_train_U(index_U);
             Set_train_L=[Set_train_L,example];%��ʶѵ�����е��ѱ�ע����
             
       
             y=Y_train(example,:);
             j=find(y==1);
             disp(strcat('the active label data is from training set: ',num2str(example),'--the class is:',num2str(j)));
             F_train(:,j)=F_train(:,j)+P_trans(:,example);%���������㷨�����Է���ֻ��Ҫ���µ�j�У�ֵΪP_trans�ĵ�i��
             F_train_nom=F_train./repmat(sum(F_train,2),[1 size(F_train,2)]);%�Ը��µ�Ԥ��ֵ���й�һ��
             F_test = evaluate_testSet_new( W_test_train,Y_train,F_train_nom, Set_train_L);
  
             % ��ѵ�����Ͳ��Լ��Ϸֱ��������顣
             accu_F_U(k+1)=evaluate_accuracy(Y_train,F_train,Set_train_L);
             accu_F_T(k+1)=evaluate_accuracy(Y_T,F_test,Set_test_L);
             disp(strcat('the accuracy on training data: ',num2str(accu_F_U(k+1)),...
                 '--the accuracy on test data:',num2str(accu_F_T(k+1))));
          
          end
          
          toc;
    end
    
end

