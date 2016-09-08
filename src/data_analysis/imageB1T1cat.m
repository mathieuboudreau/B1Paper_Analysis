function [] = imageB1T1cat()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

subjectID{1}='arseneault_ryan_20131015_140558';
subjectID{2}='caissie_jessica_20131015_152703';
subjectID{3}='mazerolle_erin_20131016_152802';
subjectID{4}='stikov_nikola_20131017_113942';
subjectID{5}='collette_marc_20131024_093735';
subjectID{6}='alonso_eva_20131025_141318';


%%

for counterSubject = 1:length(subjectID)
    [t1_hdr,t1{1}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_tse_ir.mnc']);
    [~,t1{2}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_tse.mnc']);
    [~,t1{3}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_bs.mnc']);
    [~,t1{4}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_afi.mnc']);
    [~,t1{5}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_epseg_da.mnc']);



    [~,b1{1}] = niak_read_minc([subjectID{counterSubject} '/b1_whole_brain/b1_clt_tse.mnc']);
    [~,b1{2}] = niak_read_minc([subjectID{counterSubject} '/b1_whole_brain/b1_clt_gre_bs_cr_fermi.mnc']);
    [~,b1{3}] = niak_read_minc([subjectID{counterSubject} '/b1_whole_brain/b1_clt_afi.mnc']);
    [~,b1{4}] = niak_read_minc([subjectID{counterSubject} '/b1_whole_brain/b1_epseg_da.mnc']);

    [~,mask] = niak_read_minc([subjectID{counterSubject} '/mask/mask.mnc']);

    %%
    for ii=1:length(t1)
        t1{ii}(~mask(:,:,1,1))=0;
    end

    namesB1 = {'Double Angle','Bloch-Siegert','AFI','EPI Double Angle',};
    timesB1 = {'4m38s/slice', '18s/slice', '11s/slice', '5s/slice'}
    namesT1 = {'Inversion Recovery','VFA - Stock Sequence - T1 Maps','VFA - Optimal Spoiling - T1 maps'};

    xFOV = (1:t1_hdr.info.dimensions(2))*t1_hdr.info.voxel_size(2);
    yFOV = (1:t1_hdr.info.dimensions(1))*t1_hdr.info.voxel_size(1);

    
    figure()
    bottomB1 = 0.7;
    topB1 = 1.2;
    for ii = 1 : length(b1)
            b1{ii}(mask(:,:,1,1)==0)=0;
            subplot(2,5,1+ii)
            imagesc(yFOV,xFOV,imrotate(b1{ii},-90))    
            caxis('manual') 
            caxis([bottomB1 topB1]);
            axis image
    end

    bottom = 0.7;
    top = 1.2;

    for ii = 1:length(t1)

            subplot(2,5,length(t1)+ii)
            imagesc(yFOV,xFOV,imrotate(t1{ii},-90))    
            caxis('manual') 
            caxis([bottom top]);
            axis image

    end



    subplot(2,5,2)
    title({['B1 - ' namesB1{1}];timesB1{1}},'fontweight','bold','fontsize',16)

    subplot(2,5,3)
    title({['B1 - ' namesB1{2}];timesB1{2}},'fontweight','bold','fontsize',16)

    subplot(2,5,4)
    title({['B1 - ' namesB1{3}];timesB1{3}},'fontweight','bold','fontsize',16)

    subplot(2,5,5)
    title({['B1 - ' namesB1{4}];timesB1{4}},'fontweight','bold','fontsize',16)

    subplot(2,5,6)
    title(namesT1{1},'fontweight','bold','fontsize',16)

    subplot(2,5,7)
    title(['VFA - ' namesB1{1}],'fontweight','bold','fontsize',16)

    subplot(2,5,8)
    title(['VFA - ' namesB1{2}],'fontweight','bold','fontsize',16)

    subplot(2,5,9)
    title(['VFA - ' namesB1{3}],'fontweight','bold','fontsize',16)

    subplot(2,5,10)
    title(['VFA - ' namesB1{4}],'fontweight','bold','fontsize',16)


end

end

