classdef (TestTags = {'Unit', 'util'}) concatImages_Test < matlab.unittest.TestCase

    properties
    end

    methods (TestClassSetup)
    end

    methods (TestClassTeardown)
    end

    methods (Test)
        function test_concatImages_that_known_case_matches_expected_behaviour(testCase)
            unrotatedImageCells = {[1 2; 5 6], [3 4 ;7 8]};
            imageCells = {imrotate(unrotatedImageCells{1}, 90), imrotate(unrotatedImageCells{2}, 90)};
            mask = ones(2);

            actualOutput = concatImages(imageCells, mask, -90);

            expectedOutput = [1 2 3 4; 5 6 7 8];

            testCase.assertEqual(actualOutput, expectedOutput)

        end
    end

end

