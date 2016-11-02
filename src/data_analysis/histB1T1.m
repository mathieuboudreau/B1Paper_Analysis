function [] = histB1T1(dataDir, b1t1FileOptions, b1t1OutlierMinMax)
%HISTB1T1 Plots T1 and B1 value histograms of pooled subject data.
%
%   Example usage: histB1T1([pwd '/data'], {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'vfa_spoil'}, {[0.5 1.5],[0.5 1.5]})
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
% b1t1OutlierMinMax: 1x2 cell array containing 1x2 double arrays (e.g [min max])
%                    Element 1 is the [min max] for outlier dumping for T1 data
%                    Element 2 is the [min max] for outlier dumping for b1 data
%                    Example usage: b1t1OutlierMinMax = {[0.5 1.5], [0.5 1.5]}
    %% Setup file information
    %

    subjectID = dirs2cells(dataDir);

    s = generateStructB1T1Data(b1t1FileOptions{1}, b1t1FileOptions{2}, b1t1FileOptions{3}, b1t1FileOptions{4});
    b1Keys = b1t1FileOptions{3}; % shorthand names of the b1 methods
    b1ID = s.b1Files;
    t1ID = s.t1Files;

    numB1 = size(b1ID,2); % Number of B1 methods compared, e.g. number of curves to be displayed in the hist plots.
    numSubjects = size(subjectID,1);

    t1OutlierRange = cell2mat(b1t1OutlierMinMax(1));
    b1OutlierRange = cell2mat(b1t1OutlierMinMax(2));
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
        %% Get images data for this subject
        %

        % Initialize temps for images
        t1      = cell(0);
        b1      = cell(0);

        for counterB1 = 1:numB1
            [~,t1{counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' t1ID{counterB1}]);
            [~,b1{counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{counterB1}]);
        end

        %% Store data in table & remove outliers and zeros
        %

        % Initialize cells
        tmp_t1data_row = cell(1,numB1);
        tmp_b1data_row = cell(1,numB1);

        for counterB1=1:numB1
            tmp_t1data_row{counterB1} = t1{counterB1}(:);
            tmp_t1data_row{counterB1} = removeOutliersAndZeros(tmp_t1data_row{counterB1}, t1OutlierRange);

            tmp_b1data_row{counterB1} = b1{counterB1}(:);
            tmp_b1data_row{counterB1} = removeOutliersAndZeros(tmp_b1data_row{counterB1}, b1OutlierRange);
        end

        allData_t1 = appendRow(allData_t1, tmp_t1data_row);
        allData_b1 = appendRow(allData_b1, tmp_b1data_row);

        %% Clear variables
        %

        clear tmp_t1data_row
        clear tmp_b1data_row

        clear t1
        clear b1
    end

    %% Pool subject image data
    %

    for counterB1=1:numB1
        pooledSubjectData_t1{counterB1} = cell2mat(allData_t1(:,counterB1));
        pooledSubjectData_b1{counterB1} = cell2mat(allData_b1(:,counterB1));
    end

    %% Calculate histogram data
    %

    % Initialize cell arrays
    yFreqT1 = cell(1,numB1);
    yFreqB1 = cell(1,numB1);

    xT1     = cell(1,numB1);
    xB1     = cell(1,numB1);

    for counterB1=1:numB1
        [yFreqT1{counterB1},xT1{counterB1}]=hist(pooledSubjectData_t1{counterB1},40);
        [yFreqB1{counterB1},xB1{counterB1}]=hist(pooledSubjectData_b1{counterB1},40);
    end

    %% Plot histograms
    %

    colours = lines;

    plotHistogram(xT1, yFreqT1, 'T_1 (s)'   , 'Normalized frequency (s^{-1})', b1Keys, colours);
    plotHistogram(xB1, yFreqB1, 'B_1 (n.u.)', 'Normalized frequency (n.u.)', b1Keys, colours);

end
