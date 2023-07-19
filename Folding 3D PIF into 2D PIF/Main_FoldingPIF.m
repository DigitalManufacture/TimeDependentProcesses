%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15

%   This script provides an example of folding 3D PIF into 2D PIF under 
%   raster path with the same target material removal along pick feed direction 

%% Initialization
close all; 
clear; 
clc

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


%% Folding 3D PIF into 2D PIF
PIF.R = 1.0; % Defined PIF radius [mm]
pitch = 0.06; % path spacing in raster path [mm]
X = (-6:0.01:6)'; % path position along feed direction in raster path [mm]
Hfold = foldingPIF(X,PIF,pitch);

figure; grid on; hold on; box on
plot(X,Hfold,'b','Linewidth',1.5);
xlabel('X [mm]'); ylabel('Removal rate [mm/s]');
title('Folded 3D PIF')






