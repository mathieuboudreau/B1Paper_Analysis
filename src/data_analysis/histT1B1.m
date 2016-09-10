function [] = histT1B1(dataDir, b1t1FileOptions)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
% --args--
% dataDir: String forentire path to directory containing the folders of
%          each subjects data.
%          Example usage: dataDir = [pwd '/data'];
%
% b1t1FileOptions: Cell containing the required information to use as
%          arguments for the generateStructB1T1Data function. See function
%          for format of each cells.
%          Example usage: b1t1FileOptions = {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'vfa_spoil'}
%
    %% Setup file information
    %

    subjectID = dirs2cells(dataDir);

    s = generateStructB1T1Data(b1t1FileOptions{1}, b1t1FileOptions{2}, b1t1FileOptions{3}, b1t1FileOptions{4});
    b1Keys = b1t1FileOptions{3};
    b1ID = s.b1Files;
    t1ID = s.t1Files;

    %%
    %
    reshapedT1AllMethods=[];
    reshapedT1AllSubjects=[];

    reshapedB1AllMethods=[];
    reshapedB1AllSubjects=[];

    %%
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

        %% T1
        %

        % Pre-allocate cells
        reshapedT1 = cell(1,length(t1));
        yFreq = cell(1,length(t1));
        xT1 = cell(1,length(t1));

        for ii=1:length(t1)
                reshapedT1{ii} = t1{ii}(:);
                reshapedT1{ii}(reshapedT1{ii}==0)=[];
                reshapedT1{ii}(reshapedT1{ii}>1.5)=[];
                reshapedT1{ii}(reshapedT1{ii}<0.5)=[];
        end


        reshapedT1AllSubjects=[reshapedT1AllSubjects;reshapedT1];

        %% B1
        %

        % Pre-allocate cells
        reshapedB1 = cell(1,length(b1));
        yFreqB1 = cell(1,length(b1));
        xB1 = cell(1,length(b1));

        for ii=1:length(b1)
                reshapedB1{ii} = b1{ii}(:);
                reshapedB1{ii}(reshapedB1{ii}==0)=[];
                reshapedB1{ii}(reshapedB1{ii}>1.5)=[];
                reshapedB1{ii}(reshapedB1{ii}<0.5)=[];
        end


        reshapedB1AllSubjects=[reshapedB1AllSubjects;reshapedB1];

    end

    %% T1
    %
    for ii=1:length(t1)

        for jj=1:length(subjectID)
            if jj==1
                  reshapedT1AllMethods{ii} = reshapedT1AllSubjects{jj,ii};
            else
                  reshapedT1AllMethods{ii} =  [reshapedT1AllMethods{ii};reshapedT1AllSubjects{jj,ii}];
            end
        end
    end

    %% B1
    %

    for ii=1:length(b1)

        for jj=1:length(subjectID)
            if jj==1
                  reshapedB1AllMethods{ii} = reshapedB1AllSubjects{jj,ii};
            else
                  reshapedB1AllMethods{ii} =  [reshapedB1AllMethods{ii};reshapedB1AllSubjects{jj,ii}];
            end
        end
    end

    %% Calculate histogram data
    %
    for ii=1:length(t1)
        [yFreq{ii}  ,xT1{ii}]=hist(reshapedT1AllMethods{ii},80);
    end

    for ii=1:length(b1)
        [yFreqB1{ii},xB1{ii}]=hist(reshapedB1AllMethods{ii},40);
    end
    %% Plot figure T1
    %

    colours = lines;
    close(gcf) % lines creates an empty figure, so closing it here

    h.figure = figure();
    h.axes   = gca;
    for ii=1:length(t1)
        plot(xT1{ii},yFreq{ii}./sum(yFreq{ii}), '-', 'Color', colours(ii,:), 'LineWidth',4)
        hold on
    end

    h.xlabel=xlabel('T_1 (s)');
    h.ylabel=ylabel('a.u.');

    % Remove underscores from b1 keys, and make the cell array the b1 legend
    b1Legend = escapeUnderscores(b1Keys);
    h.legend=legend(b1Legend);

    plotFigureProperties(h);

    %% Plot figure B1
    %

    h.figure = figure();
    h.axes   = gca;
    for ii=1:length(b1)
        plot(xB1{ii},yFreqB1{ii}./sum(yFreqB1{ii}), '-', 'Color', colours(ii,:), 'LineWidth',4)
        hold on
    end

    h.xlabel=xlabel('B_1 (n.u.)');
    h.ylabel=ylabel('a.u.');

    % Remove underscores from b1 keys, and make the cell array the b1 legend
    b1Legend = escapeUnderscores(b1Keys);
    h.legend=legend(b1Legend);

    plotFigureProperties(h);

    end
