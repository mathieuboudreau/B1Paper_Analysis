function fit_t1_ll_sign_flip(mag_file_name, t1_file_name, mask_file_name, seqParams)
%FIT_T1_LL_SIGN_FLIP Fits Look-Locker maps using magnitude data only by flipping
% a two combinations of the first two points ([-1 1 1 1], [-1 -1 1 1], 
% keeping the T1 with the least fitted residual. 
%
% This code is designed for four-TI Look-Locker data in the Minc format. 
% The Look-Locker fitting routine assumes that the second point is near the
% null of WM and GM. It also assumes perfect nominal flip angles (both the
% inversion AND excitation pulses).
%
% This script was originally writtend to be called by a function names
% "fitData_LL_T1_SignFlip.m"
%
% Niak is required for loading and saving Minc files, and to access header 
% information.
%
% ************ATTENTION************
% * This code is only appropriate *
% * for fitting *HEALTHY WM*. Due *
% * to the noise floor, a small   *
% * range of T1 cannot be fit,    *
% * because the data near the     *
% * second point will never be 0. *
% *                               *
% * For ep_seg_qt1_flex, this     *
% * range is around 1.3 to 1.4 s  *
% ************ATTENTION************
%
% *** Inputs ***
% mag_file_name: 
% t1_file_name: 
% mask_file_name: 
%
% Date Created: September 2013
% Author: Mathieu Boudreau
% Institution: McConnell Brain Imaging Center, Montreal Neurological
%              Institute, Montreal, Quebec
%
% Date last modified: October 2 2013
% 

%% Set hardcoded parameters
%

% Set the time to first excitation (TI1) and the interval between
% excitations (TI2)

TI1 = seqParams.TI1;
TI2 = seqParams.TI2;

% Fitting t1 guess
t1_guess = 0.8;

% Maximum allowable T1
maxT1 = 10;

%% Load images and header information
%

% Open magnitude data
[h_hdr, h] = niak_read_minc(mag_file_name);

% Get image dimensions
num_echoes(1) = h_hdr.info.dimensions(4);
num_slices(1) = h_hdr.info.dimensions(3);
height(1)  = h_hdr.info.dimensions(2);
width(1)   = h_hdr.info.dimensions(1);

% Pre-allocate data array
mag_data = zeros(num_slices(1),width(1)*height(1),num_echoes(1));

% Allocate data values to array
for slice = 1:num_slices(1)
    tmp_h = squeeze(h(:,:,slice,:));
    mag_data(slice,:,:) = reshape(tmp_h, width(1)*height(1),num_echoes(1));
end


% Load mask
[~, h] = niak_read_minc(mask_file_name);

% Pre-allocate mask array
mask_data = zeros(num_slices(1),width(1)*height(1));

% Allocate mask array values
for slice = 1:num_slices(1)
    tmp_h = squeeze(h(:,:,slice));
    mask_data(slice,:) = tmp_h(:);
end

%% Set sequence parameters
%

TR = cell2mat(h_hdr.details.acquisition.attvalue(15));
alpha= 180; % Assume Perfect 180
beta = cell2mat(h_hdr.details.acquisition.attvalue(20));
Nll = num_echoes;

% Convert angles to radians
alpha = alpha*pi/180;
beta = beta*pi/180;

%% Fit data
%

% Pre-allocate T1 array
t1_fit = zeros(width(1)*height(1),num_slices(1));

for slice = 1:num_slices(1)
    
    slice_mask = mask_data(slice,:);
 
    for voxel = find(slice_mask);
         data = squeeze(mag_data(slice,voxel,:));
         [t1_fit(voxel,slice),~]=fit_ll_voxel(data,alpha, beta,TI1,TI2,t1_guess,TR,Nll);
    end
end

%% Output T1 map
%

[h_hdr, ~] = niak_read_minc(mag_file_name);
h_hdr.file_name = t1_file_name;

t1_fit(t1_fit>maxT1)=0;
t1_fit(t1_fit<0)=0;

niak_write_minc_ss(h_hdr, reshape(t1_fit,width(1),height(1),num_slices(1)))

% % **** Next section needed because of a flaw in Niak ****
% % When writing out a single slice image, Niak (or at lease, 0.6.3) does not
% % write out the 3rd dimension (of size 1).
% 
% [~,zStart]=system(['mincinfo -attvalue zspace:start ' mask_file_name]);
% [~,zStep]=system(['mincinfo -attvalue zspace:step ' mask_file_name]);
% 
% system(['mincconcat -clobber -concat_dimension zspace -start ' num2str(str2double(zStart)) ' -step 1 ' t1_file_name ' temp.mnc']) % even if I set step to something different to 1, it always makes it 1 ??!?
% system(['mincresample -clobber -zstep ' num2str(str2double(zStep)) ' temp.mnc t1.mnc']) 
% system('rm temp.mnc')
% system(['rm ' t1_file_name])
% system(['mv t1.mnc ' t1_file_name])

end

