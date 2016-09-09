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
        t1      = cell(0);
        b1      = cell(0);

        for ii = 1:length(t1ID)
            [~,t1{ii}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' t1ID{ii}]);
        end

        for ii = 1:length(t1ID)
            [~,b1{ii}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{ii}]);
        end

        [~,mask] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/mask/mask.mnc']);

        %%
        for ii = 1 : length(b1)
                b1{ii}(mask(:,:,1,1)==0)=0;
                if ii==1
                    b1Row=imrotate(b1{ii},-90);
                else
                    b1Row=cat(2,b1Row,imrotate(b1{ii},-90));
                end
        end

        for ii = 1:length(t1)
            t1{ii}(~mask(:,:,1,1))=0;
            if ii==1
                t1Row=imrotate(t1{ii},-90);
            else
                t1Row=cat(2,t1Row,imrotate(t1{ii},-90));
            end

        end

        bottomB1 = 0.7;
        topB1 = 1.2;

        figure(100*(counterSubject) + 1)
        imagesc(b1Row)
        caxis('manual')
        caxis([bottomB1 topB1]);
        axis image
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        set(gca,'position',[0 0 1 1],'units','normalized')
        colormap(jet)

        bottomT1 = 0.5;
        topT1 = 1.5;
        figure(100*(counterSubject) + 2)
        imagesc(t1Row)
        caxis('manual')
        caxis([bottomT1 topT1]);
        axis image
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        set(gca,'position',[0 0 1 1],'units','normalized')
    end


end

