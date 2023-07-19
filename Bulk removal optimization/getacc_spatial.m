%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input:
t: Position [s] (uniform sample data)
F: Feedrate [mm/s]
Output:
Ax: Accleration in spatial domain [mm/s^2]
%}

%% Get accleration signal in spatial domain
function Ax = getacc_spatial(X,F)
F = F(:); X = X(:);
D = 1 ./ F; % Dwell-time density [s/mm]
dDdX = getacc(X,D);
Ax = -dDdX ./ D.^3;
end