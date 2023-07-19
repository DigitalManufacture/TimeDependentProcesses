%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input:
t: Time [s] (uniform sample data)
F: Feedrate [mm/s]
Output:
Acc: Accleration [mm/s^2]
%}

%% Calculate accleration signal (just numerical differentiation in time domain)
function Acc = getacc(t,F)
dt = t(2) - t(1);
Acc = diff(F) / dt;
tt = t + 0.5*dt;
tt(end) = [];
Acc = interp1(tt,Acc,t,'linear','extrap');
end