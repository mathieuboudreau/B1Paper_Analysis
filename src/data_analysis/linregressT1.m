function [] = linregressT1(dataDir, b1t1FileOptions)
%LINREGRESST1 Summary of this function goes here
%
% Example usage: linregressT1([pwd '/data'], {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'vfa_spoil'})
%
% --args--
% dataDir: String for entire path to directory containing the folders of
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
    b1Keys = b1t1FileOptions{3}; % shorthand names of the b1 methods
    b1ID = s.b1Files;
    t1ID = s.t1Files;

    numB1 = size(b1ID,2); % Number of B1 methods compared, e.g. number of curves to be displayed in the hist plots.
    numSubjects = size(subjectID,1);

    namesB1 = escapeUnderscores(b1Keys);

    %% Load all data into cell array
    %
    % Initialize temps for images
    t1      = cell(0);
    b1      = cell(0);
    for counterSubject = 1:numSubjects
        for counterB1 = 1:numB1
            [~,t1{counterSubject, counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' t1ID{counterB1}]);
            [~,b1{counterSubject, counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{counterB1}]);
        end
    end

    %%
    %

    for ii=1:4
        t1_scatter{ii}=[t1{1,ii}(:);t1{2,ii}(:);t1{3,ii}(:);t1{4,ii}(:);t1{5,ii}(:);t1{6,ii}(:)];
    end

    allzeros=(t1_scatter{1}==0)&(t1_scatter{2}==0)&(t1_scatter{3}==0)&(t1_scatter{4}==0);

    for ii=1:length(t1_scatter)
        reshapedT1_scatter{ii}=t1_scatter{ii};
        reshapedT1_scatter{ii}(allzeros)=[];

        %reshapedT1_scatter{ii}(reshapedT1_scatter{ii}>1.5)=[];
        %reshapedT1_scatter{ii}(reshapedT1_scatter{ii}<0.5)=[];
    end

    %% Scatterplots
    %

    for counterB1 = 2:numB1
        plotScatter(reshapedT1_scatter{1}, reshapedT1_scatter{counterB1}, {namesB1{1}, namesB1{counterB1}}, 'VFA T1 (s)');
    end

end
