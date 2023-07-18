% Author : Shuntaro Yamato
%{
Input: maxX: maximum tool path [mm]
       minX: minimum tool position [mm]
       X: meaningful path coordinate [mm]
       V: scheduled feed-rate [mm/s]
       Vext: Feed in extended region [mm/s]
Output: Xe: Extended path coordinate [mm/s]
        Ve: Extended Velocity [mm/s]
%}
%% Main
function [Xe,Ve] = ExtentionPath(minX,maxX,X,V,Vext_b,Vext_e)
X = X(:);
V = V(:);
dX = X(2) - X(1);
X_ext_b = ( -min(X):dX:-minX )'; 
X_ext_b = -flip(X_ext_b);
X_ext_e = ( max(X):dX:maxX )';
Xe = [X_ext_b(1:end-1); X; X_ext_e(2:end)];
if isempty(Vext_b)
    Vbeg = V(1);
else
    Vbeg = Vext_b;
end
if isempty(Vext_e)
    Vend = V(end);
else
    Vend = Vext_e;
end
Ve = [repmat(Vbeg,length(X_ext_b)-1,1); V; repmat(Vend,length(X_ext_e)-1,1)];
end