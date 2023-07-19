%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input:
X: Position [mm]
F: Feedrate [mm/s]
Amax: maximum accleration [mm/s^2]
Hfold: Folded PIF
Output:
Fopt: optimized feedrate [mm/s]
bulk: corrresponding additional bulk removal [mm]
Dbulk: corrresponding additional dwell-time density [s/mm]
%}

%% Bulk removal optimization
function [Fopt,bulk,Dbulk] = bulkremovaloptimization(X,F,Amax,Hfold)
X = X(:); F = F(:);
dX = X(2) - X(1); % [mm]
A = getacc_spatial(X,F); % [mm/s^2]
if max(abs(A)) > Amax
    disp('Apply bulk removal optimization')
    ARR = abs( trapz(Hfold) * dX ); % Areal removal rate of folded PIF [mm^2/s], ARR > 0
    bulk = ARR * (nthroot(abs(A)./Amax,3) - 1) ./ F ; % [mm]
    bulk = max(bulk); % because of definition of ARR > 0
    Dbulk = bulk / ARR; % [s/mm]
    disp(['Optimal bulk removal is ' num2str(bulk) ' [mm] in 2D']);
    disp(['Corresponding added dwell time density is ',num2str(Dbulk),' s/mm'])
    Fopt = F ./ (1 + Dbulk * F); % [mm/s]
else
    disp('Not necessary to apply bulk removal optimization')
    Fopt = F;
    bulk = 0;
    Dbulk = 0;
end

end



