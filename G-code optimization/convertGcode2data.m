%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input: 
filename: Gcode filename
Axis: axis index 
Output: 
Xin: Position [mm]
Fin: Feedrate [mm/s]
t: Time [s]
%}

function [Xin,Fin,t] = convertGcode2data(filename,Axis)

fileID = fopen(filename);
C = textscan(fileID,'%s %s %s');
Xin = C{1,2};
Fin = C{1,3};
Xin = str2double(strrep(Xin,Axis,''));
Fin = str2double(strrep(Fin,'F','')); % [mm/min]
Fin = Fin / 60; % [mm/s]

t(1,1) = 0;
for i = 2:length(Fin)
    temp = abs(Xin(i) - Xin(i-1)) / Fin(i);
    t(i,1) = t(i-1,1) + temp;
end
    
end
