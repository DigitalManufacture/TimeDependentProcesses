%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input:
X: Position along feed direction in raster path[mm]
PIF: PIF information (PIF.func, PIF.R)
pitch: path spacing [mm]
Output:
Hfold: Folded PIF
%}

%% Folding 3D PIF into 2D PIF
function Hfold = foldingPIF(X,PIF,pitch)
XXX =  X(:);
y_dummy = zeros(length(X),1);
Hfold = 0;
add = ceil(PIF.R/pitch) * pitch;
Yline = -add:pitch:add;

for i = 1:length(Yline)
    YYY = y_dummy - Yline(i);
    Htemp = zeros(length(X),1);
    mask = XXX.^2 + YYY.^2 <= PIF.R.^2;
    Hext = PIF.func(XXX(mask),YYY(mask));
    Htemp(mask) = Hext;
    Hfold = Hfold + Htemp;
end


