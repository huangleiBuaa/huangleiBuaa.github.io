function [ H ] = calculateEntropy( F_train )
%%CALCULATEENTROPY Summary of this function goes here
%   Detailed explanation goes here
%����ǰ��֤F_trainΪ��һ�ĸ���ֵ��

% ����F��һ��N*C�ľ�������ÿ��Ϊÿһ���������ڸ���ĸ���ֵ����ÿ�����Ϊ1�����Էſ����ƣ��������Ԫ�ش���0��
 
%   ��F_train���н��й�һ��������ʹ��Ϊ����ֵ��
%   F=F_train./repmat(sum(F_train,2),[1 size(F_train,2)]);%�Ը��µ�Ԥ��ֵ���й�һ��
%  [N,C]=size(F);
    epsilo=1e-300;%Ϊ�˷�ֹ����0*log0�������


    F_ep=F_train+epsilo;
    temp=F_ep.*log2(F_ep);
    H=-sum(sum(temp));
end

