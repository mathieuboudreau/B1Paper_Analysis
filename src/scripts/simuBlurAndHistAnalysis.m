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

%% Blur sinB1Map to remove artefact
%

blurredSinB1Map = imgaussfilt(sinB1Map, 10);

figIndex = figIndex+1; figure(figIndex), imagesc(blurredSinB1Map), axis image, set(gca, 'XTick', [], 'YTick', []), colormap(jet), title('Blurred Sin B_1 Map', 'FontSize', 24, 'FontName', 'TimesNewRoman', 'FontWeight', 'normal')


%% Create a b1map with a systemic bias
%

biasB1Map = b1Map_ref + 0.1;

figIndex = figIndex+1; figure(figIndex), imagesc(biasB1Map), axis image, set(gca, 'XTick', [], 'YTick', []), colormap(jet), title('Bias B_1 Map', 'FontSize', 24, 'FontName', 'TimesNewRoman', 'FontWeight', 'normal'), caxis([0.5 1.5])

%% Blur biasB1Map to remove artefact
%

blurredBiasB1Map = imgaussfilt(biasB1Map, 10);

figIndex = figIndex+1; figure(figIndex), imagesc(blurredBiasB1Map), axis image, set(gca, 'XTick', [], 'YTick', []), colormap(jet), title('Blurred Bias B_1 Map', 'FontSize', 24, 'FontName', 'TimesNewRoman', 'FontWeight', 'normal')


%% Calculate correlations relative to reference
%

corr_sinB1 = round(corr(b1Map_ref(:), sinB1Map(:)),3);
corr_blurredSinB1 = round(corr(b1Map_ref(:), blurredSinB1Map(:)),3);

corr_biasB1Map = round(corr(b1Map_ref(:), biasB1Map(:)),3);
corr_blurredBiasB1Map = round(corr(b1Map_ref(:), blurredBiasB1Map(:)),3);

%% Plot histograms
%

figIndex = figIndex+1; figure(figIndex), hist(b1Map_ref(:), 25), axis([0.25 1.75 0 1000]), axis square, title('Ref. B_1 Map', 'FontSize', 24, 'FontName', 'TimesNewRoman', 'FontWeight', 'normal')
figIndex = figIndex+1; figure(figIndex), hist(sinB1Map(:), 25), axis([0.25 1.75 0 1000]), axis square, title('Sin B_1 Map', 'FontSize', 24, 'FontName', 'TimesNewRoman', 'FontWeight', 'normal'), text(1.1,900,['Pearson Correlation = ' mat2str(corr_sinB1)], 'FontSize', 12)

figIndex = figIndex+1; figure(figIndex), hist(biasB1Map(:), 25), axis([0.25 1.75 0 1000]), axis square, title('Bias B_1 Map', 'FontSize', 24, 'FontName', 'TimesNewRoman', 'FontWeight', 'normal'), text(1.1,900, ['Pearson Correlation = ' mat2str(corr_biasB1Map)], 'FontSize', 12)
figIndex = figIndex+1; figure(figIndex), hist(blurredBiasB1Map(:), 25), axis([0.25 1.75 0 1000]), axis square, title('Blurred Bias B_1 Map', 'FontSize', 24, 'FontName', 'TimesNewRoman', 'FontWeight', 'normal'), text(1.1,900, ['Pearson Correlation = ' mat2str(corr_blurredBiasB1Map)], 'FontSize', 12)
