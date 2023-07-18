%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input: 
Sr: Positions [mm]
Vr: Feedrate [mm/s]
t_block: NC block [s]
Output: 
Sh: Resampled posiion [mm]
Vh: Resampled feedrate [mm/s]
th: time vector of resampled signal [s]
%}

%% Main
function [Sh,Vh,th] = NCblockresample_spatial(Sr,Vr,t_block)
Vhold = 0;
IDX = 1;
count = 1;
dSr = diff(Sr);
dSr = flip(dSr);
dSr = [0; dSr];
Vr = flip(Vr);
Sr = flip(Sr);

for i = 1:length(Vr)
    if sum(dSr(IDX:i)) >= Vhold * t_block
        Vh(count,1) = Vr(i,1);
        Sh(count,1) = Sr(i,1);
        IDX = i + 1;
        Vhold = Vr(i,1);
        count = count + 1;
    end
end

Vh = flip(Vh);
Sh = flip(Sh);
th(1,1) = 0;

for i = 2:length(Vh)
    temp = (Sh(i) - Sh(i-1)) / Vh(i);
    th(i,1) = th(i-1,1) + temp;
end

end


