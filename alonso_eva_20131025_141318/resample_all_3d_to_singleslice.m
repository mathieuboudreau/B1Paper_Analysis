%% Extract a the slice matching the single slice images from the 3D scans
%
% 3D scans were planned so that the 17th 3D slice matches the same area
% that the snigle slice images were acquired.
%
% Author: Mathieu Boudreau
% Date: June 27th 2013
% Purpose: For the B1T1qMT Project

%% 3D B1 Scans
%

% AFI
system(['mincreshape -clobber -dimrange zspace=16,1 ', subjectID, '_', num2str(clt_afiID(1)), 'd1_mri.mnc ', subjectID, '_', num2str(clt_afiID(1)), 'd1_mri_es.mnc ']) % "es" stands for extracted slice
system(['mincreshape -clobber -dimrange zspace=16,1 ', subjectID, '_', num2str(clt_afiID(2)), 'd2_mri.mnc ', subjectID, '_', num2str(clt_afiID(2)), 'd2_mri_es.mnc ']) % "es" stands for extracted slice

% ep_seg
system(['mincresample -clobber -like ' subjectID, '_', num2str(clt_afiID(1)), 'd1_mri_es.mnc ',  subjectID, '_', num2str(epseg_daID(1)), '_mri.mnc ' subjectID, '_', num2str(epseg_daID(1)), '_mri_resamp.mnc'])
%system(['mincreshape -clobber -dimrange zspace=16,1 ', subjectID, '_', num2str(epseg_daID(1)), '_mri_resamp.mnc ', subjectID, '_', num2str(epseg_daID(1)), '_mri_resamp_es.mnc ']) % "es" stands for extracted slice

system(['mincresample -clobber -like ' subjectID, '_', num2str(clt_afiID(1)), 'd1_mri_es.mnc ',  subjectID, '_', num2str(epseg_daID(2)), '_mri.mnc ' subjectID, '_', num2str(epseg_daID(2)), '_mri_resamp.mnc'])
%system(['mincreshape -clobber -dimrange zspace=16,1 ', subjectID, '_', num2str(epseg_daID(2)), '_mri_resamp.mnc ', subjectID, '_', num2str(epseg_daID(2)), '_mri_resamp_es.mnc ']) % "es" stands for extracted slice

%% 3D T1 Scans
%

for ii = 1:length(gre_vfaID)
    system(['mincreshape -clobber -dimrange zspace=16,1 ', subjectID, '_', num2str(gre_vfaID(ii)), '_mri.mnc ', subjectID, '_', num2str(gre_vfaID(ii)), '_mri_es.mnc ']) % "es" stands for extracted slice
end

for ii = 1:length(clt_vfaID)
    system(['mincreshape -clobber -dimrange zspace=16,1 ', subjectID, '_', num2str(clt_vfaID(ii)), '_mri.mnc ', subjectID, '_', num2str(clt_vfaID(ii)), '_mri_es.mnc ']) % "es" stands for extracted slice
end

for ii = 1:length(clt_vfa_spoilID)
    system(['mincreshape -clobber -dimrange zspace=16,1 ', subjectID, '_', num2str(clt_vfa_spoilID(ii)), '_mri.mnc ', subjectID, '_', num2str(clt_vfa_spoilID(ii)), '_mri_es.mnc ']) % "es" stands for extracted slice
end

%% Resample STRUCTURAL to extract the same slice as all the single slice scans
%

% Fit the structural scan to the VFA data using mutual information 
system(['minctracc -clob -identity -mi ', subjectID, '_', num2str(structID), '_mri.mnc ', subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ', '-lsq6 -debug transform.xfm -simplex 1 -clobber']);

% Transform the structural scan using the fitted parameters, and the same
% sampling as the structural scan
system(['mincresample -clob -transformation transform.xfm -use_input_sampling ', subjectID, '_', num2str(structID), '_mri.mnc ', subjectID, '_', num2str(structID), '_mri_reg.mnc -transverse']);

% Get X,Y steps and dimlengths from structural scan, and Z step and
% dimlength from the VFA scan
[~,struct_xstep]=system(['mincinfo -attvalue xspace:step ',subjectID, '_', num2str(structID), '_mri.mnc ']);
[~,struct_ystep]=system(['mincinfo -attvalue yspace:step ',subjectID, '_', num2str(structID), '_mri.mnc ']);
[~,vfa_zstep]=system(['mincinfo -attvalue zspace:step ',subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ']);
[~,struct_xlength]=system(['mincinfo -dimlength xspace ',subjectID, '_', num2str(structID), '_mri.mnc ']);
[~,struct_ylength]=system(['mincinfo -dimlength yspace ',subjectID, '_', num2str(structID), '_mri.mnc ']);
[~,vfa_zlength]=system(['mincinfo -dimlength zspace ',subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ']);


% Get PE %
[~,vfa_xlength]=system(['mincinfo -dimlength xspace ',subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ']);
[~,vfa_ylength]=system(['mincinfo -dimlength yspace ',subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ']);
% ***Assumes that the PE direction is L->R (xspace)
pe_perc = str2double(vfa_xlength)/str2double(vfa_ylength);

% Resample registered structural scan so that slices match the size of the
% VFA slices (and all other extracted slice scans), but the X,Y resolution
% stays the same as the original structural measurement
system(['mincresample -clob -like ', subjectID, '_', num2str(clt_vfaID(2)), '_mri.mnc ', '-step ', num2str(str2double(struct_xstep)), ' ', num2str(str2double(struct_ystep)), ' ', num2str(str2double(vfa_zstep)), ' -nelements ', num2str(str2double(struct_xlength)*pe_perc), ' ', num2str(str2double(struct_ylength)), ' ', num2str(str2double(vfa_zlength)), ' ', subjectID, '_', num2str(structID), '_mri_reg.mnc ', subjectID, '_', num2str(structID), '_mri_reg_resamp.mnc']);

system(['mincreshape -clobber -dimrange zspace=16,1 ', subjectID, '_', num2str(structID), '_mri_reg_resamp.mnc ', subjectID, '_', num2str(structID), '_mri_reg_resamp_es.mnc']) % "es" stands for extracted slice
