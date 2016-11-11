function [fittedT1, t1Error] = calculateVFAT1ErrorDueToB1(T1, TR, FAs, b1ErrorRange)
%CALCULATEVFAT1ERRORDUETOB1 Fit VFA data generated for a range of
%inaccurate B1 correction values
%--args--
%   T1: scalar in ms
%   TR: scalar in ms
%   FAs: array in deg
%   b1ErrorRange: array in relative amplitude. Accurate b1 = 1.
%
%--return--
%   fittedT1: T1 values fitted for each respective b1ErrorRange value
%   t1error: Absolute error % of fitted T1 relative to expected value.

M0 = 10;
measuredSignal = vfaSignal(T1,TR,FAs,M0);
fittedT1 = zeros(1,length(b1ErrorRange));
for ii=1:length(b1ErrorRange)
    Sy = measuredSignal./sind(FAs.*b1ErrorRange(ii));
    Sx = measuredSignal./tand(FAs.*b1ErrorRange(ii));

    p=polyfit(Sx,Sy,1);

    fittedT1(ii) = -TR./log(p(1));
end

t1Error = abs((fittedT1-T1)./T1.*100);

end

function signal = vfaSignal(T1,TR,FA,M0)
% T1 in ms
% TR in ms
% FA in deg

    E1 = exp(-TR/T1);
    signal=M0 .* (1-E1)./(1-cosd(FA).*E1) .* sind(FA);

end