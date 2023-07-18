%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15

%   This script provides an example of G-code optimization

%% Initialization
close all; 
clear; 
clc
Currentfolder = pwd;
set(0,'DefaultAxesLinewidth',1.5)
set(0,'DefaultTextFontName','Script')
set(0,'DefaultAxesFontSize',12);
set(0,'DefaultTextFontSize',12)
set(0,'DefaultAxesFontName', 'Arial');
scrsz = get(0,'ScreenSize'); % Get screen size

%% Load G-code and reference data 
load('Summary_feedrate.mat')
tnc = t_block;
feeddir = Axis;
tR = Refdata(:,1); 
FR = Refdata(:,2); 
XR = Refdata(:,3);
tG = Gdata(:,1); 
FG = Gdata(:,2); 
XG = Gdata(:,3);

%% Gcode optimization
tau = 30e-3; % time constant of 1st order LPF [s]
dt = 1/1000; % Sampling period [s]
Fmin = 0.0;
Fmax = 50; % [mm/s]
Amax = 300; % [mm/s^2]

[XG_opt,FG_opt,tG_opt,pulseMat,dpulseMat] = Gcodeoptimization(XR,FR,tR,dt,tau,tnc,Fmin,Fmax,Amax);

figure('name','Results','Position',[10 1080*1/20 1920*1/2 1080*1/2]);  fig = gcf;
subplot(2,1,1); hold on
plot(XR,FR*60,'b','Linewidth',1.5);
stairs(flip(XG),flip(FG*60),'--ok','Linewidth',1.2);
stairs(flip(XG_opt),flip(FG_opt*60),'--or','Linewidth',1.2);
grid on; xlabel('Position [mm]'); ylabel('Feed [mm/min]');
title('Feedrate in spatial domain')
legend('Ref','G-code(W/O opt)','G-code(W/ opt)');
subplot(2,1,2); hold on
plot(tR,FR*60,'b','Linewidth',1.5);
stairs(flip(tG),flip(FG*60),'--ok','Linewidth',1.2);
stairs(flip(tG_opt),flip(FG_opt*60),'--or','Linewidth',1.2);
grid on; xlabel('Time [s]'); ylabel('Feed [mm/min]');
title('Feedrate in time domain')
legend('Ref','G-code(W/O opt)','G-code(W/ opt)');


%% Conver to G-code
outfilename = 'Gcode_W_opt';
generateGcode(XG_opt,FG_opt*60,'G01',feeddir,3,outfilename); % 丸め込みによっても位置は若干ずれる
[XG_opt,FG_opt,tG_opt] = convertGcode2data([outfilename,'.txt'],Axis);


%% Simulate response after G-code optimization
[XS_opt,FS_opt,tS_opt] = IIRlpf_Gcode(tG_opt,FG_opt,dt,tau,XG_opt(end));
[XS,FS,tS] = IIRlpf_Gcode(tG,FG,dt,tau,XG(end));

figure(gcf);
subplot(211)
plot(XS,FS*60,'--','Color',[0.7,0.7,0.7],'Linewidth',1.8);
plot(XS_opt,FS_opt*60,':g','Linewidth',1.8);
legend('Ref','G-code','G-code(opt)','ResSim(w/o opt)','ResSim(w/ opt)');
subplot(212)
plot(tS,FS*60,'--','Color',[0.7,0.7,0.7],'Linewidth',1.8);
plot(tS_opt,FS_opt*60,':g','Linewidth',1.8);
legend('Ref','G-code','G-code(opt)','ResSim(w/o opt)','ResSim(w/ opt)');

%% Plot summary
figure('name','Results','Position',[10 1080*1/20 1920*1/2 1080*1/2]); 
subplot(221);  hold on; grid on; box on;
plot(XR,FR*60,'b','Linewidth',2);
plot(XS,FS*60,'g','Linewidth',1.8);
plot(XS_opt,FS_opt*60,'r','Linewidth',1.3);
ylabel('Feed [mm/min]'); xlabel('Position [mm]')
legend('Ref','Res.(w/o opt)','Res.(w/ opt)')
title('Feedrate in spatial domain')

subplot(223); hold on; grid on; box on;
plot(XS,FS-interp1(XR,FR,XS,'linear','extrap'),'b','Linewidth',1.5)
plot(XS_opt,FS_opt-interp1(XR,FR,XS_opt,'linear','extrap'),':r','Linewidth',1.5);
ylabel('Error [mm/s]'); xlabel('Position [mm]');
legend('W/O opt','W/ opt');

subplot(222); hold on; grid on; box on;
plot(tR,FR*60,'b','Linewidth',2);
plot(tS,FS*60,'g','Linewidth',1.8);
plot(tS_opt,FS_opt*60,'r','Linewidth',1.3);
ylabel('Feed [mm/min]'); xlabel('Position [mm]')
legend('Ref','Res.(w/o opt)','Res.(w/ opt)')
title('Feedrate in time domain')

subplot(224); hold on; grid on; box on;
plot(tS,FS-interp1(tR,FR,tS,'linear','extrap'),'b','Linewidth',1.5)
plot(tS_opt,FS_opt-interp1(tR,FR,tS_opt,'linear','extrap'),':r','Linewidth',1.5)
ylabel('Error [mm/s]'); xlabel('Time [s]');
legend('W/O opt','W/ opt');

