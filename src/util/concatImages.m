function [imageRow] = concatImages(imageCells, mask, rotateAngle)
%concatImage Concat images in cell array to form a row.
%   Example usage: b1Row = concatImage(b1, squeeze(mask(:,:,1,1)), -90);
%
%   --args--
%   imageCells: cell of 2D arrays representing images. Each cell must have
%               the same dimensions.
%
%   mask: array of 2D logical values to mask out image data. Must be same
%         dims as each imageCells cells.
%
%   rotateAngle: double or in used to rotate each images individually
%
%   --return--
%   imageRow: array of 2D values representing concatenated values of
%             imageCells data.
%

    for ii = 1:length(imageCells)
        imageCells{ii}(mask(:,:)==0)=0;
        if ii==1
            imageRow=imrotate(imageCells{ii},rotateAngle);
        else
            imageRow=cat(2,imageRow,imrotate(imageCells{ii},rotateAngle));
        end
    end

end
