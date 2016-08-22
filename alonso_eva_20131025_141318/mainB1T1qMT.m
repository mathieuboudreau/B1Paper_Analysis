%% B1T1qMT Comparison
%

%% Clear session
%

clear all
clc
close all

%% Make directories
%

olddir = cd;

mkdir t1
mkdir b1
mkdir mask
mkdir struct


%% Load study info
%

% **Needs to be manually modified for each scans/protocol**
study_info

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

%fitDataBSB1([subjectID '_' num2str(clt_bsID(1)) 'd1_mri_resamp_es.mnc'], [subjectID '_' num2str(clt_bsID(2)) 'd2_mri_resamp_es.mnc'], 500, 0.008, 'gauss', 'b1_clt_bs.mnc')
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
% 
% % **** Next section needed because of a flaw in Niak ****
% % When writing out a single slice image, Niak (or at lease, 0.6.3) does not
% % write out the 3rd dimension (of size 1).
% 
% [~,zStart]=system(['mincinfo -attvalue zspace:start ' subjectID '_' num2str(clt_vfaID(1)) '_mri_es.mnc']);
% [~,zStep]=system(['mincinfo -attvalue zspace:step ' subjectID '_' num2str(clt_vfaID(1)) '_mri_es.mnc']);
% 
% system(['mincconcat -clobber -concat_dimension zspace -start ' num2str(str2double(zStart)) ' -step 1 t1_clt_tse_ir.mnc temp.mnc']) % even if I set step to something different to 1, it always makes it 1 ??!?
% system(['mincresample -clobber -zstep ' num2str(str2double(zStep)) ' temp.mnc t1_clt_tse_ir.mnc']) 
% system('rm temp.mnc')

% LL

%fitData_LL_T1(subjectID, cd, ep_segID, 'b1_clt_afi.mnc', [subjectID '_' num2str(structID) '_mri_reg_resamp.mnc'])
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
%system('mincresample -clobber -nearest_neighbour -like t1/t1_clt_tse_ir.mnc mask/brain_classified_mask_resamp.mnc mask/brain_classified_mask_resamp_ss_2x2x5.mnc')
maskMajorityVoting('t1/t1_clt_tse_ir.mnc', 'brain_classified.mnc',3,'brain_classified_ir');
system('minccalc -expression ''A[0] > 75.1 ? 1 : 0'' brain_classified_ir_wm_perc.mnc mask/brain_wm_mask_resamp_ir_2x2x5.mnc')


% Extracted slices from 3D
%system('mincresample -clobber -nearest_neighbour -like t1/t1_clt_vfa_b1_clt_afi.mnc mask/brain_classified_mask_resamp.mnc mask/brain_classified_mask_resamp_es_2x2x5.mnc')
maskMajorityVoting('t1/t1_clt_vfa_b1_clt_afi.mnc', 'brain_classified.mnc',3,'brain_classified_afi');
system('minccalc -expression ''A[0] > 75.1 ? 1 : 0'' brain_classified_afi_wm_perc.mnc mask/brain_wm_mask_resamp_es_2x2x5.mnc')


% For LL
%system('mincresample -clobber -nearest_neighbour -like t1/t1_ep_seg_b1_clt_tse.mnc mask/brain_classified_mask_resamp.mnc mask/brain_classified_mask_resamp_ss_2x2x5.mnc')
maskMajorityVoting('t1/t1_ep_seg_b1_clt_afi.mnc', 'brain_classified.mnc',3,'brain_classified_ll');
system('minccalc -expression ''A[0] > 75.1 ? 1 : 0'' brain_classified_ll_wm_perc.mnc mask/brain_wm_mask_resamp_ll_2x2x5.mnc')

% For EPSEG
%system('mincresample -clobber -nearest_neighbour -like t1/t1_ep_seg_b1_clt_tse.mnc mask/brain_classified_mask_resamp.mnc mask/brain_classified_mask_resamp_ss_2x2x5.mnc')
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


%%
%
[t1_hdr,t1{1}] = niak_read_minc('t1/t1_clt_tse_ir.mnc');
t1{5} = t1{1};
t1{9}=t1{1};
t1{13}=t1{1};


[~,t1{2}] = niak_read_minc('t1/t1_ep_seg_b1_clt_afi.mnc');
t1{6} = t1{2};
t1{10}=t1{2};
t1{14}=t1{2};

[~,t1{3}] = niak_read_minc('t1/t1_gre_vfa_b1_clt_tse.mnc');
[~,t1{4}] = niak_read_minc('t1/t1_clt_vfa_spoil_b1_clt_tse.mnc');

[~,t1{7}] = niak_read_minc('t1/t1_gre_vfa_b1_epseg_da.mnc');
[~,t1{8}] = niak_read_minc('t1/t1_clt_vfa_spoil_b1_epseg_da.mnc');

[~,t1{11}] = niak_read_minc('t1/t1_gre_vfa_b1_clt_afi.mnc');
[~,t1{12}] = niak_read_minc('t1/t1_clt_vfa_spoil_b1_clt_afi.mnc');

[~,t1{15}] = niak_read_minc('t1/t1_gre_vfa_b1_clt_bs.mnc');
[~,t1{16}] = niak_read_minc('t1/t1_clt_vfa_spoil_b1_clt_bs.mnc');

colours = 'brgkyrgkyrgkyrgk';
xFOV = (1:t1_hdr.info.dimensions(2))*t1_hdr.info.voxel_size(2);
yFOV = (1:t1_hdr.info.dimensions(1))*t1_hdr.info.voxel_size(1);

% Pre-allocate cells
reshapedT1 = cell(1,length(t1));
yFreq = cell(1,length(t1));
xT1 = cell(1,length(t1));

for ii=1:length(t1)

    if ii==5 || ii==9 || ii==13
        
        reshapedT1{ii} = t1{ii}(:);
        reshapedT1{ii}(reshapedT1{ii}==0)=[];
        reshapedT1{ii}(reshapedT1{ii}>1.5)=[];
        reshapedT1{ii}(reshapedT1{ii}<0.5)=[];
        % Calculate histogram data
        [yFreq{ii},xT1{ii}]=hist(reshapedT1{ii},25);
    elseif ii==6 || ii==10 || ii==14
        
        reshapedT1{ii} = t1{ii}(:);
        reshapedT1{ii}(reshapedT1{ii}==0)=[];
        reshapedT1{ii}(reshapedT1{ii}>1.5)=[];
        reshapedT1{ii}(reshapedT1{ii}<0.5)=[];
        % Calculate histogram data
        [yFreq{ii},xT1{ii}]=hist(reshapedT1{ii},25);       
    else

        reshapedT1{ii} = t1{ii}(:);
        reshapedT1{ii}(reshapedT1{ii}==0)=[];
        reshapedT1{ii}(reshapedT1{ii}>1.5)=[];
        reshapedT1{ii}(reshapedT1{ii}<0.5)=[];

        % Calculate histogram data
        [yFreq{ii},xT1{ii}]=hist(reshapedT1{ii},25);
        plot(xT1{ii},yFreq{ii}./length(reshapedT1{ii}), colours(ii))
        hold on
    end
end
title('WM masked brain T1 histogram')
xlabel('T1 (s)')

namesB1 = {'clt\_tse','bic\_clt','clt\_afi','clt\_bs'};
namesT1 = {'ir    ','ll    ','vfa   ','vfa\_opt'};



figure()
bottom = 0.5;
top = 1.5;



for ii = 1:length(t1)
    if ii==5 || ii==9 || ii==13
        %skip
    elseif ii==6 || ii==10 || ii==14
        %skip        
    else
        subplot(4,4,ii)
        imagesc(yFOV,xFOV,imrotate(t1{ii},-90))    
        caxis('manual') 
        caxis([bottom top]);
        axis image
    end
end

subplot(4,4,1)
title(namesT1{1})
ylabel(namesB1{1})

subplot(4,4,2)
title(namesT1{2})

subplot(4,4,3)
title(namesT1{3})

subplot(4,4,4)
title(namesT1{4})

subplot(4,4,5)
ylabel(namesB1{2})


subplot(4,4,9)
ylabel(namesB1{3})

subplot(4,4,13)
ylabel(namesB1{4})

% 4 B1 graphs of 

figure()
colours = 'brgk';


for ii = 1:length(t1)/4
    
    subplot(2,2,ii)
    for jj = 1:length(t1)/4

        plot(xT1{(jj+(ii-1)*4)},yFreq{(jj+(ii-1)*4)}./length(reshapedT1{(jj+(ii-1)*4)}), colours(jj))
        hold on 

    end
        
end

for ii = 1:length(t1)/4
    subplot(2,2,ii)
    title(namesB1{ii})
    xlabel('T1 (s)')
    legend(namesT1)
end

figure()
colours = 'brgk';

for ii = 1:length(t1)/4

    subplot(2,2,ii)
    for jj = 1:length(t1)/4

        plot(xT1{(ii+(jj-1)*4)},yFreq{(ii+(jj-1)*4)}./length(reshapedT1{(ii+(jj-1)*4)}), colours(jj))
        hold on 
        
    end
        
end


for ii = 1:length(t1)/4
    
    subplot(2,2,ii)
    title(namesT1{ii})
    xlabel('T1 (s)')
    if ii~=1 && ii~=2
        legend(namesB1)
    end
end
%% Make Table

%                 ** T1 Table**   
%
%       |   IR   |   LL   |   VFA  |VFAspoil|
%--------------------------------------------
%   DA  |        |        |        |        |
%--------        ----------------------------
%DA Sled|        |        |        |        |
%--------        ----------------------------
%  AFI  |        |        |        |        |
%--------        ----------------------------
%   BS  |        |        |        |        |
%--------------------------------------------



% Get means


t1Means = zeros(4);
t1STDs = zeros(4);

for ii = 1:length(t1)
 
    if ii==5 || ii==9 || ii==13
        %skip
    else   
        t1Means(ii) = mean(reshapedT1{ii}(:));
        t1STDs(ii) = std(reshapedT1{ii}(:));
    end
    
end

t1Means = t1Means'

t1STDs = t1STDs'

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

[~,b1{1}] = niak_read_minc('b1/b1_clt_tse.mnc');
[~,b1{2}] = niak_read_minc('b1/b1_epseg_da.mnc');
[~,b1{3}] = niak_read_minc('b1/b1_clt_afi.mnc');
[~,b1{4}] = niak_read_minc('b1/b1_clt_gre_bs_cr_fermi.mnc');


% Plot slice B1 maps
figure()
bottom = 0.7;
top = 1.3;
namesB1 = {'clt\_tse','epseg\_da','clt\_afi','clt\_bs'};

for ii = 1:length(b1)

    subplot(2,2,ii)
    imagesc(yFOV,xFOV,imrotate(b1{ii},-90))    
    caxis('manual') 
    caxis([bottom top]);
    axis image
end

for ii = 1:length(b1)
    subplot(2,2,ii)
    title(namesB1{ii})
end

% Plot B1 Histogram

figure()

% Pre-allocate cells
reshapedB1 = cell(1,length(b1));
yB1Freq = cell(1,length(b1));
xB1 = cell(1,length(b1));
colours = 'brgk';

for ii=1:length(b1)


    reshapedB1{ii} = b1{ii}(:);
    reshapedB1{ii}(reshapedB1{ii}==0)=[];
    reshapedB1{ii}(reshapedB1{ii}>1.5)=[];
    reshapedB1{ii}(reshapedB1{ii}<0.5)=[];
    % Calculate histogram data
    [yB1Freq{ii},xB1{ii}]=hist(reshapedB1{ii},50);

    plot(xB1{ii},yB1Freq{ii}./length(reshapedB1{ii}), colours(ii))
    hold on

end
title('WM masked brain B1 histogram')
xlabel('B1 (s)')
legend(namesB1)


% Plot slice B1 maps erros
figure()
bottom = 0.7;
top = 1.3;

for ii = 1:length(b1)
    if ii==1
        subplot(2,2,ii)
        imagesc(yFOV,xFOV,imrotate(b1{ii},-90))    
        caxis('manual') 
        caxis([bottom top]);
        axis image
    else
        subplot(2,2,ii)
        imagesc(yFOV,xFOV,imrotate(abs((b1{ii}-b1{1})./b1{2}*100),-90))    
        axis image   
        caxis('manual') 
        caxis([0 5]);
    end
    
end

for ii = 1:length(b1)
    subplot(2,2,ii)
    title(namesB1{ii})
end

%% Fit qMT parameter maps
%
