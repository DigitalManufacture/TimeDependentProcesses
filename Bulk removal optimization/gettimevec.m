%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input: X: Positions [mm] (Uniform sampling in spatial domain)
       D: Feedrate [mm/s]
Output: t: Time vector [s]
%}
%% main
function t = gettimevec(X,F)
dX = X(2) - X(1); % [mm]
X = X - X(1); % 便宜上
z  = tf('z',dX);
I = dX*z/(z-1); % integrate
t = lsim(I, 1./F, X); % [s]
t = [0; t(1:end-1)]; % start from 0 sec
end