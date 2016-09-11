function [outputMat] = appendRow(inputMat, newRow)
%APPENDROW Summary of this function goes here
%
% --args--
% inputMat: 2D array, can be empty.
%
% newRow: can be cell or array type.
%
% --return--
% outputMat: 2D inputMat with newRow appended.
%

    numRows   = size(inputMat,1);
    outputMat = inputMat;

    if numRows == 0
        outputMat = newRow;
    else
        outputMat(numRows + 1, :) = newRow;
    end
end
