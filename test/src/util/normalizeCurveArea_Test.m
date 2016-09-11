classdef (TestTags = {'Unit', 'util'}) normalizeCurveArea_Test < matlab.unittest.TestCase

    properties
    end

    methods (TestClassSetup)
    end

    methods (TestClassTeardown)
    end

    methods (Test)
        function test_normalizeCurveArea_that_output_curve_is_normalized(testCase)
            xData = linspace(0, 50, 100);
            yData = randn(1,100)*5 + 3;

            expectedArea = 1;
            normalized_yData = normalizeCurveArea(xData, yData);
            actualArea = trapz(xData,normalized_yData);

            tol = eps;
            testCase.assertTrue(abs(actualArea - expectedArea) < tol);
        end
    end

end
