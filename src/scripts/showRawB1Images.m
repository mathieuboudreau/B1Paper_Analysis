close all
clear all
clc

old_dir = cd;

cd('/Users/mathieuboudreau/Work/Analysis_PhDWork/B1Paper_Analysis/data/mazerolle_erin_20131016_152802')

%%
%

[~, clt_da_1] = niak_read_minc('mazerolle_erin_20131016_152802_4_mri.mnc'); 
[~, clt_da_2] = niak_read_minc('mazerolle_erin_20131016_152802_6_mri.mnc'); 

[~, bs_1] = niak_read_minc('mazerolle_erin_20131016_152802_19d1_mri.mnc'); 
[~, bs_2] = niak_read_minc('mazerolle_erin_20131016_152802_21d2_mri.mnc'); 

[~, afi_1] = niak_read_minc('mazerolle_erin_20131016_152802_8d1_mri_es.mnc'); 
[~, afi_2] = niak_read_minc('mazerolle_erin_20131016_152802_9d2_mri_es.mnc'); 

[~, epi_1] = niak_read_minc('mazerolle_erin_20131016_152802_76_mri_resamp.mnc'); 
[~, epi_2] = niak_read_minc('mazerolle_erin_20131016_152802_77_mri_resamp.mnc'); 

[~, mask] = niak_read_minc('brain_mask_es_2x2x5.mnc'); 

%%
%

clt_da_1_masked = imrotate(clt_da_1.*mask,-90);
clt_da_2_masked = imrotate(clt_da_2.*mask,-90);

bs_1_masked = imrotate(bs_1.*mask,-90);
bs_2_masked = imrotate(bs_2.*mask,-90);

afi_1_masked = imrotate(afi_1.*mask,-90);
afi_2_masked = imrotate(afi_2.*mask,-90);

epi_1_masked = imrotate(epi_1.*mask,-90);
epi_2_masked = imrotate(epi_2.*mask,-90);

%%
%

figure(1), imshow(cat(1,clt_da_1_masked./max(max(clt_da_1_masked)),clt_da_2_masked./max(max(clt_da_1_masked)))), axis image % Divide both by same amount, picked the first image max
set(gcf, 'Position', [1 1 1280 1280])

figure(2), imshow(cat(1,(bs_1_masked./max(max(bs_1_masked))+1)/2,(bs_2_masked./max(max(bs_1_masked))+1)/2)), axis image %(+1, /2 to push phase between 0 and 1 instead of -1 and 1, since imshow is bounded to 0 and 1)
set(gcf, 'Position', [1 1 1280 1280])

figure(3), imshow(cat(1,afi_1_masked./max(max(afi_1_masked)),afi_2_masked./max(max(afi_1_masked)))), axis image
set(gcf, 'Position', [1 1 1280 1280])

figure(4), imshow(cat(1,epi_1_masked./max(max(epi_1_masked)),epi_2_masked./max(max(epi_1_masked)))), axis image
set(gcf, 'Position', [1 1 1280 1280])

figure(5), imshow(cat(1,clt_da_1_masked.*0, clt_da_1_masked.*0)), axis image
set(gcf, 'Position', [1 1 1280 1280])

%%
%
cd(old_dir)