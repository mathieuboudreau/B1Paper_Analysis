function [] = imageB1T1cat(dataDir)
%imageB1T1cat ImageShow concatenated B1 & T1 maps
%
% --args--
% dataDir: String forentire path to directory containing the folders of
%          each subjects data.
%          Example usage: dataDir = [pwd '/data'];

%%
%

subjectID = dirs2cells(dataDir);

for counterSubject = 1:length(subjectID)
    [t1_hdr,t1{1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_tse.mnc']);
    [~,t1{2}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_bs.mnc']);
    [~,t1{3}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_afi.mnc']);
    [~,t1{4}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_epseg_da.mnc']);



    [~,b1{1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/b1_whole_brain/b1_clt_tse.mnc']);
    [~,b1{2}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/b1_whole_brain/b1_clt_gre_bs_cr_fermi.mnc']);
    [~,b1{3}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/b1_whole_brain/b1_clt_afi.mnc']);
    [~,b1{4}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/b1_whole_brain/b1_epseg_da.mnc']);

    [~,mask] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/mask/mask.mnc']);

    %%
    for ii=1:length(t1)
        t1{ii}(~mask(:,:,1,1))=0;
    end

    namesB1 = {'Double Angle','Bloch-Siegert','AFI','EPI Double Angle',};
    timesB1 = {'4m38s/slice', '18s/slice', '11s/slice', '5s/slice'}
    namesT1 = {'Inversion Recovery','VFA - Stock Sequence - T1 Maps','VFA - Optimal Spoiling - T1 maps'};

    xFOV = (1:t1_hdr.info.dimensions(2))*t1_hdr.info.voxel_size(2);
    yFOV = (1:t1_hdr.info.dimensions(1))*t1_hdr.info.voxel_size(1);

    
    bottomB1 = 0.7;
    topB1 = 1.2;
    for ii = 1 : length(b1)
            b1{ii}(mask(:,:,1,1)==0)=0;
            if ii==1
                b1Row=imrotate(b1{ii},-90);    
            else
                b1Row=cat(2,b1Row,imrotate(b1{ii},-90));    
            end
    end

    bottom = 0.7;
    top = 1.2;

    for ii = 1:length(t1)
        if ii==1    
            t1Row=imrotate(t1{ii},-90);
        else
                t1Row=cat(2,t1Row,imrotate(t1{ii},-90));   
        end
 
    end
    
    
    xFOV = (1:t1_hdr.info.dimensions(2))*t1_hdr.info.voxel_size(2)*2;
    yFOV = (1:t1_hdr.info.dimensions(1))*t1_hdr.info.voxel_size(1)*4;
    figure()
    imagesc(yFOV,xFOV,cat(1,b1Row,t1Row))
    axis image
    caxis('manual') 
    caxis([bottomB1 topB1]);
    axis image
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    set(gca,'position',[0 0 1 1],'units','normalized')
end



end

