function [ Risk ] = calculateRisk( F_train )
%CALCULATERISK Summary of this function goes here
%   Detailed explanation goes here
% �÷������ڼ�����������ϵ����F_train��n*c���󣬴���n�����ݣ�ÿ�д�������ݵĸ��ʷֲ�
 % �������ÿ�����ݵķ���֮�͡�
    [n,~]=size(F_train);
    Risk=0;
%     for i=1:n
%        temp=1-max(F_train(i,:));
%        Risk=Risk+temp;     
%     end
    %Ч�ʸ��ߵĽⷨ
    F_trans=F_train';
    temp=1-max(F_trans);
    Risk=sum(temp);
    
end

