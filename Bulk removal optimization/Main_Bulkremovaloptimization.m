%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15

%   This script provides an example of bulk removal optimization (in 2D) to suppress accleration

%% Initialization
close all; 
clear; 
clc
Currentfolder = pwd;

%% Define PIF used for feedrate scheduling
% The PIF model referred to the following reference:
% Y. Han et al. (2020) Region adaptive scheduling for time-dependent
% processes with optimal use of machine dynamics. Int. J. Mach. Tools
% Manuf. 156:103589. https://doi.org/10.1016/j.ijmachtools.2020.103589

PIFtype = 2;
switch PIFtype
    case 1
        a(1) = -1.5e-5;
        b(1) = 0.1968;
    case 2
        a(1) = -1.5e-4;
        b(1) = 0.2268;
        a(2) = 1.5e-4;
        b(2) = 0.1818;
end
Ngauss = length(a);
PIF.func = @(x,y)0;
for i = 1:Ngauss
    temp = @(x,y)a(i) * exp(-1/2 * (x - 0).^2 ./ b(i)^2 - 1/2 * (y - 0).^2 ./ b(i).^2);
    PIF.func = @(x,y)PIF.func(x,y) + temp(x,y);
end
dx = 0.01; dy = 0.01;
x = (-1:dx:1)';
y = (-1:dy:1)';
[x,y] = meshgrid(x,y);
H = PIF.func(x,y);
figure;
surf(x,y,H,'EdgeColor','none');
colormap jet; c = colorbar;
view([0,0,1])
box on; axis tight; axis square
xlabel('x [mm]'); ylabel('y [mm]');
c.Label.String = 'Removal rate [mm/s]';

ds = dx*dy; % [mm^2]
VRR = sum(H(:))*ds; % [mm^3/s]
disp(['Volmetric removal rate (VRR) is ',num2str(VRR),' mm^3/s'])


%% Load exact shceduled feed-rate data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('Scheduledfeedrate_example_beforeBRO.mat'); % Get feedrate(F [mm/s]) and position (X [mm])
t = gettimevec(X,F); % get time vector
A = getacc_spatial(X,F); % get accleration in spatial domain
disp(['Process time of a single raster path before BRO is ' num2str(t(end)), ' [s]'])

figure('name','Results','Position',[10 1080*1/20 1920*1/2 1080*1/2]); fig = gcf;
subplot(221);  hold on; grid on; box on;
plot(X,F,'b','Linewidth',1.5);
ylabel('Feed [mm/s]'); xlabel('Position [mm]')
legend('Before BRO')
title('Feedrate in spatial domain')

subplot(222); hold on; grid on; box on;
plot(t,F,'b','Linewidth',1.5);
ylabel('Feed [mm/s]'); xlabel('Time [s]')
legend('Before BRO')
title('Feedrate in time domain')

subplot(223);  hold on; grid on; box on;
h11 = plot(X,A,'b','Linewidth',1.5);
ylabel('Accleration [mm/s^2]'); xlabel('Position [mm]')
legend('Before BRO')
title('Accleration in spatial domain')

subplot(224); hold on; grid on; box on;
h21 = plot(t,A,'b','Linewidth',1.5);
ylabel('Accleration [mm/s^2]'); xlabel('Time [s]')
legend('Before BRO')
title('Accleration in time domain')


%% Bulk removal optimization
PIF.R = 1; % Define PIF radius [mm]
Amax = 250; % mm/s^2, maximum accleration
pitch = 0.06; % path spacing [mm]

Hfold = foldingPIF(X,PIF,pitch); % Calculate folded PIF
figure; grid on; hold on; box on
plot(X,Hfold,'b','Linewidth',1.5);
xlabel('X [mm]'); ylabel('Removal rate [mm/s]');
title('Folded 3D PIF')

[Fo,bulk,Dbulk] = bulkremovaloptimization(X,F,Amax,Hfold);
to = gettimevec(X,Fo); % get time vector
Ao = getacc_spatial(X,Fo); % get accleration in spatial domain
disp(['Process time of a single raster path after BRO is ' num2str(to(end)), ' [s]'])

figure(fig);
subplot(221);
plot(X,Fo,'r','Linewidth',1.5); legend('Before BRO','After BRO')

subplot(222);
plot(to,Fo,'r','Linewidth',1.5); legend('Before BRO','After BRO')

subplot(223);
h12 = plot(X,Ao,'r','Linewidth',1.5); 
yline(Amax,':k','LineWidth',1); yline(-Amax,':k','LineWidth',1);
legend([h11,h12],'Before BRO','After BRO')

subplot(224);
h22 = plot(to,Ao,'r','Linewidth',1.5); legend('Before BRO','After BRO')
yline(Amax,':k','LineWidth',1); yline(-Amax,':k','LineWidth',1);
legend([h21,h22],'Before BRO','After BRO')
