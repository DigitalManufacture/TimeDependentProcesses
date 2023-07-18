%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15

%   This script provides an example of G-code generation from scheduled
%   feedrate in spatial domain 

%% Initialization
close all; 
clear; 
clc
Currentfolder = pwd;

%% Load exact shceduled feed-rate data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('ScheduledFeedrate_example.mat')

figure; fig1 = gcf;
plot(X,F,'-ob','linewidth',1.0,'markersize',5); hold on; grid on
legend('Imported data')
title('Feedrate in spatial domain')

%%% Interpolation of scheduled feedrate data
dX = 0.01; % Spatial resolution of feedrate data
Nsample = round((X(end)-X(1))/dX);
Xinterp = linspace(X(1),X(end),Nsample).';
Finterp= interp1(X,F,Xinterp,'linear','extrap');
X = Xinterp;
F = Finterp;

plot(X,F,'--*r','linewidth',1.0,'markersize',3);
legend('Imported data','Interpolated data')

%% Transfrom time-domain and resample with NC block time
%%% Calculate time vector from feedrate in spatial domain
t = gettimevec(X,F);

figure; fig2 = gcf; grid on; box on;
plot(t,F,'-ob','linewidth',1.0,'markersize',5); hold on; grid on
xlabel('Time [s]'); ylabel('Feed [mm/s]');
legend('Reference data')
title('Feedrate in time domain')

%%% Resample to uniform sampling
Fs = 20000; % Sampling frequency (must set to sufficently high value)
Ts = 1 / Fs ; % [s]
tr = (min(t):Ts:max(t))';
Fr = interp1(t,F,tr,'linear','extrap');
Xr = interp1(t,X,tr,'linear','extrap'); 

figure(fig1); plot(Xr,Fr,'--c','linewidth',1.2)
legend('Imported data','Interpolated data','Uniformed data')
figure(fig2); plot(tr,Fr,'--c','linewidth',1.2)
legend('Reference data','Uniformed data')

%%% Resample with NC block time
t_block = 0.032; % interval of NC block 32 [ms]
[Xh,Fh,th] = NCblockresample_spatial(Xr,Fr,t_block);

figure(fig1); stairs(flip(Xh),flip(Fh),':ok','Linewidth',1.2);
legend('Imported data','Interpolated data','Uniformed data','ZOH with NC block')
figure(fig2); stairs(flip(th),flip(Fh),':ok','Linewidth',1.2);
legend('Reference data','Uniformed data','ZOH with NC block')

%% Conver to G-code & save summary data
outfilename = 'Gcode_WO_opt';
Axis = 'X';
%%% Generate Gcode text file
generateGcode([Xr(1);Xh],[Fr(1);Fh]*60,'G01',Axis,3,outfilename);
[XG,FG,tG] = convertGcode2data([outfilename,'.txt'],Axis);

figure(fig1); stairs(flip(XG),flip(FG),'--^g','Linewidth',1.2);
legend('Imported data','Interpolated data','Uniformed data','ZOH with NC block','Gcode data')
figure(fig2); stairs(flip(tG),flip(FG),'--^g','Linewidth',1.2);
legend('Reference data','Uniformed data','ZOH with NC block','Gcode data')

%%% Save summary data
outfilename = 'Summary_feedrate';
Refdata = [tr, Fr, Xr];
Gdata = [tG, FG, XG];
save(outfilename,'Refdata','Gdata','t_block','Axis');

