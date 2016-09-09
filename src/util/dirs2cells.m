function [cellsOfDirs] = dirs2cells(parentDir)
%DIRS2CELLS Generates a cell array containing the names of all the
%directories in the specified parent directory.
%
%   --args--
%   parentDir: String of parent directory to be scanned for list of dirs
%
%   --return--
%   cellsOfDirs: Cell array of strings of each directory in the specified
%                parent dir.
%
    dirsIgnore = {'.',  ...
                  '..'};
    
    parentList = dir(parentDir);
    
    
    cellsOfDirs = cell(0);
    for ii = 1:length(parentList)
        
        % Get items that are directories
        if parentList(ii).isdir

          % Ignore specified directories
              if ~any(strcmp(genRSC(parentList(ii).name, length(dirsIgnore)), dirsIgnore))
                  
                  % Append valid directory name to the output cell
                  cellsOfDirs{length(cellsOfDirs) + 1, 1} = parentList(ii).name;
              end

        end

    end

end

function outputCells = genRSC(stringName, len)
             %genRepeatStringCells
    outputCells = cell(1,len);
    
    for ii = 1:len
        outputCells{ii} = stringName;
    end
end