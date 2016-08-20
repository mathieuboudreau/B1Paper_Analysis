function fitData_LL_T1_SignFlip(subjectID, dataDir, file_index, t1Filename, maskFilename)
%FITDATA_LL_T1_SIGNFLIP Script that prepares magnitude data and mask for 
% Look-Locker maps fitting using magnitude data only by flipping a two 
% combinations of the first two points ([-1 1 1 1], [-1 -1 1 1], 
% keeping the T1 with the least fitted residual. A call to the Look- 
% Locker fitting routine is called at the end of the script.
%
% This code is designed for four-TI Look-Locker data in the Minc format. 
% The Look-Locker fitting routine assumes that the second point is near the
% null of WM and GM. It also assumes perfect nominal flip angles (both the
% inversion AND excitation pulses).
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
% Filenames must be in minc format, and its filename must be written as:
% (subjectID)_(file_index)_mri.mnc"
%
% *** Inputs ***
% subjectID: String in the form of 'lastname_name_date_id'
% dataDir: String containing working directory - suggeset use is "cd"
% file_index: index 
%
% Date Created: September 2013
% Author: Mathieu Boudreau
% Institution: McConnell Brain Imaging Center, Montreal Neurological
%              Institute, Montreal, Quebec
%
% Date last modified: October 2 2013
% 

%% Hardcoded parameters
%

noiseFloorDataMagnitude = 50;

mag_hdr = niak_read_hdr_minc([subjectID '_' num2str(file_index) 'e1_mri.mnc']);
sequence_type = cell2mat(mag_hdr.details.acquisition.attvalue(getAttributeIndexNiak(mag_hdr,'series_description')));

switch sequence_type
    case 'ep_seg_fid_qt1_flex '
        display('Using ep_seg_fid_qt1_flex hard-coded sequence parameters')
        seqParams.TI1 = 0.015;
        seqParams.TI2 = 0.495;        
    case 'ep_seg_fid_qt1'
        error('The code has not been set up to support ep_seg_fid_qt1')
            
end
   

%% Check existence of directories
%

if ~exist('mask','dir')
    mkdir 'mask'
end

if ~exist('mask','dir')
    mkdir ('t1');
end

%% Concatenate LL images
%

system(['cd ' dataDir]);
system(['mincconcat ' subjectID '_' num2str(file_index(1)) 'e* ' subjectID '_' num2str(file_index(1)) '_mri.mnc -clobber -concat_dimension time']);
magFilename = [subjectID '_' num2str(file_index(1)) '_mri.mnc'];

%% Create mask
%

[mask_hdr, mask] = niak_read_minc([subjectID '_' num2str(file_index) '_mri.mnc']);
mask(mask<noiseFloorDataMagnitude) = 0;
mask = cast(mask, 'logical');
mask_hdr.file_name = ['mask/' maskFilename];
niak_write_minc_ss(mask_hdr,mask);

%% Run processing script
%

ll_fit_map(magFilename, ['t1/' t1Filename], ['mask/' maskFilename], seqParams);
