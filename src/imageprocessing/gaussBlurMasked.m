function blurredImage = gaussBlurMasked(rawImage, maskImage, fwhmVal)
%GAUSSBLURMASKED Gaussian blur BW image in a masked ROI.
%
%   rawImage = 2d bw image;
%   rawMask  = 2d binary image of same dimensions as rawImage
%   fwhmVal  = Full width half max of desired gaussian kernel (in pixels)
%

    sigmaPixels = fwhm2sigma(fwhmVal);
    kernelFactor = 3; % We want the kernel grid to be at least three times the size of sigma to have enough coverage of the gaussian curve.

    filterKernel = fspecial('gaussian', ceil(sigmaPixels*kernelFactor), sigmaPixels);

    blurredImage = roifilt2(filterKernel, rawImage, maskImage);
end

