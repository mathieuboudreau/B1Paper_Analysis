function Msig = myLLfunc_amp(x,params)
%MYLLFUNC Calculates the LL signal amplitude for a set of sequence
%parameters to be used in a LL fitting procedure.
%
% This script was designed to be called from "fit_ll_voxel.m"
% 
% The equations used for this calculation were taken from:
%
% Gunnar Brix, Lothar R. Schad, Michael Deimling, Walter J. Lorenz, 
% Fast and precise T1 imaging using a TOMROP sequence, 
% Magnetic Resonance Imaging, Volume 8, Issue 4, 1990, Pages 351-356
%
% ***Inputs***
% x: Two-element vector containing fitting variables. 
%    x(1): Equilibrium magnetization magnitude
%    x(2): T1 in seconds
% 
% params: Structure containing all required sequence parameters - see
% section below.
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
% alpha: Inversion flip angle in radians.
% beta: Excitation flip angle in radians.
% TI1: Time between inversion and first excitation pulse.
% TR: Repetition time in seconds.
% Nll: Number of excitations

alpha = params.alpha;
beta = params.beta;
TI1 = params.TI1; 
TI2 = params.TI2;
TR = params.TR;
Nll = params.Nll;

%% Shortcut variables for signal equation
%

calpha = cos(alpha);
cbeta = cos(beta);

tr = TR - TI1 - (Nll-1).*TI2;

E1 = exp(-TI1./x(2));
E2 = exp(-TI2./x(2));
Er = exp(-tr/x(2));

F = (1-E2)./(1-cbeta.*E2);
Qnom = F.*calpha.*cbeta.*Er.*E1.*(1-(cbeta.*E2).^(Nll-1)) + calpha.*E1.*(1-Er)-E1+1;
Qdenom = 1-calpha.*cbeta.*Er.*E1.*(cbeta.*E2).^(Nll-1);
Q=Qnom/Qdenom;

%% Calculate signal amplitude
%

% Array pre-loading
Mz = zeros(Nll,1);
Msig = zeros(Nll,1);

for ii=1:Nll
    Mz(ii) = F+(cbeta.*E2).^(ii-1).*(Q-F);
    Msig(ii) = x(1).*sin(beta).*Mz(ii);
end
   
end