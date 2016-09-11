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
        plot(xData{ii},normalizeCurveArea(xData{ii}, yData{ii}), '-', 'Color', lineColours(ii,:), 'LineWidth',4)
        hold on
    end

    h.xlabel=xlabel(xLabel);
    h.ylabel=ylabel(yLabel);

    % Remove underscores from legends, and make the cell array the legend
    legendCells = escapeUnderscores(legendCells);
    h.legend=legend(legendCells);

    plotFigureProperties(h);
end