function percentageTissue = maskMajorityVoting(inputMincVolume, inputMincClassified, numberOfClasses, outputBaseName)
%MASKMAJORITYVOTING Creates from a high res tissue classified mask, low res volumes of tissue percentages.
%   A high resolution tissue classified (0,1,2,3,...) mask is used to
%   classify the tissue percentage in a lower resolution volume. Each voxel
%   of the hi res volume is associated with the voxel in the low res volume
%   for which the center of hi res voxel is contained within it, and a 
%   percentage of each tissue class in the low res volumes is calculated.
%
%   For three tissue classes, the results are outputed in minc files.
%
% inputMincVolume: Low res volume
% inputMincClassified:  High res tissue classified (0,1,2,3,...) mask
% numberOfClasses: Number of tissue classes
% outputBaseName: String containing the
%
%   Date created: September 14 2013
%   Author: Mathieu Boudreau
%   Last modified: September 27 2013

%% Load volume data and header information
%

vol_hdr = niak_read_hdr_minc(inputMincVolume);    % Only hdr information is needed from inputMincVolume
[classVol_hdr, classVol] = niak_read_minc(inputMincClassified);

% Image volume  dimentions
vol_dimentions = vol_hdr.info.dimensions;
classVol_dimentions = classVol_hdr.info.dimensions;

% Voxel to World transformation matrices
vol_mat = vol_hdr.info.mat;
classVol_mat = classVol_hdr.info.mat;



imagesc(classVol(:,:,size(classVol,3)/2))
drawnow
pause(5)


%% Pre-allocate arrays
%

% Container for the classified inputMincVolume (4th dimension contains the
% number of center of voxels of inputMincClassified that are contained in
% each voxels of inputMincVolume for each tissue class)
volNowClassified = zeros(vol_dimentions(1), vol_dimentions(2), vol_dimentions(3), numberOfClasses+1);

% Each voxel of sumOfClassVoxelInVolVoxels contains the total number of
% voxels of inputMincClassified for all tissues that are contained in inputMincVolume
sumOfClassVoxelInVolVoxels = zeros(vol_dimentions(1), vol_dimentions(2), vol_dimentions(3));

% The fourth dimension of percentageTissue is volNowClassified transformed
% into percentages of tissues.
percentageTissue = zeros(vol_dimentions(1), vol_dimentions(2), vol_dimentions(3), numberOfClasses+1);


%% Identify which voxel of inputMincVolume contains each voxels of inputMincClassified
%

for ii=1:classVol_dimentions(1);

    for jj=1:classVol_dimentions(2);

        for kk=1:classVol_dimentions(3);
             
             classVolVoxel = [ii, jj, kk];
            
             classVolWorld = classVol_mat*[classVolVoxel(1)-0.5; classVolVoxel(2)-0.5; classVolVoxel(3)-0.5; 1];
             
             virtualVolVoxel = vol_mat\[classVolWorld(1); classVolWorld(2); classVolWorld(3); 1]; 
             
             virtualVolVoxel = [round(virtualVolVoxel(1)+0.5), round(virtualVolVoxel(2)+0.5), round(virtualVolVoxel(3)+0.5)];

             if((virtualVolVoxel>0) & (virtualVolVoxel<=vol_dimentions) & classVol(ii,jj,kk)~=0)

                 volNowClassified(virtualVolVoxel(1), virtualVolVoxel(2), virtualVolVoxel(3), round(classVol(ii,jj,kk))+1) = volNowClassified(virtualVolVoxel(1), virtualVolVoxel(2), virtualVolVoxel(3), round(classVol(ii,jj,kk))+1)+1;
                 
             end

        end
        
    end
    
end

%% Calculate percentage of each tissues in each voxels
%

for ii=1:vol_dimentions(1);

    for jj=1:vol_dimentions(2);

        for kk=1:vol_dimentions(3);
            sumOfClassVoxelInVolVoxels(ii,jj,kk) = sum(volNowClassified(ii,jj,kk,:)); 
            
            if sumOfClassVoxelInVolVoxels(ii,jj,kk)==0                
                percentageTissue(ii,jj,kk,:) = 0;
            else
                for ll=1:(numberOfClasses+1)
                    percentageTissue(ii,jj,kk,ll) = volNowClassified(ii,jj,kk,ll)./sumOfClassVoxelInVolVoxels(ii,jj,kk)*100;
                end
            end
            
        end
    end
end


percentageTissue(isnan(percentageTissue))=0;

%% Write out minc files of tissue percentages
%
if numberOfClasses == 3
    csf_hdr=vol_hdr;
    csf_hdr.file_name = [outputBaseName '_csf_perc.mnc'];
    niak_write_minc(csf_hdr,double(squeeze(percentageTissue(:,:,:,2))));

    gm_hdr=vol_hdr;
    gm_hdr.file_name = [outputBaseName '_gm_perc.mnc'];
    niak_write_minc(gm_hdr,double(squeeze(percentageTissue(:,:,:,3))));

    wm_hdr=vol_hdr;
    wm_hdr.file_name = [outputBaseName '_wm_perc.mnc'];
    niak_write_minc(wm_hdr,double(squeeze(percentageTissue(:,:,:,4))));

    % **** Next section needed because of a flaw in Niak ****
    % When writing out a single slice image, Niak (or at lease, 0.6.3) does not
    % write out the 3rd dimension (of size 1).

    [~,zStart]=system(['mincinfo -attvalue zspace:start ' inputMincVolume]);
    [~,zStep]=system(['mincinfo -attvalue zspace:step ' inputMincVolume]);

    system(['mincconcat -clobber -concat_dimension zspace -start ' num2str(str2double(zStart)) ' -step 1 ' csf_hdr.file_name ' temp.mnc']) % even if I set step to something different to 1, it always makes it 1 ??!?
    system(['rm ' csf_hdr.file_name])
    system(['mincresample -clobber -zstep ' num2str(str2double(zStep)) ' temp.mnc ' csf_hdr.file_name]) 
    system('rm temp.mnc')

    system(['mincconcat -clobber -concat_dimension zspace -start ' num2str(str2double(zStart)) ' -step 1 ' gm_hdr.file_name ' temp.mnc']) % even if I set step to something different to 1, it always makes it 1 ??!?
    system(['rm ' gm_hdr.file_name])
    system(['mincresample -clobber -zstep ' num2str(str2double(zStep)) ' temp.mnc ' gm_hdr.file_name]) 
    system('rm temp.mnc')

    system(['mincconcat -clobber -concat_dimension zspace -start ' num2str(str2double(zStart)) ' -step 1 ' wm_hdr.file_name ' temp.mnc']) % even if I set step to something different to 1, it always makes it 1 ??!?
    system(['rm ' wm_hdr.file_name])
    system(['mincresample -clobber -zstep ' num2str(str2double(zStep)) ' temp.mnc ' wm_hdr.file_name]) 
    system('rm temp.mnc')
else
    % Nothing, return percentageTissue.
end


