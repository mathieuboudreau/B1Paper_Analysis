function [] = processVFAT1MapsFromBlurredB1(dataDir,studyFile)
%processVFAT1MapsFromBlurredB1
%   --Arguments--
%   string dataDir: 
%
%   string studyFile: string to location of study_info.m file. Since the
%   working directory is dataDir, if the file is located here, 'study_info'
%   will be sufficient. Otherwise, the full path is recommended
%
%   bool quietFlag: 0 for verbose, 1 for quiet

%% B1T1qMT Comparison
%

%% Make directories
%

olddir = cd(dataDir);

if(~isdir('t1_gauss'))
    mkdir('t1_gauss')
end

if(~isdir('t1_gauss_wm'))
    mkdir('t1_gauss_wm')
end

if(~isdir('b1_gauss_wm'))
    mkdir('b1_gauss_wm')
end

%% Load study info
%

% **Needs to be manually modified for each scans/protocol**
run(studyFile)


%%
%

% GRE

fitDataVFA_es (subjectID, gre_vfaID, 'b1_gauss/b1_clt_afi.mnc', 't1_gauss/t1_gre_vfa_b1_clt_afi', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, gre_vfaID, 'b1_gauss/b1_clt_tse.mnc', 't1_gauss/t1_gre_vfa_b1_clt_tse', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, gre_vfaID, 'b1_gauss/b1_epseg_da.mnc', 't1_gauss/t1_gre_vfa_b1_epseg_da', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, gre_vfaID, 'b1_gauss/b1_clt_gre_bs_cr_fermi.mnc', 't1_gauss/t1_gre_vfa_b1_clt_bs', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 


%% B1 vs T1 statistics
%


%%%%% Apply masks %%%%%

% GRE
system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1_gauss/t1_gre_vfa_b1_clt_afi.mnc t1_gauss/temp.mnc')
system('mv t1_gauss/temp.mnc t1_gauss_wm/t1_gre_vfa_b1_clt_afi.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1_gauss/t1_gre_vfa_b1_clt_tse.mnc t1_gauss/temp.mnc')
system('mv t1_gauss/temp.mnc t1_gauss_wm/t1_gre_vfa_b1_clt_tse.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1_gauss/t1_gre_vfa_b1_epseg_da.mnc t1_gauss/temp.mnc')
system('mv t1_gauss/temp.mnc t1_gauss_wm/t1_gre_vfa_b1_epseg_da.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1_gauss/t1_gre_vfa_b1_clt_bs.mnc t1_gauss/temp.mnc')
system('mv t1_gauss/temp.mnc t1_gauss_wm/t1_gre_vfa_b1_clt_bs.mnc')

%% Make B1 maps and stats
%

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_ll_2x2x5.mnc b1_gauss/b1_clt_tse.mnc b1_gauss/temp.mnc')
system('mv b1_gauss/temp.mnc b1_gauss_wm/b1_clt_tse.mnc')

if(system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_epseg_2x2x5.mnc b1_gauss/b1_epseg_da.mnc b1_gauss/temp.mnc'))
    system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc b1_gauss/b1_epseg_da.mnc b1_gauss/temp.mnc')
end
system('mv b1_gauss/temp.mnc b1_gauss_wm/b1_epseg_da.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc b1_gauss/b1_clt_afi.mnc b1_gauss/temp.mnc')
system('mv b1_gauss/temp.mnc b1_gauss_wm/b1_clt_afi.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_ll_2x2x5.mnc b1_gauss/b1_clt_gre_bs_cr_fermi.mnc b1_gauss/temp.mnc')
system('mv b1_gauss/temp.mnc b1_gauss_wm/b1_clt_gre_bs_cr_fermi.mnc')

%% Return to old dir
%

cd(olddir)

end
