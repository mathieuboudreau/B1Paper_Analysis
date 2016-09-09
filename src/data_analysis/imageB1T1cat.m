function [] = imageB1T1cat(dataDir, b1t1FileOptions)
%imageB1T1cat ImageShow concatenated B1 & T1 maps
%
% --args--
% dataDir: String forentire path to directory containing the folders of
%          each subjects data.
%          Example usage: dataDir = [pwd '/data'];
%
% b1t1FileOptions: Cell containing the required information to use as
%          arguments for the generateStructB1T1Data function. See function
%          for format of each cells.
%          Example usage: b1t1FileOptions = {'b1_whole_brain/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'vfa_spoil'}

%%
%

subjectID = dirs2cells(dataDir);
s = generateStructB1T1Data(b1t1FileOptions{1}, b1t1FileOptions{2}, b1t1FileOptions{3}, b1t1FileOptions{4});

b1ID = s.b1Files;
t1ID = s.t1Files;

for counterSubject = 1:length(subjectID)
    % Pre-define variable types
    tmp_hdr = cell(0);
    t1      = cell(0);
    b1      = cell(0);

    for ii = 1:length(t1ID)
        [tmp_hdr{ii},t1{ii}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' t1ID{ii}]);
    end
    t1_hdr = tmp_hdr{1}; % legacy definition

    for ii = 1:length(t1ID)
        [~,b1{ii}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{ii}]);
    end

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

