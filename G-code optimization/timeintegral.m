%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input:  
t:  Time vector
Vr: Input signal (e.g., V [mm/s])
Output: 
Sr: Integrated signal (e.g., Position [mm])
%}

%% First order time integral
function Sr = timeintegral(t,Vr)
Ts = t(2) - t(1); % [s]
z  = tf('z',Ts);
I = Ts*z/(z-1); % integrate
Sr = lsim(I, Vr, t); % [s]
end