function [ F_T] = evaluate_testSet_new( W_test_train,Y_train,F_train_nom, Set_train_L)
%EVALUATE_TESTSET Summary of this function goes here
%   Detailed explanation goes here
    C=size(Y_train,2);
     F_train_L1=F_train_nom;%�����������Ҫ�����ڶԲ��Լ��е����ݽ���Ԥ��ʱ���̶���ע���ݼ��ı�ǩֵ��
     F_train_L1(Set_train_L,:)=Y_train(Set_train_L,:);
     
     W_sum=sum(W_test_train,2); 
     f_t=W_test_train*F_train_L1;
     F_T=f_t./(repmat(W_sum,[1 C]));   

end

