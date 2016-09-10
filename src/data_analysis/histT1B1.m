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
                reshapedT1{ii} = removeOutliersAndZeros(reshapedT1{ii}, [0.5 1.5]);
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
                reshapedB1{ii} = removeOutliersAndZeros(reshapedB1{ii}, [0.5 1.5]);
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

    plotHistogram(xT1, yFreq  , 'T_1 (s)'   , 'a.u.', b1Keys, colours);

    %% Plot figure B1
    %

    plotHistogram(xB1, yFreqB1, 'B_1 (n.u.)', 'a.u.', b1Keys, colours);

end

function plotHistogram(xData, yData, xLabel, yLabel, legendCells, lineColours)
%PLOTHISTOGRAM Plot histogram data and format figure.
%
%   --args--
%   xData: cells of the frequencies' xaxis values for each line.
%   yData: cells of the histogram frequencies to be plot for each line.
%   xLabel: string to be set as xlabel.
%   yLabel: string to be set as ylabel.
%   legendCells: cells of strings for the legend of the plot.
%   lineColours: M-by-3 matrix containing a "ColorOrder" colormap.
%
    h.figure = figure();
    h.axes   = gca;
    for ii=1:length(yData)
        plot(xData{ii},yData{ii}./sum(yData{ii}), '-', 'Color', lineColours(ii,:), 'LineWidth',4)
        hold on
    end

    h.xlabel=xlabel(xLabel);
    h.ylabel=ylabel(yLabel);

    % Remove underscores from legends, and make the cell array the legend
    legendCells = escapeUnderscores(legendCells);
    h.legend=legend(legendCells);

    plotFigureProperties(h);
end
