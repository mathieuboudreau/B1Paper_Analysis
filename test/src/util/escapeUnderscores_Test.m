classdef (TestTags = {'Unit', 'util'}) escapeUnderscores_Test < matlab.unittest.TestCase

    properties
    end

    methods (TestClassSetup)
    end

    methods (TestClassTeardown)
    end

    methods (Test)
        function test_escapeUnderscores_with_string_input(testCase)
            inputString = 'Boooo_Hello!_';

            expectedOutput = 'Boooo\_Hello!\_';
            actualOutput = escapeUnderscores(inputString);

            testCase.assertEqual(expectedOutput, actualOutput);
        end

        function test_escapeUnderscores_with_cells_of_strings_input(testCase)
            inputString = {'_', 'a_b', '_c', 'd_', '__'};

            expectedOutput = {'\_', 'a\_b', '\_c', 'd\_', '\_\_'};
            actualOutput = escapeUnderscores(inputString);

            testCase.assertEqual(expectedOutput, actualOutput);
        end
    end

end

