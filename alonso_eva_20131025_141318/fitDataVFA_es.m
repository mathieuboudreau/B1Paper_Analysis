function fitDataVFA_es (subjectID, vfaIndeces, b1Out, t1Out, ref) 

% Usage: fitData (subjectID, afiIndeces, vfaIndeces, t1Out, b1Out, ref) 
% -------------------------------------------------------------------------
% inputs
% ------
% subjectID: the minc ID in the format last_first_date_time
% b1map: b1map filename
% vfaIndeces: integers marking the VFA files
% t1Out: the name of the t1 map minc file
% ref: the reference minc file
% ---------------------------------------
% This function uses minc tools to compute a T1 map by 
% combining two images acquired using the variable flip angle (VFA) T1
% mapping technique, and correcting for the flip angle inhomogeneity using
% the actual flip angle (AFI) technique.  As the AFI files are at a lower resolution, 
% all files are resampled and registered to ref.  All of the sequence parameters
% have been hard-coded in this function to streamline the processing.  If
% any parameters in the protocol are changed, the changes need to be made
% in this function
% ----------------
% Example: fitDataAFI
% Written by: Nikola Stikov
% Date: Jan 19, 2012
% Updated: Apr 25, 2012 to add a 'ref' field
% Updated: Sep 28, 2012, changed the indexing of AFI/VFA
% Updated (Mathieu): March 21st 2013, upgraded sequence to work solely with
% niak. Emma is no longer used.


% We assume there are always two AFI files

files = cell(1,length(vfaIndeces));
vfaFlip = zeros(1,length(vfaIndeces));
vfaFilesAligned = cell(1,length(vfaIndeces));

filesHeader = cell(1,length(vfaIndeces));

for ii=1:numel(vfaIndeces)
    files{ii} = [subjectID '_' num2str(vfaIndeces(ii)) '_mri_es.mnc'];
    filesHeader{ii} = niak_read_hdr_minc(cell2mat(files(ii)));
    vfaFlip(ii) = cell2mat(filesHeader{ii}.details.acquisition.attvalue(getAttributeIndexNiak(filesHeader{ii},'flip_angle')));
    vfaFilesAligned{ii} = ['VFA_' num2str(vfaFlip(ii)) '.mnc'];
end




% Align the files to ref and resample them to the same resolution
for ii=1:numel(files)
    mincResampleAndAlign(files{ii}, ref, vfaFilesAligned{ii});
end


% Now we make a mask, based on the second VFA image

[vfahdr, mask] = niak_read_minc(vfaFilesAligned{2});
mask(mask<50) = 0;
mask = cast(mask, 'logical');
maskhdr = vfahdr;
maskhdr.file_name = [t1Out, '_mask.mnc'];
niak_write_minc_ss(maskhdr,mask);

% % **** Next section needed because of a flaw in Niak ****
% % When writing out a single slice image, Niak (or at lease, 0.6.3) does not
% % write out the 3rd dimension (of size 1).
% 
% [~,zStart]=system(['mincinfo -attvalue zspace:start ' vfaFilesAligned{2}])
% [~,zStep]=system(['mincinfo -attvalue zspace:step ' vfaFilesAligned{2}])
% 
% system(['mincconcat -clobber -concat_dimension zspace -start ' num2str(str2double(zStart)) ' -step 1 ' [t1Out, '_mask.mnc'] ' temp.mnc']) % even if I set step to something different to 1, it always makes it 1 ??!?
% system(['mincresample -clobber -zstep ' num2str(str2double(zStep)) ' temp.mnc ' [t1Out, '_mask.mnc']]) 
% system('rm temp.mnc')

% Now we process the T1 map, using the above b1 map

TR = cell2mat(filesHeader{ii}.details.acquisition.attvalue(getAttributeIndexNiak(filesHeader{ii},'repetition_time')));


if (numel(vfaIndeces) == 2)
    %qt1_vfa(vfaFilesAligned{1}, vfaFilesAligned{2}, vfaFlip(1)*pi/180, vfaFlip(2)*pi/180, TR, t1Out, 'M0.mnc', b1Out);
    qt1_vfa_lin_fit(vfaFilesAligned, vfaFlip/180*pi, TR, [t1Out, '.mnc'], [t1Out,'_m0.mnc'], b1Out, [t1Out, '_mask.mnc']);
else
    % maybe add mask
    qt1_vfa_lin_fit(vfaFilesAligned, vfaFlip/180*pi, TR, [t1Out, '.mnc'], [t1Out,'_m0.mnc'], b1Out, [t1Out, '_mask.mnc']);
    %qt1_vfa_nonlin_fit(vfaFilesAligned, vfaFlip/180*pi, TR, [t1Name 'nonlin_corr.mnc'], ['M0_' t1Name 'nonlin_corr.mnc'], b1Out, 'mask.mnc');
end