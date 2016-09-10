function [] = histT1(dataDir, b1t1FileOptions)
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

    end

    %%
    %
    for ii=1:length(t1)

        for jj=1:length(subjectID)
            if jj==1
                  reshapedT1AllMethods{ii}= reshapedT1AllSubjects{jj,ii};
            else
                  reshapedT1AllMethods{ii} =  [reshapedT1AllMethods{ii};reshapedT1AllSubjects{jj,ii}];
            end
        end
    end

    %% Calculate histogram data
    %
    for ii=1:length(t1)
        [yFreq{ii},xT1{ii}]=hist(reshapedT1AllMethods{ii},80);
    end

    %% Plot figure
    %


    colours = lines;
    close(gcf) % lines creates an empty figure, so closing it here

    h_figure = figure();
    for ii=1:length(t1)
        plot(xT1{ii},yFreq{ii}./sum(yFreq{ii}), '-', 'Color', colours(ii,:), 'LineWidth',4)
        hold on
    end

    h_xlabel=xlabel('T1 (s)');
    h_ylabel=ylabel('a.u.');

    % Remove underscores from b1 keys, and make the cell array the b1 legend
    b1Legend = escapeUnderscores(b1Keys);
    h_legend=legend(b1Legend);

    set(h_figure, 'DefaultAxesBox', 'on', 'DefaultAxesLineWidth', 1.5);
    set(h_figure, 'DefaultAxesFontSize', 16, 'DefaultAxesFontWeight', 'bold');
    set(h_ylabel,'FontWeight', 'bold' , 'FontSize',18, 'FontName', 'Arial');
    set(h_xlabel,'FontWeight', 'bold' , 'FontSize',18, 'FontName', 'Arial');
    set(h_legend,'FontWeight', 'bold' , 'FontSize',16, 'FontName', 'Arial');

    end

