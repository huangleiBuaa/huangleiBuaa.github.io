function [ value ] = calculateBvSB( f )
%CALCULATEBVSB Summary of this function goes here
%   Detailed explanation goes here
%   ����f��һ��CԪ������C��ֵΪ�����
%   ���valueΪf��ǰ�������ֵ�ò�ֵ��
    [v,~]=sort(f,'descend');
    value=v(1)-v(2);
end

