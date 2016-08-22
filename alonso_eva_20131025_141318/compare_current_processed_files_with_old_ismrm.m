function [b1, b1_ismrm, b1err, t1, t1_ismrm, t1err] = compare_current_processed_files_with_old_ismrm(cur_repo,ismrm_repo)
%compare_current_processed_files_with_old_ismrm 
% Display and compare two datasets to verify if the dataprocessing was
% identical
%   e.g. cur_repo   = '~/Work/Analysis_PhDWork/B1Paper/alonso_eva_20131025_141318/'
%        ismrm_repo = '~/Work/Projects/B1T1qMT/ISMRM/alonso_eva_20131025_141318/'
%   
%   ***Could be used as part of an integration test later on***

%% Load current repo files
%

[~,b1{1}] = niak_read_minc([cur_repo, 'b1/b1_clt_tse.mnc']);
[~,b1{2}] = niak_read_minc([cur_repo, 'b1/b1_epseg_da.mnc']);
[~,b1{3}] = niak_read_minc([cur_repo, 'b1/b1_clt_afi.mnc']);
[~,b1{4}] = niak_read_minc([cur_repo, 'b1/b1_clt_gre_bs_cr_fermi.mnc']);

[~,t1{1}] = niak_read_minc([cur_repo, 't1/t1_clt_tse_ir.mnc']);

[~,t1{2}] = niak_read_minc([cur_repo, 't1/t1_ep_seg_b1_clt_afi.mnc']);

[~,t1{3}] = niak_read_minc([cur_repo, 't1/t1_gre_vfa_b1_clt_tse.mnc']);
[~,t1{4}] = niak_read_minc([cur_repo, 't1/t1_clt_vfa_spoil_b1_clt_tse.mnc']);

[~,t1{5}] = niak_read_minc([cur_repo, 't1/t1_gre_vfa_b1_epseg_da.mnc']);
[~,t1{6}] = niak_read_minc([cur_repo, 't1/t1_clt_vfa_spoil_b1_epseg_da.mnc']);

[~,t1{7}] = niak_read_minc([cur_repo, 't1/t1_gre_vfa_b1_clt_afi.mnc']);
[~,t1{8}] = niak_read_minc([cur_repo, 't1/t1_clt_vfa_spoil_b1_clt_afi.mnc']);

[~,t1{9}] = niak_read_minc([cur_repo, 't1/t1_gre_vfa_b1_clt_bs.mnc']);
[~,t1{10}] = niak_read_minc([cur_repo, 't1/t1_clt_vfa_spoil_b1_clt_bs.mnc']);

%% Load ISMRM repo files
%

[~,b1_ismrm{1}] = niak_read_minc([ismrm_repo, 'b1/b1_clt_tse.mnc']);
[~,b1_ismrm{2}] = niak_read_minc([ismrm_repo, 'b1/b1_epseg_da.mnc']);
[~,b1_ismrm{3}] = niak_read_minc([ismrm_repo, 'b1/b1_clt_afi.mnc']);
[~,b1_ismrm{4}] = niak_read_minc([ismrm_repo, 'b1/b1_clt_gre_bs_cr_fermi.mnc']);

[~,t1_ismrm{1}] = niak_read_minc([ismrm_repo, 't1/t1_clt_tse_ir.mnc']);

[~,t1_ismrm{2}] = niak_read_minc([ismrm_repo, 't1/t1_ep_seg_b1_clt_afi.mnc']);

[~,t1_ismrm{3}] = niak_read_minc([ismrm_repo, 't1/t1_gre_vfa_b1_clt_tse.mnc']);
[~,t1_ismrm{4}] = niak_read_minc([ismrm_repo, 't1/t1_clt_vfa_spoil_b1_clt_tse.mnc']);

[~,t1_ismrm{5}] = niak_read_minc([ismrm_repo, 't1/t1_gre_vfa_b1_epseg_da.mnc']);
[~,t1_ismrm{6}] = niak_read_minc([ismrm_repo, 't1/t1_clt_vfa_spoil_b1_epseg_da.mnc']);

[~,t1_ismrm{7}] = niak_read_minc([ismrm_repo, 't1/t1_gre_vfa_b1_clt_afi.mnc']);
[~,t1_ismrm{8}] = niak_read_minc([ismrm_repo, 't1/t1_clt_vfa_spoil_b1_clt_afi.mnc']);

[~,t1_ismrm{9}] = niak_read_minc([ismrm_repo, 't1/t1_gre_vfa_b1_clt_bs.mnc']);
[~,t1_ismrm{10}] = niak_read_minc([ismrm_repo, 't1/t1_clt_vfa_spoil_b1_clt_bs.mnc']);

%% Plot figures and differences
%

for ii = 1:length(b1)
    figure()
    subplot(1,3,1)
    imagesc(imrotate(b1{ii},-90)),caxis([0.7,1.3])
    axis image
    subplot(1,3,2)
    imagesc(imrotate(b1_ismrm{ii},-90)),caxis([0.7,1.3])
    axis image
    subplot(1,3,3)
    imagesc(imrotate((b1{ii}-b1_ismrm{ii})./b1_ismrm{ii}.*100,-90)),caxis([-1,1])
    axis image
    disp('B1')
    disp(ii)
    B1percdiff = (b1{ii}-b1_ismrm{ii})./b1_ismrm{ii}.*100;
    B1percdiff(isnan(B1percdiff)) = 0;
    B1percdiff(isinf(B1percdiff)) = 0;
    B1percdiff((-101<B1percdiff) & (B1percdiff<-99)) = 0; % Fix bug
    b1err{ii} = sum(sum(b1percdiff));
end

for ii = 1:length(b1)
    figure()
    subplot(1,3,1)
    imagesc(imrotate(t1{ii},-90)),caxis([0.7,1.3])
    axis image
    subplot(1,3,2)
    imagesc(imrotate(t1_ismrm{ii},-90)),caxis([0.7,1.3])
    axis image
    subplot(1,3,3)
    imagesc(imrotate((t1{ii}-t1_ismrm{ii})./t1_ismrm{ii}.*100,-90)),caxis([-1,1])
    axis image
    disp('T1')
    disp(ii)
    T1percdiff = (t1{ii}-t1_ismrm{ii})./t1_ismrm{ii}.*100;
    T1percdiff(isnan(T1percdiff)) = 0;
    T1percdiff(isinf(T1percdiff)) = 0;
    T1percdiff((-101<T1percdiff) & (T1percdiff<-99)) = 0; % Fix bug
    t1err{ii} = sum(sum(T1percdiff));
end