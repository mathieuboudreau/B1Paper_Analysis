function [normArea_yData] = normalizeCurveArea(xData, yData)
%NORMALIZECURVEAREA Normalize the curve data (yData) area in relation to
%the x-axis (xData)

    normArea_yData = yData./trapz(xData,yData);

end
