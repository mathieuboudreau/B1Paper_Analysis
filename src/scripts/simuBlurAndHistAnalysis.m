%% simuBlurAndHistAnalysis
% Exploratory analysis of to explore why histograms and correlations were 
% used for the paper analysis
%

%% Initial setup
%

clear all
close all
clc

%% Globals
%

figIndex = 0;
imDims = [100, 100];
diagionalRotationAngle = 90;
b1MapRescaleFactor = 0.5;

sinB1MapAmpl = 0.2;
sinB1MapFreq = 1;
%% Generate ideal "Ref" B1 map with diagonal gradient
%

[Xgrad, Ygrad] = meshgrid(1:imDims(1),1:imDims(2));

diagionalGrad = Xgrad+Ygrad;

b1map_tmp = imrotate(diagionalGrad, diagionalRotationAngle); % Rotate to get prefered diagonal orientation, only a visual preference.

b1Map_ref = b1map_tmp./max(b1map_tmp(:))+b1MapRescaleFactor;

figIndex = figIndex+1; figure(figIndex), imagesc(b1Map_ref), axis image, set(gca, 'XTick', [], 'YTick', []), colormap(jet), title('Ref. B_1 Map', 'FontSize', 24, 'FontName', 'TimesNewRoman', 'FontWeight', 'normal')

% Cleanup variables that are of no use anymore
clear b1map_tmp diagionalGrad

%% Create a b1map with sinusoid superimpose to simulate a regular imprecision or artefact
%

sinB1Map = b1Map_ref + sinB1MapAmpl * sin(sinB1MapFreq * Xgrad);

figIndex = figIndex+1; figure(figIndex), imagesc(sinB1Map), axis image, set(gca, 'XTick', [], 'YTick', []), colormap(jet), title('Sin B_1 Map', 'FontSize', 24, 'FontName', 'TimesNewRoman', 'FontWeight', 'normal')
