function imagecatFigureProperties(caxisRange, colormapChoice)
%IMAGECATFIGUREPROPERTIES Custom figure properties for concatenated images
%
%   --args--
%   caxisRange: array of size 2 containing [min max] of axis bar
%
%   colormapChoice: Name of default colormap to be used (e.g. jet, parula)
%
    caxis('manual')
    caxis(caxisRange);
    axis image
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    set(gca,'position',[0 0 1 1],'units','normalized')
    colormap(colormapChoice)
end