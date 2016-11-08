%% Figure 2, B1 paper
% Script for on the fly figure reproducibility
clear all
close all
clc

[xB1, yFreqB1, xT1, yFreqT1] = histB1T1([pwd '/data'], {'b1_gauss_wm/', 't1_gauss_wm/', {'clt_da', 'bs', 'afi', 'epi'}, 'gre'}, {[0.5 1.5],[0.5 1.5]});


figHandles = findobj('Type','figure');

figsToRemove = [1];

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

%% Get modes
%

b1Mode{1} = {'clt_da', xB1{1}((max(yFreqB1{1})==yFreqB1{1}))};
b1Mode{2} = {'bs', xB1{2}((max(yFreqB1{2})==yFreqB1{2}))};
b1Mode{3} = {'afi', xB1{3}((max(yFreqB1{3})==yFreqB1{3}))};
b1Mode{4} = {'epi_da', xB1{4}((max(yFreqB1{4})==yFreqB1{4}))};

for ii = 1:4
   disp('B1')
   disp(b1Mode{ii}(1))
   disp(b1Mode{ii}(2))
   disp((cell2mat(b1Mode{ii}(2))-cell2mat(b1Mode{1}(2)))./cell2mat(b1Mode{1}(2))*100)
   b1ModeTable(ii) = (cell2mat(b1Mode{ii}(2))-cell2mat(b1Mode{1}(2)))./cell2mat(b1Mode{1}(2))*100;
end


t1Mode{1} = {'clt_da', xT1{1}((max(yFreqT1{1})==yFreqT1{1}))};
t1Mode{2} = {'bs', xT1{2}((max(yFreqT1{2})==yFreqT1{2}))};
t1Mode{3} = {'afi', xT1{3}((max(yFreqT1{3})==yFreqT1{3}))};
t1Mode{4} = {'epi_da', xT1{4}((max(yFreqT1{4})==yFreqT1{4}))};

for ii = 1:4
   disp('T1')
   disp(t1Mode{ii}(1))
   disp(t1Mode{ii}(2))
   disp((cell2mat(t1Mode{ii}(2))-cell2mat(t1Mode{1}(2)))./cell2mat(t1Mode{1}(2))*100)
   t1ModeTable(ii) = (cell2mat(t1Mode{ii}(2))-cell2mat(t1Mode{1}(2)))./cell2mat(t1Mode{1}(2))*100;
end

disp(b1ModeTable)
disp(t1ModeTable)