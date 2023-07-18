%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input: 
tr: Time vector of desired feed [s]
       Fr: Desired feed [mm/s]
       M: # of G-code blocks
       Ts: Simulation sampling period [s]       
       tau: time constant of 1st order LPF [s]
       t_block: interval of NC block [s]
       Xstart: Start position of path [mm]
Output: Xout: Response position [mm]
        Fout: Response feed-rate [mm/s]
        t: time vector of response signal [s]
        Aout: Corresponding accleration [mm/s^2]
        pulseMat: Pulse response matrix used in simulation
%}
%% main
function [XG_opt,FG_opt,tG,pulseMat,dpulseMat] = Gcodeoptimization(XR,FR,tR,Ts,tau,t_block,Fmin,Fmax,Amax)
tR = tR(:); % Time vector of desired feed [s]
FR = FR(:); % desired feed [mm/s]
XR = XR(:);
Nblock = ceil(max(tR)/t_block); % # of G-blocks
t = (min(tR):Ts:max(tR))';
Ts = t(2) - t(1);
F = interp1(tR,FR,t,'linear','extrap');
X = timeintegral(t,F); % Calculate corresponding tool position
X = X - X(1) + XR(1);
tG = (0:t_block:(Nblock-1)*t_block)'; % Time vector of Gcode

%%% Generate pulse response matrix 
M = length(tG);
N = length(t);
G = tf(1,[tau,1]);
pulseMat = zeros(N,M);
dpulseMat = zeros(N,M);
for i = 2:M
    pulse = zeros(N,1);
    idx = t > tG(i-1) & t <= tG(i);
    pulse(idx) = 1;
    pulse_fil = lsim(G,pulse,t);
    pulse_fil = round(pulse_fil*10^12) / 10^12;
    dpulse_fil = [0; diff(pulse_fil)/Ts];
    pulseMat(:,i) = pulse_fil;
    dpulseMat(:,i) = dpulse_fil;
end
idx = t <= tG(1);
pulseMat(idx,1) = 1;

%%% Generate constraint vector/matrix
if isempty(Fmax)
    ub = [];
else
    ub = Fmax * ones(M,1); % lower bound of feed [mm/s]
end
if isempty(Fmin)
    lb = [];
else
    lb = Fmin * ones(M,1); % upper bound of feed [mm/s]
end
if isempty(Amax)
    A = [];
    b = [];
else
    A = [dpulseMat; -dpulseMat]; % 2N×M
    b = Amax * ones(2*N,1); % upper bound of feed [mm/s]
end

%%% Set optimization specification 
opt = optimoptions('lsqlin','Display','iter');
pulseMat = sparse(pulseMat);

%%% Solve inverse problem by using lsq with constraitn
FG_opt = lsqlin(pulseMat,F,A,b,[],[],lb,ub,[],opt);

%%% Calculate corresponding position
XG_opt(1,1) = 0;
dtG = diff(tG);
dtG = [0; dtG];
for i = 2:length(FG_opt)
    temp = FG_opt(i) * dtG(i);
    XG_opt(i,1) = XG_opt(i-1,1) + temp;
end
XG_opt = XG_opt - XG_opt(1) + X(1);

idx = XG_opt > XR(end);
XG_opt(idx) = [];
FG_opt(idx) = [];
tG(idx) = [];
XG_opt(end) = XR(end);
tG(end) = tG(end-1) + (XG_opt(end) - XG_opt(end-1))/FG_opt(end);

end