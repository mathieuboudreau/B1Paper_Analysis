%% Figure 2, B1 paper
% Script for on the fly figure reproducibility
clear all
close all
clc

[statsStructB1, statsStructT1] = linregressB1T1([pwd '/data'], {'b1_gauss_wm/', 't1_gauss_wm/', {'clt_da', 'bs', 'afi', 'epi'}, 'gre'})

% | qMRI Metric |   Stats Metric   |  Ref. DA  |   BS   |   AFI   |  EPI-DA  |
% |             |   Pearson Corr    -----------
% |      B1     |      Slope        -----------
% |             |     Intercept     -----------
%    -------------------------------------------------------------------------
% |             |   Pearson Corr    -----------
% |      T1     |      Slope        -----------
% |             |     Intercept     -----------

statsTable = zeros(6,3);

for ii = 1:3
    statsTable(1,ii) = statsStructB1{ii}.pearsonCorr
    statsTable(2,ii) = statsStructB1{ii}.slope
    statsTable(3,ii) = statsStructB1{ii}.intercept
end

for ii = 1:3
    statsTable(4,ii) = statsStructT1{ii}.pearsonCorr
    statsTable(5,ii) = statsStructT1{ii}.slope
    statsTable(6,ii) = statsStructT1{ii}.intercept
end
