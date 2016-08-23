function mincResampleAndAlign(mincSource, ref, mincDestination, blurSize)

% function mincResampleAndAlign(mincSource, ref, mincDestination)
% ---------------------------------------------------------------
% INPUTS:
% -------
% mincSource: a .mnc file that needs to be resampled to ref
% ref: a .mnc file that serves as a reference
% mincDestination: a .mnc file that is a resampled and realigned copy of
% mincSource
% blurSize: if downsampling, the 3D size of the downsampled voxel
% ----------
% Example: mincResampleAndAlign('file.mnc', 'ref.mnc', 'resampledFile.mnc', [2 2 5])

if (nargin > 3)
    eval(['!mincblur -clobber -3dfwhm ' num2str(blurSize(1)) ' ' num2str(blurSize(2)) ' ' num2str(blurSize(3)) ' ' mincSource ' test']);
    %eval(['!minctracc -clob -identity -mi ' mincSource ' ' ref ' -lsq6 -debug -threshold 30 5 transform.xfm -simplex 1 -clobber']);
    eval(['!minctracc -clob -identity -mi ' mincSource ' ' ref ' -lsq6 -debug transform.xfm -simplex 1 -clobber']);
    eval(['!mincresample -clob -transformation transform.xfm test_blur.mnc -use_input_sampling ' mincDestination]);
    % eval(['!mincresample -like ' ref ' test_blur.mnc ' mincDestination ]);
else
    %eval(['!minctracc -clob -identity -mi ' mincSource ' ' ref ' -lsq6 -debug -threshold 30 5 transform.xfm -simplex 1 -clobber']);
    eval(['!minctracc -clob -identity -mi ' mincSource ' ' ref ' -lsq6 -debug transform.xfm -simplex 1 -clobber']);
    imvalid = false;
    while(~imvalid)
        eval(['!mincresample -clob -transformation transform.xfm ' mincSource ' -use_input_sampling ' mincDestination]);
        [~,medianValue]=system(['mincstats -median ' mincDestination ' | grep Median']);
        medianValue = str2double(medianValue(19:end));
        if(abs(medianValue)>1e+40)
            imvalid = false;
        elseif (isnan(medianValue))
             imvalid = false;
        else
            imvalid = true;
        end
    end
end

%eval(['!mincresample -like ' ref ' ' mincSource ' ' mincDestination ]);

