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
DEBUG=0;

%% Data info
%

dataDir = [pwd '/data'];
b1t1FileOptions = {'b1_whole_brain/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'gre'};

maskFile = 'brain_mask_es_2x2x5.mnc';

%% Setup file information
%

subjectID = dirs2cells(dataDir);

s = generateStructB1T1Data(b1t1FileOptions{1}, b1t1FileOptions{2}, b1t1FileOptions{3}, b1t1FileOptions{4});
b1Keys = b1t1FileOptions{3}; % shorthand names of the b1 methods
b1ID = s.b1Files;
t1ID = s.t1Files;
mincExtension = '.mnc';

numB1 = size(b1ID,2); % Number of B1 methods compared, e.g. number of curves to be displayed in the hist plots.
numSubjects = size(subjectID,1);

blurDirs = {'b1_gauss'};

%% Setup filter details
%

fwhmVal = 5;

%% Blur maps for each subjects
%

olddir = cd;

for counterSubject = 1:numSubjects
    cd([dataDir '/' subjectID{counterSubject}]);

    for ii = 1:length(blurDirs)
        if(~isdir(blurDirs{ii}))
            mkdir(blurDirs{ii})
        end

        for jj = 1:length(b1ID)
            [b1_hdr{jj},b1{jj}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{jj}]);
        end

        [~,mask] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' maskFile]);
        mask = logical(mask);

        switch blurDirs{ii}
            case 'b1_gauss'
                for jj = 1:length(b1ID)
                    b1Blur{jj} = gaussBlurMasked(b1{jj}, mask, fwhmVal);

                    b1_hdr{jj}.file_name = [dataDir '/' subjectID{counterSubject} '/' blurDirs{ii} b1ID{jj}(length(b1t1FileOptions{1}):end)];
                    niak_write_minc_ss(b1_hdr{jj},b1Blur{jj}.*mask);
                end
        end
    end
end

%% Cleanup
%
% *** TEMP *** Delete data & folders for now during development. Remove
% later.

if(DEBUG==1)
    for counterSubject = 1:numSubjects
        cd([dataDir '/' subjectID{counterSubject}])
        disp(cd)

        for ii = 1:length(blurDirs)
            if(isdir(blurDirs{ii}))
                rmdir(blurDirs{ii},'s')
            end
        end
    end
end

% Return to original folder
cd(olddir)

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
