function [fittedT1,fittedConst]= fit_ll_voxel(data,alpha, beta,TI1,TI2,T1est,TR,Nll)
%FIT_LL_VOXEL Fits Look-Locker voxel data using magnitude data only by flipping
% a two combinations of the first two points ([-1 1 1 1], [-1 -1 1 1], and 
% returning the T1 with the least fitted residual. 
%
% This code is designed for four-TI Look-Locker data.
%
% The Look-Locker fitting routine assumes that the second point is near the
% null of WM and GM. It also assumes perfect nominal flip angles (both the
% inversion AND excitation pulses).
%
% This script was originally writtend to be called by a function names
% "ll_fit_map.m"
%
% ************ATTENTION************
% * This code is only appropriate *
% * for fitting *HEALTHY WM*. Due *
% * to the noise floor, a small   *
% * range of T1 cannot be fit,    *
% * because the data near the     *
% * second point will never be 0. *
% *                               *
% * For ep_seg_qt1_flex, this     *
% * range is around 1.3 to 1.4 s  *
% ************ATTENTION************
%
% *** Inputs ***
% data: Four element vector containing the magnitude data (all positive) of
%       a given voxel to be fitted.
% alpha: Inversion flip anngle in radian
% beta: Excitation flip angle in radian
% TI1: Time between inversion pulse and first excitation pulse
% TI2: Time between excitation in the LL pulse sequence
% T1est: T1 for initial fitting estimate
% TR: Repetition time in seconds
% Nll: Number of echoes (should be equal to the length of data)
%
% Date Created: September 2013
% Author: Mathieu Boudreau
% Institution: McConnell Brain Imaging Center, Montreal Neurological
%              Institute, Montreal, Quebec
%
% Date last modified: October 2 2013
% 

%% Prepare sequence parameters
%

params.alpha = alpha;
params.beta = beta;
params.TI1 = TI1;
params.TI2 = TI2;
params.TR = TR;
params.Nll = Nll;

%% Fit data
%

opts = optimset('Display','off', 'Algorithm', 'levenberg-marquardt');

[fitParamLL_1, res_fitParamLL_1] =lsqcurvefit(@(x,params)myLLfunc_amp(x,params), [data(1)*1.25, T1est], params, [-data(1) data(2) data(3) data(4)]',[],[],opts);
[fitParamLL_2, res_fitParamLL_2] =lsqcurvefit(@(x,params)myLLfunc_amp(x,params), [data(1)*1.25, T1est], params, [-data(1) -data(2) data(3) data(4)]',[],[],opts);

%% Get T1 from the fit resulting in the least residual
%

all_res = [res_fitParamLL_1, res_fitParamLL_2];
if res_fitParamLL_1==min(all_res)
    fittedT1 = fitParamLL_1(:,2);
    fittedConst = fitParamLL_1(:,1);
else
    fittedT1 = fitParamLL_2(:,2);
    fittedConst = fitParamLL_2(:,1);
end

end