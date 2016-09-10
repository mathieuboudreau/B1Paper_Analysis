function plotFigureProperties(structHandler)
%PLOTFIGUREPROPERTIES Set custom figure properties for plots
%
%   --arg--
%   structHandler: a struct with the following attributes:
%                   .figure: figure handler
%                   .xlabel: xlabel handler
%                   .ylabel: ylabel handler
%                   .legend: ledend handler
%

    %% Define default properties
    %

    axesLineWidth    = 1.5;
    axesFontSize     = 16;

    labelFontWeight  = 18;
    legendFontWeight = 16;

    fontName         = 'Arial';

    %% Set properties
    %

    set(structHandler.figure, 'DefaultAxesBox', 'on', 'DefaultAxesLineWidth', axesLineWidth);
    set(structHandler.figure, 'DefaultAxesFontSize', axesFontSize, 'DefaultAxesFontWeight', 'bold');
    set(structHandler.xlabel,'FontWeight', 'bold' , 'FontSize', labelFontWeight , 'FontName', fontName);
    set(structHandler.ylabel,'FontWeight', 'bold' , 'FontSize', labelFontWeight , 'FontName', fontName);
    set(structHandler.legend,'FontWeight', 'bold' , 'FontSize', legendFontWeight, 'FontName', fontName);

end

