function [outputArray] = removeOutliersAndZeros(inputArray, min_max)
%removeOutliersAndZeros Remove outliers and zeros from array.
%
%   --args--
%   inputArray: array of numbers.
%   min_max: 1x2 array in the format of [min max]

    minVal = min_max(1);
    maxVal = min_max(2);
    outputArray = inputArray;

    outputArray(outputArray == 0     ) = [];
    outputArray(outputArray <  minVal) = [];
    outputArray(outputArray >  maxVal) = [];
end

