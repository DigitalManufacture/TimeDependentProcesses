%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input:
tG: time vector of Gcode signal data [s]
FG: Gcode feed-rate [mm/s]
dt: sampling period for simulation [s]
tau: time constant of 1st order LPF [s]
Xend: Last position [mm]
Output: 
XS: Response position [mm]
FS: Response feed-rate [mm/s]
tS: time vector of response signal [s]
%}

%% main
function [XS,FS,tS] = IIRlpf_Gcode(tG,FG,dt,tau,Xend)
tG = tG(:); 
FG = FG(:);
FG = flip(FG);
tG = flip(tG);
tbeg = tG(1);
tS = []; FS = [];

for i = 1:length(FG)-1
    tinterp = (tbeg:-dt:tG(i+1)+dt)';
    N = length(tinterp);
    Finterp = repmat(FG(i),N,1);
    tS = [tS; tinterp];
    FS = [FS; Finterp];
    tbeg = tinterp(end) - dt;
end

tS = [tS; 0];
FS = [FS; FG(end)];
tS = flip(tS);
FS = flip(FS);
L = length(tS);
tS_interp = (0:dt:(L-1)*dt)';
FS = interp1(tS,FS,tS_interp,'linear','extrap');
tS = tS_interp;
L = round(5*tau/dt);
add = (0:dt:(L-1)*dt)';
tS = [tS; tS(end)+add+dt];
FS = [FS; zeros(L,1)];

G = tf(1,[tau,1]);
FS = lsim(G,FS,tS); % IIR LPF
XS = timeintegral(tS,FS);
XS = XS - XS(end) + Xend;

end