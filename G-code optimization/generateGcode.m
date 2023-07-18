%   Copyright 2023 Kyoto University
%   Author: Shuntaro Yamato
%   Last modified: 2023/07/15
%{
Input: 
X: Designated position [mm]
V: Corresponding Feed speed [mm/min]
FIDX: Feed index (G00 or G01)
Ddigit: Decimal digits
outfilename: output filename
Output: Gcode: G-code
%}

function generateGcode(X,V,FIDX,Axis,Ddigit,outfilename)
X = X(:);
V = V(:);
X = round(X*10^Ddigit) / 10^Ddigit;
V = round(V*10^Ddigit) / 10^Ddigit;

Ref = X(1); 
idx = X == X;
for i = 2:length(X)
    if X(i) == Ref
        idx(i) = 0;
    else
        Ref = X(i);
    end
end
X = X(idx);
V = V(idx);

if strcmp(FIDX,'G00')
    FIDX = repmat(FIDX,length(V),1);
elseif strcmp(FIDX,'G01')
    FIDX = repmat(FIDX,length(V),1);
end

for i = 1:length(X)
    Xcell{i,1} = sprintf(['%.',num2str(Ddigit),'f'],X(i));
    Vcell{i,1} = sprintf(['%.',num2str(Ddigit),'f'],V(i));
    Xcell{i,1} = [Axis,Xcell{i,1}];
    Vcell{i,1} = ['F',Vcell{i,1}];
end
Xtable = cell2table(Xcell);
Vtable = cell2table(Vcell);
FIDXtable = table(FIDX);
if isempty(FIDX)
    Gcode = horzcat(Xtable,Vtable);
else
    Gcode = horzcat(FIDXtable,Xtable,Vtable);
end

writetable(Gcode,[outfilename,'.txt'],'Delimiter',' ','WriteVariableNames',false);

end
