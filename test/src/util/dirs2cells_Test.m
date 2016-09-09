classdef (TestTags = {'Unit'}) dirs2cells_Test < matlab.unittest.TestCase

    properties
    end

    methods (TestClassSetup)
    end

    methods (TestClassTeardown)
    end

    methods (Test)
        function test_that_dirs2cells_doesnt_have_cur_or_parent_dir_in_output(testCase)
            cellsOfDirs = dirs2cells('.');
            
            for ii = 1:length(cellsOfDirs)
                assertFalse( strcmp(testCase, cellsOfDirs{ii},'.'  ) );
                assertFalse( strcmp(testCase, cellsOfDirs{ii},'..' ) );
            end
        end
    end

end

