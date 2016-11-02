%% Figure 2, B1 paper
% Script for on the fly figure reproducibility
clear all
close all
clc

histB1T1([pwd '/data'], {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi', 'nominal'}, 'gre'}, {[0.5 1.5],[0.5 1.5]})


histB1T1([pwd '/data'], {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'gre'}, {[0.5 1.5],[0.5 1.5]})

figHandles = findobj('Type','figure');

figsToRemove = [1, 3, 4];

for ii=length(figHandles):-1:1
    if( any(figHandles(ii).Number == figsToRemove) )
        close(figHandles(ii).Number)
        figHandles(ii) = [];
    else
        axesLineWidth    = 4;
        axesFontSize     = 26;

        fontName         = 'Times New Roman';
        set(figHandles(ii).CurrentAxes,'XLabel',[],'YLabel',[]);
        set(figHandles(ii).CurrentAxes,'Title',[]);
        axis square
        figHandles(ii).Position = [100, 100, 600, 600];

        figHandles(ii).CurrentAxes.Box        = 'on';
        figHandles(ii).CurrentAxes.LineWidth  = axesLineWidth;
        figHandles(ii).CurrentAxes.FontSize   = axesFontSize;
        figHandles(ii).CurrentAxes.FontWeight = 'bold';

        legend boxoff
    end
end
