function [] = mainB1T1qMT(dataDir,studyFile)
%mainB1T1qMT Full processing for B1T1 processing
%   --Arguments--
%   string dataDir: 
%
%   string studyFile: string to location of study_info.m file. Since the
%   working directory is dataDir, if the file is located here, 'study_info'
%   will be sufficient. Otherwise, the full path is recommended

%% B1T1qMT Comparison
%

%% Make directories
%

olddir = cd(dataDir);

mkdir t1
mkdir b1
mkdir mask
mkdir struct


%% Load study info
%

% **Needs to be manually modified for each scans/protocol**
run(studyFile)

%% Get single slice images from 3D data
%

resample_all_3d_to_singleslice;

%% Resample 4D images into workable 3D images
%

% bic_tse
system(['mincreshape -clobber -dimrange time=0,0 ' subjectID '_' num2str(bic_tseID) '_mri.mnc ' subjectID num2str(bic_tseID) '_mri_1.mnc'])
system(['mincreshape -clobber -dimrange time=1,0 ' subjectID '_' num2str(bic_tseID) '_mri.mnc ' subjectID num2str(bic_tseID) '_mri_2.mnc'])

%% Get Brain and WM mask
%

% Convert structural scan too nii
system(['perl mnc2nii_opt.pl ', subjectID,'_',num2str(structID),'_mri_reg.mnc',' raw_brain.nii'])

% Extract brain
system('bet raw_brain brain -f 0.5 -g 0 -m')

% Gunzip some files
system('gunzip brain.nii.gz')
system('gunzip brain_mask.nii.gz')

% Convert back to minc
system('nii2mnc brain.nii brain.mnc')
system('nii2mnc brain_mask.nii brain_mask.mnc')

% Get PE %
[~,vfa_xlength]=system(['mincinfo -dimlength xspace ',subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ']);
[~,vfa_ylength]=system(['mincinfo -dimlength yspace ',subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ']);
% ***Assumes that the PE direction is L->R (xspace)
pe_perc = str2double(vfa_xlength)/str2double(vfa_ylength);

% Resample registered structural scan so that slices match the size of the
% VFA slices (and all other extracted slice scans), but the X,Y resolution
% stays the same as the original structural measurement

% Brain
system(['mincresample -clob -like ', subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ', '-step ', num2str(str2double(struct_xstep)), ' ', num2str(str2double(struct_ystep)), ' ', num2str(str2double(vfa_zstep)), ' -nelements ', num2str(str2double(struct_xlength)*pe_perc), ' ', num2str(str2double(struct_ylength)), ' ', num2str(str2double(vfa_zlength)), ' brain.mnc', ' brain_resamp.mnc']);
system(['mincreshape -clobber -dimrange zspace=16,1', ' brain_resamp.mnc ', 'brain_resamp_es.mnc']) % "es" stands for extracted slice

% Brain Mask
system(['mincresample -clob -like ', subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ', '-step ', num2str(str2double(struct_xstep)), ' ', num2str(str2double(struct_ystep)), ' ', num2str(str2double(vfa_zstep)), ' -nelements ', num2str(str2double(struct_xlength)*pe_perc), ' ', num2str(str2double(struct_ylength)), ' ', num2str(str2double(vfa_zlength)), ' brain_mask.mnc', ' brain_mask_resamp.mnc']);
system(['mincreshape -clobber -dimrange zspace=16,1', ' brain_mask_resamp.mnc ', 'brain_mask_resamp_es.mnc']) % "es" stands for extracted slice

% Generate tal files using this command: standard_pipeline.pl tal_tissue_classify 1 alonso_eva_20131025_141318_75_mri.mnc --prefix . --model_dir /opt/minc/share/icbm152_model_09c --model mni_icbm152_t1_tal_nlin_sym_09c -beastlib /opt/minc/share/beast-library-1.1
% On my current latop (Mac OS 10.11), the pipeline aborts near the end, but
% after the required files are generated. The pipeline takes about an hour.
system(['mincresample -invert_transformation -transformation tal_tissue_classify/1/tal/tal_xfm_tal_tissue_classify_1_t1w.xfm -like ' subjectID '_' num2str(structID) '_mri.mnc' ' tal_tissue_classify/1/tal_cls/tal_clean_tal_tissue_classify_1.mnc brain_classified.mnc'])

%% Calculate B1 maps
%

% AFI

fitDataAFI_es (subjectID, clt_afiID, 'b1_clt_afi.mnc', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 

% CLT Double Echo

fitDataDAB1(subjectID, clt_tseID, 'b1_clt_tse.mnc', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc'], 60)

% EP_SEG Double Echo

fitDataDAB1(subjectID, epseg_daID, 'b1_epseg_da_full.mnc', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc'], 60)

system(['mincresample -clobber -like ' subjectID, '_', num2str(clt_afiID(1)), 'd1_mri_es.mnc b1_epseg_da_full.mnc b1_epseg_da.mnc'])


% BIC Double Echo

do_ratio_b1_single([subjectID '_' num2str(bic_tseID) '_mri.mnc'], 33, 'b1_bic_tse.mnc')

% Bloch Siegert

fitDataBSB1([subjectID '_' num2str(mb_clt_gre_bs_cr_fermiID(1)) 'd1_mri.mnc'], [subjectID '_' num2str(mb_clt_gre_bs_cr_fermiID(2)) 'd2_mri.mnc'], 500, 0.008, 'fermi', 'b1_clt_gre_bs_cr_fermi.mnc')
fitDataBSB1([subjectID '_' num2str(mb_gre_bsID(1)) 'd1_mri.mnc'], [subjectID '_' num2str(mb_gre_bsID(2)) 'd2_mri.mnc'], 500, 0.008, 'fermi', 'b1_mb_gre_bs_fermi.mnc')
fitDataBSB1([subjectID '_' num2str(mb_clt_gre_bs_crushID(1)) 'd1_mri.mnc'], [subjectID '_' num2str(mb_clt_gre_bs_crushID(2)) 'd2_mri.mnc'], 500, 0.008, 'gauss', 'b1_clt_gre_bs_cr_gauss.mnc')
fitDataBSB1([subjectID '_' num2str(mb_gre_bs_gaussID(1)) 'd1_mri.mnc'], [subjectID '_' num2str(mb_gre_bs_gaussID(2)) 'd2_mri.mnc'], 500, 0.008, 'gauss', 'b1_mb_gre_bs_gauss.mnc')


%% Fit T1 maps
%

% GRE

fitDataVFA_es (subjectID, gre_vfaID, 'b1_clt_afi.mnc', 't1_gre_vfa_b1_clt_afi', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, gre_vfaID, 'b1_clt_tse.mnc', 't1_gre_vfa_b1_clt_tse', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, gre_vfaID, 'b1_epseg_da.mnc', 't1_gre_vfa_b1_epseg_da', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, gre_vfaID, 'b1_clt_gre_bs_cr_fermi.mnc', 't1_gre_vfa_b1_clt_bs', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 


% VFA Default Spoil

fitDataVFA_es (subjectID, clt_vfaID, 'b1_clt_afi.mnc', 't1_clt_vfa_b1_clt_afi', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, clt_vfaID, 'b1_clt_tse.mnc', 't1_clt_vfa_b1_clt_tse', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, clt_vfaID, 'b1_epseg_da.mnc', 't1_clt_vfa_b1_epseg_da', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, clt_vfaID, 'b1_clt_gre_bs_cr_fermi.mnc', 't1_clt_vfa_b1_clt_bs', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 

% VFA Optimum Spoil

fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_clt_afi.mnc', 't1_clt_vfa_spoil_b1_clt_afi', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_clt_tse.mnc', 't1_clt_vfa_spoil_b1_clt_tse', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_epseg_da.mnc', 't1_clt_vfa_spoil_b1_epseg_da', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 
fitDataVFA_es (subjectID, clt_vfa_spoilID, 'b1_clt_gre_bs_cr_fermi.mnc', 't1_clt_vfa_spoil_b1_clt_bs', [subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) 

% IR

getDataMag_niak(subjectID,clt_tse_irID)
mainScan_mb

load T1FitRD-NLS-PR_data.mat
study_info
IR_hdr=niak_read_hdr_minc([subjectID '_' num2str(clt_tse_irID(1)) '_mri.mnc']);
IR_hdr.file_name='t1_clt_tse_ir.mnc';
niak_write_minc_ss(IR_hdr,imrotate(squeeze(ll_T1(:,:,:,1)),90)./1000);

% LL

fitData_LL_T1_SignFlip(subjectID, cd, ep_segID(1), 't1_ep_seg_b1_clt_afi.mnc', 'mask.mnc')

%% Move files into organized folders
%

if(system('mv t1_* t1/')||system('mv b1_* b1/')||system('mv *_mask* mask/'))
   error('Error: Unix command failed')
end

system('cp -r t1/ t1_whole_brain/')
system('cp -r b1/ b1_whole_brain/')

%% B1 vs T1 statistics
%

% Mask out WM

% SS and ES have start positions slice thickness appart, a single slice vs
% 3D bug?

%%%%%% Get masks %%%%%%

% For IR
maskMajorityVoting('t1/t1_clt_tse_ir.mnc', 'brain_classified.mnc',3,'brain_classified_ir');
system('minccalc -expression ''A[0] > 75.1 ? 1 : 0'' brain_classified_ir_wm_perc.mnc mask/brain_wm_mask_resamp_ir_2x2x5.mnc')


% Extracted slices from 3D
maskMajorityVoting('t1/t1_clt_vfa_b1_clt_afi.mnc', 'brain_classified.mnc',3,'brain_classified_afi');
system('minccalc -expression ''A[0] > 75.1 ? 1 : 0'' brain_classified_afi_wm_perc.mnc mask/brain_wm_mask_resamp_es_2x2x5.mnc')


% For LL
maskMajorityVoting('t1/t1_ep_seg_b1_clt_afi.mnc', 'brain_classified.mnc',3,'brain_classified_ll');
system('minccalc -expression ''A[0] > 75.1 ? 1 : 0'' brain_classified_ll_wm_perc.mnc mask/brain_wm_mask_resamp_ll_2x2x5.mnc')

% For EPSEG
maskMajorityVoting('b1/b1_epseg_da.mnc', 'brain_classified.mnc',3,'brain_classified_epseg');
system('minccalc -expression ''A[0] > 75.1 ? 1 : 0'' brain_classified_epseg_wm_perc.mnc mask/brain_wm_mask_resamp_epseg_2x2x5.mnc')


%%%%% Apply masks %%%%%

% IR
system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_ir_2x2x5.mnc t1/t1_clt_tse_ir.mnc t1/temp.mnc')
system('rm t1/t1_clt_tse_ir.mnc')
system('mv t1/temp.mnc t1/t1_clt_tse_ir.mnc')

% LL
system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_ll_2x2x5.mnc t1/t1_ep_seg_b1_clt_afi.mnc t1/temp.mnc')
system('rm t1/t1_ep_seg_b1_clt_afi.mnc')
system('mv t1/temp.mnc t1/t1_ep_seg_b1_clt_afi.mnc')

% GRE
system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1/t1_gre_vfa_b1_clt_afi.mnc t1/temp.mnc')
system('rm t1/t1_gre_vfa_b1_clt_afi.mnc')
system('mv t1/temp.mnc t1/t1_gre_vfa_b1_clt_afi.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1/t1_gre_vfa_b1_clt_tse.mnc t1/temp.mnc')
system('rm t1/t1_gre_vfa_b1_clt_tse.mnc')
system('mv t1/temp.mnc t1/t1_gre_vfa_b1_clt_tse.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1/t1_gre_vfa_b1_epseg_da.mnc t1/temp.mnc')
system('rm t1/t1_gre_vfa_b1_epseg_da.mnc')
system('mv t1/temp.mnc t1/t1_gre_vfa_b1_epseg_da.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1/t1_gre_vfa_b1_clt_bs.mnc t1/temp.mnc')
system('rm t1/t1_gre_vfa_b1_clt_bs.mnc')
system('mv t1/temp.mnc t1/t1_gre_vfa_b1_clt_bs.mnc')

% VFA - optimum spoil
system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1/t1_clt_vfa_spoil_b1_clt_afi.mnc t1/temp.mnc')
system('rm t1/t1_clt_vfa_spoil_b1_clt_afi.mnc')
system('mv t1/temp.mnc t1/t1_clt_vfa_spoil_b1_clt_afi.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1/t1_clt_vfa_spoil_b1_clt_tse.mnc t1/temp.mnc')
system('rm t1/t1_clt_vfa_spoil_b1_clt_tse.mnc')
system('mv t1/temp.mnc t1/t1_clt_vfa_spoil_b1_clt_tse.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1/t1_clt_vfa_spoil_b1_epseg_da.mnc t1/temp.mnc')
system('rm t1/t1_clt_vfa_spoil_b1_epseg_da.mnc')
system('mv t1/temp.mnc t1/t1_clt_vfa_spoil_b1_epseg_da.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc t1/t1_clt_vfa_spoil_b1_clt_bs.mnc t1/temp.mnc')
system('rm t1/t1_clt_vfa_spoil_b1_clt_bs.mnc')
system('mv t1/temp.mnc t1/t1_clt_vfa_spoil_b1_clt_bs.mnc')


%% Make B1 maps and stats
%

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_ll_2x2x5.mnc b1/b1_clt_tse.mnc b1/temp.mnc')
system('mv b1/temp.mnc b1/b1_clt_tse.mnc')


system('mincresample -nearest_neighbour -like b1/b1_epseg_da.mnc mask/brain_wm_mask_resamp_epseg_2x2x5.mnc mask/temp.mnc')
system('mv mask/temp.mnc mask/brain_wm_mask_resamp_epseg_2x2x5.mnc')
system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_epseg_2x2x5.mnc b1/b1_epseg_da.mnc b1/temp.mnc')
system('mv b1/temp.mnc b1/b1_epseg_da.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc b1/b1_clt_afi.mnc b1/temp.mnc')
system('mv b1/temp.mnc b1/b1_clt_afi.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_ll_2x2x5.mnc b1/b1_clt_gre_bs_cr_fermi.mnc b1/temp.mnc')
system('mv b1/temp.mnc b1/b1_clt_gre_bs_cr_fermi.mnc')


%% Return to old dir
%

cd(olddir)

end
