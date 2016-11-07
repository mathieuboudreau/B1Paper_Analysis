%% B1T1qMT Comparison
%

%% Clear session
%

clear all
clc
close all

%% Debug flag
%

% If DEBUG=1, b1_blur and b1_spline folders will be removed at the end for all subjects.
DEBUG=1;

%% Data info
%

dataDir = [pwd '/data'];
b1t1FileOptions = {'b1_whole_brain/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'gre'};

%% Setup file information
%

subjectIDs = dirs2cells(dataDir);

s = generateStructB1T1Data(b1t1FileOptions{1}, b1t1FileOptions{2}, b1t1FileOptions{3}, b1t1FileOptions{4});
b1Keys = b1t1FileOptions{3}; % shorthand names of the b1 methods
b1ID = s.b1Files;
t1ID = s.t1Files;

numB1 = size(b1ID,2); % Number of B1 methods compared, e.g. number of curves to be displayed in the hist plots.
numSubjects = size(subjectIDs,1);

blurDirs = {'b1_blur', 'b1_spline'};

%% Blur maps for each subjects
%

olddir = cd;

for counterSubject = 1:numSubjects
    cd([dataDir '/' subjectIDs{counterSubject}])
    disp(cd);

    % Load study indices for all measurements for this subject
    study_info

    for ii = 1:length(blurDirs)
        if(~isdir(blurDirs{ii}))
            mkdir(blurDirs{ii})
        end
    end

end

%% Cleanup
%
% *** TEMP *** Delete data & folders for now during development. Remove
% later.

if(DEBUG==1)
    for counterSubject = 1:numSubjects
        cd([dataDir '/' subjectIDs{counterSubject}])
        disp(cd);

        for ii = 1:length(blurDirs)
            if(~isdir(blurDirs{ii}))
                mkdir(blurDirs{ii})
            end
        end
    end
end

% Return to original folder
cd(olddir)


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
