classdef (TestTags = {'Unit', 'util'}) appendRow_Test < matlab.unittest.TestCase

    properties
    end

    methods (TestClassSetup)
    end

    methods (TestClassTeardown)
    end

    methods (Test)
        function test_appendRow_with_empty_initial_array_with_input_array_row(testCase)
            initialArray = [];
            inputRow     = [1 2 3 4];
            expectedOutput = [1 2 3 4];

            actualOutput = appendRow(initialArray, inputRow);

            testCase.assertEqual(actualOutput, expectedOutput);
        end

        function test_appendRow_with_filled_initial_array_with_input_array_row(testCase)
            initialArray = [4 3 2 1];
            inputRow     = [1 2 3 4];
            expectedOutput = [4 3 2 1; 1 2 3 4];

            actualOutput = appendRow(initialArray, inputRow);

            testCase.assertEqual(actualOutput, expectedOutput);
        end

        function test_appendRow_with_empty_initial_array_with_input_cell_row(testCase)
            initialArray = [];
            inputRow     = {[1 2 3 4], [0 0 0 0], [-2 -2 -2 -2]};
            expectedOutput = {[1 2 3 4], [0 0 0 0], [-2 -2 -2 -2]};

            actualOutput = appendRow(initialArray, inputRow);

            testCase.assertEqual(actualOutput, expectedOutput);
        end

        function test_appendRow_with_filled_initial_array_with_input_cell_row(testCase)
            initialArray = {[4 3 2 1], [0 0 0 0], [-1 -2 -3 -4]};
            inputRow     = {[1 2 3 4], [0 0 0 0], [-2 -2 -2 -2]};
            expectedOutput = {[4 3 2 1], [0 0 0 0], [-1 -2 -3 -4] ...
                             ;[1 2 3 4], [0 0 0 0], [-2 -2 -2 -2]};

            actualOutput = appendRow(initialArray, inputRow);

            testCase.assertEqual(actualOutput, expectedOutput);
        end
    end

end

