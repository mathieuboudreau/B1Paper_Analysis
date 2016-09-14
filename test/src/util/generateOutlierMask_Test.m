classdef (TestTags = {'Unit', 'util'}) generateOutlierMask_Test < matlab.unittest.TestCase

    properties
    end

    methods (TestClassSetup)
    end

    methods (TestClassTeardown)
    end

    methods (Test)
        function test_generateOutlierMask_different_array_size_error(testCase)
            min_max    = [-100 100];

            inputCellArray = {[1 2 3 4 5], [1 2 3 4]};

            testCase.assertError(@() generateOutlierMask(inputCellArray, min_max, 0), 'generateOutlierMask:nonMatchingArrayDimensions');
        end

        function test_generateOutlierMask_min_max(testCase)
            min_max    = [-100 100];

            inputCellArray = {[1 1 1 1 1],[200 1 1 -101 100]};

            expectedOutput = logical([1 0 0 1 0]);

            actualOutput = generateOutlierMask(inputCellArray, min_max, 0);

            testCase.assertEqual(actualOutput, expectedOutput);
        end

        function test_generateOutlierMask_zeros(testCase)
            min_max    = [-100 100];

            inputCellArray = {[1 1 1 1 1],[1 0 1 0 1]};

            expectedOutput = logical([0 1 0 1 0]);

            actualOutput = generateOutlierMask(inputCellArray, min_max, 1);

            testCase.assertEqual(actualOutput, expectedOutput);
        end

        function test_generateOutlierMask_infinities(testCase)
            min_max    = [-100 100];

            inputCellArray = {[1 1 1 1 1],[Inf 1 1 -Inf 1/0]};

            expectedOutput = logical([1 0 0 1 1]);

            actualOutput = generateOutlierMask(inputCellArray, min_max, 1);

            testCase.assertEqual(actualOutput, expectedOutput);
        end

        function test_generateOutlierMask_NaNs(testCase)
            min_max    = [-100 100];

            inputCellArray = {[1 1 1 1 1],[1 NaN 1 ((+Inf) + (-Inf)) 0/0]};

            expectedOutput = logical([0 1 0 1 1]);

            actualOutput = generateOutlierMask(inputCellArray, min_max, 1);

            testCase.assertEqual(actualOutput, expectedOutput);
        end

        function test_generateOutlierMask_outlier_percDiff(testCase)
            min_max    = [-100 100];
            pDiff      = 60; % Percent diff, relative to first cell array

            inputCellArray = {[1 1 1 1 1],[1 1.5 1.61 0.39 0.4]};

            expectedOutput = logical([0 0 1 1 0]);

            actualOutput = generateOutlierMask(inputCellArray, min_max, 0, pDiff);

            testCase.assertEqual(actualOutput, expectedOutput);
        end
    end

end

