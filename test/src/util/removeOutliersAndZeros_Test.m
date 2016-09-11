classdef (TestTags = {'Unit', 'util'}) removeOutliersAndZeros_Test < matlab.unittest.TestCase

    properties
    end

    methods (TestClassSetup)
    end

    methods (TestClassTeardown)
    end

    methods (Test)
        function test_removeOutliersAndZeros_example_case_for_expected_behavior(testCase)
            min_max    = [-100 100];

            inputArray = [0 0 0 1 100.1 -100.1 1 3 5 0 100 -100];

            expectedOutput = [1 1 3 5 100 -100];

            actualOutput = removeOutliersAndZeros(inputArray, min_max);

            testCase.assertEqual(expectedOutput, actualOutput);
        end

    end

end

