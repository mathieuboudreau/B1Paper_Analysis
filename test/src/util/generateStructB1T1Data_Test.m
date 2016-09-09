classdef (TestTags = {'Unit'}) generateStructB1T1Data_Test < matlab.unittest.TestCase

    properties
        knownCase = struct;
    end

    methods (TestClassSetup)
        function setupKnownStructCase(testCase)
            testCase.knownCase.b1Folder = 'b1/';
            testCase.knownCase.t1Folder = 't1/';
            testCase.knownCase.b1Files  = {'b1/b1_clt_tse.mnc','b1/b1_epseg_da.mnc','b1/b1_clt_afi.mnc','b1/b1_clt_gre_bs_cr_fermi.mnc','b1/b1_nominal.mnc'};
            testCase.knownCase.t1Files  = {'t1/t1_gre_vfa_b1_clt_tse.mnc','t1/t1_gre_vfa_b1_epseg_da.mnc','t1/t1_gre_vfa_b1_clt_afi.mnc','t1/t1_gre_vfa_b1_clt_gre_bs_cr_fermi.mnc','t1/t1_gre_vfa_b1_nominal.mnc'};
        end

    end

    methods (TestClassTeardown)
    end

    methods (Test)
        function test_that_generateStructB1T1Data_throws_err_for_bad_input_types(testCase)
            badType = 0;
            testCase.assertError(@() generateStructB1T1Data(badType, 't1/', {'clt_da'}, 'gre'), 'generateStructB1T1Data:args');
            testCase.assertError(@() generateStructB1T1Data('b1/', badType, {'clt_da'}, 'gre'), 'generateStructB1T1Data:args');
            testCase.assertError(@() generateStructB1T1Data('b1/', 't1/', badType, 'gre'), 'generateStructB1T1Data:args');
            testCase.assertError(@() generateStructB1T1Data('b1/', 't1/', {'clt_da'}, badType), 'generateStructB1T1Data:args');
        end

        function test_generateStructB1T1Data_expected_output_for_known_case(testCase)
            outputStruct = generateStructB1T1Data('b1/', 't1/', {'clt_da','epi','afi','bs','nominal'}, 'gre');
            assertEqual(testCase, outputStruct, testCase.knownCase);
        end

    end

end

