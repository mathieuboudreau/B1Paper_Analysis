%% B1T1qMT Comparison
%

%% Clear session
%

clear all
clc
close all

%% Data info
%

dataDir = [pwd '/data'];
b1t1FileOptions = {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'gre'};

%% Setup file information
%

subjectID = dirs2cells(dataDir);

s = generateStructB1T1Data(b1t1FileOptions{1}, b1t1FileOptions{2}, b1t1FileOptions{3}, b1t1FileOptions{4});
b1Keys = b1t1FileOptions{3}; % shorthand names of the b1 methods
b1ID = s.b1Files;
t1ID = s.t1Files;

numB1 = size(b1ID,2); % Number of B1 methods compared, e.g. number of curves to be displayed in the hist plots.
numSubjects = size(subjectID,1);

% 
% 
% 
% %% Make directories
% %
% 
% olddir = cd;
% 
% %cd('/Users/mathieuboudreau/Work/Projects/B1smoothing/BlurHistComp/ISMRM/alonso_eva_20131025_141318')
% %cd('/Users/mathieuboudreau/Work/Projects/B1smoothing/BlurHistComp/ISMRM/arseneault_ryan_20131015_140558')
% %cd('/Users/mathieuboudreau/Work/Projects/B1smoothing/BlurHistComp/ISMRM/caissie_jessica_20131015_152703')
% %cd('/Users/mathieuboudreau/Work/Projects/B1smoothing/BlurHistComp/ISMRM/collette_marc_20131024_093735')
% %cd('/Users/mathieuboudreau/Work/Projects/B1smoothing/BlurHistComp/ISMRM/mazerolle_erin_20131016_152802')
% cd('/Users/mathieuboudreau/Work/Projects/B1smoothing/BlurHistComp/ISMRM/stikov_nikola_20131017_113942')
% 
% 
% %% Load study info
% %
% 
% % **Needs to be manually modified for each scans/protocol**
% study_info
% 
% %% Calculate B1 maps
% %
% 
% % Blur
% mkdir b1_blur
% mkdir b1_spline
% 
% system(['mincblur -no_apodize -dim 2 -fwhm 10 b1_whole_brain/b1_clt_tse.mnc b1_blur/b1_clt_tse' ]);
% system(['mincblur -no_apodize -dim 2 -fwhm 10 b1_whole_brain/b1_clt_afi.mnc b1_blur/b1_clt_afi' ]);
% system(['mincblur -no_apodize -dim 2 -fwhm 10 b1_whole_brain/b1_clt_gre_bs_cr_fermi.mnc b1_blur/b1_clt_gre_bs_cr_fermi' ]);
% system(['mincblur -no_apodize -dim 2 -fwhm 10 b1_whole_brain/b1_epseg_da.mnc b1_blur/b1_epseg_da' ]);
% 
% 
% % Spline
% 
% system(['spline_smooth -verbose -distance 60 -lambda 2.5119e-06 -mask t1_whole_brain/t1_clt_vfa_spoil_b1_clt_tse_mask.mnc b1_whole_brain/b1_clt_tse.mnc b1_spline/b1_clt_tse_spline.mnc'])
% system(['spline_smooth -verbose -distance 60 -lambda 2.5119e-06 -mask t1_whole_brain/t1_clt_vfa_spoil_b1_clt_tse_mask.mnc b1_whole_brain/b1_clt_afi.mnc b1_spline/b1_clt_afi_spline.mnc'])
% system(['spline_smooth -verbose -distance 60 -lambda 2.5119e-06 -mask t1_whole_brain/t1_clt_vfa_spoil_b1_clt_tse_mask.mnc b1_whole_brain/b1_clt_gre_bs_cr_fermi.mnc b1_spline/b1_clt_gre_bs_cr_fermi_spline.mnc'])
% system(['spline_smooth -verbose -distance 60 -lambda 2.5119e-06 -mask t1_whole_brain/t1_clt_vfa_spoil_b1_clt_tse_mask.mnc b1_whole_brain/b1_epseg_da.mnc b1_spline/b1_epseg_da_spline.mnc'])
% 
% %%
% %
% 
% [~, blur{1}]=niak_read_minc('b1_blur/b1_clt_tse_blur.mnc');
% [~, blur{2}]=niak_read_minc('b1_blur/b1_clt_afi_blur.mnc');
% [~, blur{3}]=niak_read_minc('b1_blur/b1_clt_gre_bs_cr_fermi_blur.mnc');
% [~, blur{4}]=niak_read_minc('b1_blur/b1_epseg_da_blur.mnc');
% 
% [~, spline{1}]=niak_read_minc('b1_spline/b1_clt_tse_spline.mnc');
% [~, spline{2}]=niak_read_minc('b1_spline/b1_clt_afi_spline.mnc');
% [~, spline{3}]=niak_read_minc('b1_spline/b1_clt_gre_bs_cr_fermi_spline.mnc');
% [~, spline{4}]=niak_read_minc('b1_spline/b1_epseg_da_spline.mnc');
% 
% [~,mask]=niak_read_minc('t1_whole_brain/t1_clt_vfa_spoil_b1_clt_tse_mask.mnc');
% 
% 
% for ii=1:4
%     figure(),imagesc(blur{ii}.*mask),caxis([0.7 1.2])
%     figure(),imagesc(spline{ii}.*mask),caxis([0.7 1.2])
% end
% 
% %% Fit T1 maps
% %
% 
% mkdir t1_blur
% mkdir t1_spline
% 
% % VFA Optimum Spoil Blur
% !rm VFA_3.mnc
% !rm VFA_20.mnc
% fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_blur/b1_clt_afi_blur.mnc', 't1_blur/t1_clt_vfa_spoil_b1_clt_afi_blur', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
% 
% 
% !rm VFA_3.mnc
% !rm VFA_20.mnc
% fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_blur/b1_clt_tse_blur.mnc', 't1_blur/t1_clt_vfa_spoil_b1_clt_tse_blur', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
% 
% !rm VFA_3.mnc
% !rm VFA_20.mnc
% fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_blur/b1_epseg_da_blur.mnc', 't1_blur/t1_clt_vfa_spoil_b1_epseg_da_blur', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
% 
% !rm VFA_3.mnc
% !rm VFA_20.mnc
% fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_blur/b1_clt_gre_bs_cr_fermi_blur.mnc', 't1_blur/t1_clt_vfa_spoil_b1_clt_bs_blur', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
% 
% % VFA Optimum Spoil Spline
% !rm VFA_3.mnc
% !rm VFA_20.mnc
% fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_spline/b1_clt_afi_spline.mnc', 't1_spline/t1_clt_vfa_spoil_b1_clt_afi_spline', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
% 
% !rm VFA_3.mnc
% !rm VFA_20.mnc
% fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_spline/b1_clt_tse_spline.mnc', 't1_spline/t1_clt_vfa_spoil_b1_clt_tse_spline', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
% 
% !rm VFA_3.mnc
% !rm VFA_20.mnc
% fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_spline/b1_epseg_da_spline.mnc', 't1_spline/t1_clt_vfa_spoil_b1_epseg_da_spline', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
% 
% !rm VFA_3.mnc
% !rm VFA_20.mnc
% fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_spline/b1_clt_gre_bs_cr_fermi_spline.mnc', 't1_spline/t1_clt_vfa_spoil_b1_clt_bs_spline', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
% 
