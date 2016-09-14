function [statsStruct] = plotScatter(xData, yData, axisLabels, titleName)
%PLOTSCATTER Plot scatter points data, and show linear regression & pearson
%corr data.
%   --args--
%   xData: 1D array of values to be scatterplotted
%   yData: 1D array of values to be scatterplotted
%   axisLabels: 1x2 cell aray containing strings for axis labels. xaxis is
%               cell 1, ylabel is cell 2.
%   titleName: string

    figure(),scatter(xData,yData)
    axis([0.5 2 0.5 2])
    xlabel(axisLabels{1},'fontweight','bold','fontsize',12)
    ylabel(axisLabels{2},'fontweight','bold','fontsize',12)
    p= polyfit(xData,yData,1);
    pearsCoeff=corr(xData, yData);
    annotation('textbox', [.2 .8, .1, .1],'String', [ {['y = ' num2str(p(1)) 'x + ' num2str(p(2))]} ; {['r2 = ' num2str(pearsCoeff^2)]}; {['Pearson Corr. Coeff = ' num2str(pearsCoeff)]}]);
    title(titleName,'fontweight','bold','fontsize',16)

    statsStruct.slope       = p(1);
    statsStruct.intercept   = p(2);
    statsStruct.pearsonCorr = pearsCoeff;
    statsStruct.r2          = pearsCoeff^2;

    statsStruct.ref  = axisLabels{1};
    statsStruct.name = axisLabels{2};
end

