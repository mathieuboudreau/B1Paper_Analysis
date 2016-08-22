function fitDataAFI_es (subjectID, afiIndeces, b1Out, ref) 

% Usage: fitData (subjectID, afiIndeces, vfaIndeces, t1Out, b1Out, ref) 
% -------------------------------------------------------------------------
% inputs
% ------
% subjectID: the minc ID in the format last_first_date_time
% afiIndeces: integers marking the AFI files
% vfaIndeces: integers marking the VFA files
% t1Out: the name of the t1 map minc file
% b1Out: the name of the b1 map minc file
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

files = cell(1,2);


files{1} = [subjectID '_' num2str(afiIndeces(1)) 'd1_mri_es.mnc'];
files{2} = [subjectID '_' num2str(afiIndeces(2)) 'd2_mri_es.mnc'];
filesAligned = {'AFI_1.mnc', 'AFI_2.mnc'};
filesHeader = cell(1,2);


% Align the files to ref and resample them to the same resolution
for ii=1:numel(files)
    mincResampleAndAlign(files{ii}, ref, filesAligned{ii});
end

% Now perform the AFI B1 mapping
% N, the ratio of TR1 to TR2 is equal to 5

N = 5;

[afi1hdr, afi1] = niak_read_minc('AFI_1.mnc');
[~, afi2] = niak_read_minc('AFI_2.mnc');

r = abs(afi2./afi1);
cos_arg = (r*N-1)./(N-r);

% filter out cases where r > 1:
% r should not be greater than one, so must be noise
cos_arg = double(cos_arg).*(r<=1) + ones(size(r)).*(r>1);


alpha = acos(cos_arg); %alpha is in radians

% To convert alpha to a relative factor, we divide by the nominal flip
% angle pi/3    dude=mincLoadImage(vfaFilesAligned{2});


b1 = alpha/(pi/3);

%mincSaveImage(b1, b1Out, ref);
b1hdr = afi1hdr;
b1hdr.file_name = b1Out;
niak_write_minc_ss(b1hdr,b1);
