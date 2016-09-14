function [outlierMask] = generateOutlierMask(arraySeries, min_max, z_i_n_Flag, varargin)
%GENERATEOUTLIERMASK
%   arraySeries: cell array. Each cells must have same dimensions.
%   min_max: 1x2 array for minimum and maximum values to be masked out
%            [min max]
%   z_i_n_Flag: Logical flag for removal of (z)eros, (i)nfinities, and (n)ot-a-numbers
%   varargin{1}:
%           outlierPercDiff: percentage difference relative to first
%                            arraySeries entry to be removed (absolute
%                            value, so positive and negative sides)

    %% Input handling
    %

    if ~isempty(varargin)
        outlierPercDiff = varargin{1};
    end

    %% Verify that all cells in array series have the same dimensions.
    %

    numSeries = length(arraySeries);

    for seriesIndex = 2:numSeries % Each cell is compared with the first one, so numSeries-1 comparisons
        sameDimensionsFlag = isequal(size(arraySeries{1}), size(arraySeries{seriesIndex}));
        if sameDimensionsFlag == false
           error('generateOutlierMask:nonMatchingArrayDimensions', 'Error: each cell in arraySeries must have the same dimensions');
        end
    end

    %% Prepare outlier mask
    %

    % Initialize outlier mask to the same size of the array series,
    outlierMask = logical ( zeros(size( arraySeries{1} )) );

    %% Remove outside min-max range
    %
    minVal = min_max(1);
    maxVal = min_max(2);

    for seriesIndex = 1:numSeries
            outlierMask(       arraySeries{seriesIndex} < minVal ) = 1;
            outlierMask(       arraySeries{seriesIndex} > maxVal ) = 1;
    end

    %% Remove zeros, nan, & infinities
    %

    if z_i_n_Flag == true
        for seriesIndex = 1:numSeries
            outlierMask(       arraySeries{seriesIndex} == 0 ) = 1;
            outlierMask( isinf(arraySeries{seriesIndex})     ) = 1;
            outlierMask( isnan(arraySeries{seriesIndex})     ) = 1;
        end
    end

    %% Remove outliers relative to reference
    %
    if exist('outlierPercDiff', 'var')
        for seriesIndex = 2:numSeries % Each cell is compared with the first one, so numSeries-1 comparisons
            pDiff = abs( (arraySeries{1} - arraySeries{seriesIndex}) ...
                                        ./                           ...
                                  arraySeries{1}                    )...
                   .* 100;

            outlierMask(pDiff > abs(outlierPercDiff))          = 1;
        end
    end
end
