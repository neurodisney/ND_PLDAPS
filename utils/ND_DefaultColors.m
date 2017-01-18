function p = ND_DefaultColors(p)
% Setup default color lookup tables.
%
% PLDAPS realizes a dual presentation of the stimulus screen with additional
% information shown for the experimenter with help of color lookup tables.
% This makes the handling of colors more cumbersome, especially since they all
% need to be defined in the early initialization period of the experiment.
%
% Here, the first positions of the lookup table are defined with default
% values that could be changed in the experimental setup. There, also the
% remaining table positions could be assigned to task relevant items.
%
% This function overrides values defined by the defailtColors function in the PLDAPS package!
%
% wolf zinke, Jan. 2017

bgcol = p.defaultParameters.display.bgColor;


% pre-allocate lookup table
p.defaultParameters.display.humanCLUT  = zeros(256,3); 
p.defaultParameters.display.monkeyCLUT = zeros(256,3);

% some colors are used by pldaps, need tro check what is needed
ND_DefineCol(p, 'bg',       1, bgcol,   bgcol);
ND_DefineCol(p, 'eyepos',   2, [0.00, 1.00, 1.00], bgcol);
ND_DefineCol(p, 'joypos',   3, [0.85, 0.00, 1.00], bgcol);
ND_DefineCol(p, 'joylines', 4, [1.00, 0.75, 0.00], bgcol);
ND_DefineCol(p, 'cursor',   5, [0.80, 0.00, 0.50], bgcol);
ND_DefineCol(p, 'window',   6, [0.80, 0.80, 0.80], bgcol);
ND_DefineCol(p, 'black',    7, [0.00, 0.00, 0.00], [0.00, 0.00, 0.00]);
ND_DefineCol(p, 'blackbg',  8, [0.00, 0.00, 0.00], bgcol);
ND_DefineCol(p, 'white',    9, [1.00, 1.00, 1.00], [1.00, 1.00, 1.00]);
ND_DefineCol(p, 'red',     10, [1.00, 0.00, 0.00], [1.00, 0.00, 0.00]);
ND_DefineCol(p, 'redbg',   11, [1.00, 0.00, 0.00], bgcol);
ND_DefineCol(p, 'blue',    12, [0.00, 0.00, 1.00], [0.00, 0.00, 1.00]);
ND_DefineCol(p, 'green',   13, [0.00, 1.00, 0.00], [0.00, 1.00, 0.00]);

