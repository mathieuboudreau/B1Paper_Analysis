function [statsStructB1, statsStructT1] = linregressB1T1(dataDir, b1t1FileOptions)
%LINREGRESST1 Perform regression analysis, plot respective scatterplots,
%and plot histograms of percent differences (voxelwise) between methods and
%the reference.
%
% Example usage: [statsStructB1, statsStructT1] = linregressB1T1([pwd '/data'], {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'gre'})
%                                                                                               **The first
%                                                                                               entry, e.g.
%                                                                                               clt_da, will be
%                                                                                               the reference
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
% --return--
% statsStructB1 and statsStructT1: Linear regressions statistics structure.
%                  --Attributes--
%                  ref: Name of reference method
%                  name: Name of method-of-interest
%                  slope: Linear fit slope value
%                  intercept: Linear fit y-intercept value
%                  pearsonCorr: Pearson correlation coefficient
%                  r2: r-square value
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
    pooledSubjectData_b1  = cell(0);

    %% Load all data into cell array
    %

    for counterSubject = 1:numSubjects
        for counterB1 = 1:numB1
            [~,allData_t1{counterSubject, counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' t1ID{counterB1}]);
            [~,allData_b1{counterSubject, counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{counterB1}]);
        end
    end

    %% Pool subject data
    %

    for counterB1 = 1:numB1
        pooledSubjectData_t1{counterB1}=[allData_t1{1,counterB1}(:);allData_t1{2,counterB1}(:);allData_t1{3,counterB1}(:);allData_t1{4,counterB1}(:);allData_t1{5,counterB1}(:);allData_t1{6,counterB1}(:)];
        pooledSubjectData_b1{counterB1}=[allData_b1{1,counterB1}(:);allData_b1{2,counterB1}(:);allData_b1{3,counterB1}(:);allData_b1{4,counterB1}(:);allData_b1{5,counterB1}(:);allData_b1{6,counterB1}(:)];
    end

    %% Remove outliers and zeros/nan/infs
    %

    outlierMaskT1 = generateOutlierMask(pooledSubjectData_t1, [0.5 1.5], 1, 60);
    outlierMaskB1 = generateOutlierMask(pooledSubjectData_b1, [0.5 1.5], 1, 60);

    reshapedT1_scatter = cell(1,numB1);
    reshapedB1_scatter = cell(1,numB1);

    for counterB1 = 1:numB1
        reshapedT1_scatter{counterB1}=pooledSubjectData_t1{counterB1};
        reshapedT1_scatter{counterB1}(outlierMaskT1)=[];

        reshapedB1_scatter{counterB1}=pooledSubjectData_b1{counterB1};
        reshapedB1_scatter{counterB1}(outlierMaskB1)=[];
    end

    %% Scatterplots
    %

    statsStructT1 = cell(1,numB1-1);
    statsStructB1 = cell(1,numB1-1);

    for counterB1 = 2:numB1
        statsStructT1{counterB1-1} = plotScatter(reshapedT1_scatter{1}, reshapedT1_scatter{counterB1}, {namesB1{1}, namesB1{counterB1}}, 'VFA T1 (s)');
        statsStructB1{counterB1-1} = plotScatter(reshapedB1_scatter{1}, reshapedB1_scatter{counterB1}, {namesB1{1}, namesB1{counterB1}}, 'VFA B1 (s)');
    end

    %% Prepare percent difference histogram data
    %

    % Initialize cell arrays
    yFreqT1 = cell(1,numB1-1); % Since these are percent differences relative to a reference, one less cell is required.
    yFreqB1 = cell(1,numB1-1); % Since these are percent differences relative to a reference, one less cell is required.

    xT1     = cell(1,numB1-1);
    xB1     = cell(1,numB1-1);

    pDiffT1   = cell(1,numB1-1);
    pDiffB1   = cell(1,numB1-1);

    for counterB1 = 2:numB1
        pDiffT1{counterB1-1} = (reshapedT1_scatter{1} - reshapedT1_scatter{counterB1})./reshapedT1_scatter{1}.*100;
        [yFreqT1{counterB1-1},xT1{counterB1-1}]=hist(pDiffT1{counterB1-1},40);

        pDiffB1{counterB1-1} = (reshapedB1_scatter{1} - reshapedB1_scatter{counterB1})./reshapedB1_scatter{1}.*100;
        [yFreqB1{counterB1-1},xB1{counterB1-1}]=hist(pDiffB1{counterB1-1},40);
    end

    %% Plot percent difference histograms
    %

    colours = lines;

    plotHistogram(xT1, yFreqT1, 'T_1 (s)'   , 'a.u.', b1Keys(2:end), colours(2:end,:));
    plotHistogram(xB1, yFreqB1, 'B_1 (s)'   , 'a.u.', b1Keys(2:end), colours(2:end,:));

end
