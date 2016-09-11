function [] = histT1B1(dataDir, b1t1FileOptions)
%HISTT1B1 Summary of this function goes here
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

    numB1 = size(b1ID,2); % Number of B1 methods compared, e.g. number of curves to be displayed in the hist plots.

    %% Initialize cell arrays
    %

    reshapedT1AllMethods  = cell(0);
    reshapedT1AllSubjects = cell(0);

    reshapedB1AllMethods  = cell(0);
    reshapedB1AllSubjects = cell(0);

    %% Load all data into cell array
    %

    for counterSubject = 1:length(subjectID)
        %% Get images data for this subject
        %

        % Pre-define variable types
        t1      = cell(0);
        b1      = cell(0);

        for counterB1 = 1:numB1
            [~,t1{counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' t1ID{counterB1}]);
            [~,b1{counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{counterB1}]);
        end

        %% T1
        %

        % Pre-allocate cells
        tmp_t1data_row = cell(1,numB1);
        tmp_b1data_row = cell(1,numB1);

        for counterB1=1:numB1
            tmp_t1data_row{counterB1} = t1{counterB1}(:);
            tmp_t1data_row{counterB1} = removeOutliersAndZeros(tmp_t1data_row{counterB1}, [0.5 1.5]);

            tmp_b1data_row{counterB1} = b1{counterB1}(:);
            tmp_b1data_row{counterB1} = removeOutliersAndZeros(tmp_b1data_row{counterB1}, [0.5 1.5]);
        end

        reshapedT1AllSubjects = appendRow(reshapedT1AllSubjects, tmp_t1data_row);
        reshapedB1AllSubjects = appendRow(reshapedB1AllSubjects, tmp_b1data_row);

        clear tmp_t1data_row
        clear tmp_b1data_row
    end

    %% Pool subjects (T1 data)
    %

    for counterB1=1:numB1
        reshapedT1AllMethods{counterB1} = cell2mat(reshapedT1AllSubjects(:,counterB1));
        reshapedB1AllMethods{counterB1} = cell2mat(reshapedB1AllSubjects(:,counterB1));
    end

    %% Calculate histogram data
    %

    % Initialize cell arrays
    yFreqT1 = cell(1,numB1);
    yFreqB1 = cell(1,numB1);

    xT1     = cell(1,numB1);
    xB1     = cell(1,numB1);

    for counterB1=1:numB1
        [yFreqT1{counterB1},xT1{counterB1}]=hist(reshapedT1AllMethods{counterB1},80);
        [yFreqB1{counterB1},xB1{counterB1}]=hist(reshapedB1AllMethods{counterB1},40);
    end

    %% Plot histograms
    %

    colours = lines;
    close(gcf) % lines creates an empty figure, so closing it here

    plotHistogram(xT1, yFreqT1, 'T_1 (s)'   , 'a.u.', b1Keys, colours);
    plotHistogram(xB1, yFreqB1, 'B_1 (n.u.)', 'a.u.', b1Keys, colours);

end
