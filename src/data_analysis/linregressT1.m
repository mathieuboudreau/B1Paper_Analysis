function [] = linregressT1(dataDir, b1t1FileOptions)
%LINREGRESST1 Summary of this function goes here
%
% Example usage: linregressT1([pwd '/data'], {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'vfa_spoil'})
%                                                           **The first
%                                                           entry, e.g.
%                                                           clt_da, will be
%                                                           the reference
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

    %% Initialize cell arrays
    %

    % allData columns are for each B1 methods, rows are for each subjects.
    allData_t1 = cell(0);
    allData_b1 = cell(0);

    % pooled data columns are for each B1 methods
    pooledSubjectData_t1  = cell(0);

    %% Load all data into cell array
    %

    for counterSubject = 1:numSubjects
        for counterB1 = 1:numB1
            [~,allData_t1{counterSubject, counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' t1ID{counterB1}]);
            [~,allData_b1{counterSubject, counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{counterB1}]);
        end
    end

    %%
    %

    for ii=1:4
        pooledSubjectData_t1{ii}=[allData_t1{1,ii}(:);allData_t1{2,ii}(:);allData_t1{3,ii}(:);allData_t1{4,ii}(:);allData_t1{5,ii}(:);allData_t1{6,ii}(:)];
    end

    allzeros=(pooledSubjectData_t1{1}==0)&(pooledSubjectData_t1{2}==0)&(pooledSubjectData_t1{3}==0)&(pooledSubjectData_t1{4}==0);

    for ii=1:length(pooledSubjectData_t1)
        reshapedT1_scatter{ii}=pooledSubjectData_t1{ii};
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
