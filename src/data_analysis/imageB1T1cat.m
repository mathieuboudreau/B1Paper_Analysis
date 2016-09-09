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

    %% Setup file information
    %

    subjectID = dirs2cells(dataDir);
    s = generateStructB1T1Data(b1t1FileOptions{1}, b1t1FileOptions{2}, b1t1FileOptions{3}, b1t1FileOptions{4});

    b1ID = s.b1Files;
    t1ID = s.t1Files;

    %% Loop each subject
    %

    for counterSubject = 1:length(subjectID)
        %% Get images data for this subject
        %

        % Pre-define variable typs
        t1      = cell(0);
        b1      = cell(0);

        for ii = 1:length(t1ID)
            [~,t1{ii}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' t1ID{ii}]);
        end

        for ii = 1:length(t1ID)
            [~,b1{ii}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{ii}]);
        end

        [~,mask] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/mask/mask.mnc']);

        %% Concat image sets
        %

        b1Row = concatImages(b1, squeeze(mask(:,:,1,1)), -90);

        t1Row = concatImages(t1, squeeze(mask(:,:,1,1)), -90);

        %% Plot images
        %

        caxisRangeB1 = [0.7 1.2];
        figure(100*(counterSubject) + 1)
        imagesc(b1Row)
        imagecatFigureProperties(caxisRangeB1, jet)

        caxisRangeT1 = [0.5 1.5];
        figure(100*(counterSubject) + 2)
        imagesc(t1Row)
        imagecatFigureProperties(caxisRangeT1, parula)
    end


end
