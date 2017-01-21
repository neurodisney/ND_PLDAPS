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
% This function overrides values defined by the defaultColors function in the PLDAPS package!
%
% wolf zinke, Jan. 2017

% keep the currently defined background color
bgcol = p.defaultParameters.display.bgColor;

%% remove PLDAPS default colors
% this ensures that there is not interference with the PLDAPS definitions,
% but make sure that required colors will be re-defined to not break pldaps.
p_disp = p.defaultParameters.display;    
p_disp = rmfield(p_disp, {'clut', 'humanCLUT', 'monkeyCLUT'});
p.defaultParameters.display = p_disp; % hope this does not cause trouble...

%% pre-allocate lookup table
p.defaultParameters.display.humanCLUT  = zeros(256,3); 
p.defaultParameters.display.monkeyCLUT = zeros(256,3);

%% some colors are used by pldaps, need to check what really is needed
ND_DefineCol(p, 'bg',       1, bgcol,              bgcol);  % background color
ND_DefineCol(p, 'eyepos',   2, [0.00, 1.00, 1.00], bgcol);  % eye positions
ND_DefineCol(p, 'joypos',   3, [0.40, 0.60, 0.00], bgcol);  % current joystick position
ND_DefineCol(p, 'joybox',   4, [0.35, 0.15, 0.00], bgcol);  % color representing released state
ND_DefineCol(p, 'joythr',   5, [0.65, 0.25, 0.00], bgcol);  % color representing pressed state
ND_DefineCol(p, 'cursor',   6, [0.80, 0.00, 0.50], bgcol);
ND_DefineCol(p, 'window',   7, [0.80, 0.80, 0.80], bgcol);
ND_DefineCol(p, 'black',    8, [0.00, 0.00, 0.00], [0.00, 0.00, 0.00]);
ND_DefineCol(p, 'blackbg',  9, [0.00, 0.00, 0.00], bgcol);
ND_DefineCol(p, 'white',   10, [1.00, 1.00, 1.00], [1.00, 1.00, 1.00]);
ND_DefineCol(p, 'red',     11, [1.00, 0.00, 0.00], [1.00, 0.00, 0.00]);
ND_DefineCol(p, 'redbg',   12, [1.00, 0.00, 0.00], bgcol);
ND_DefineCol(p, 'blue',    13, [0.00, 0.00, 1.00], [0.00, 0.00, 1.00]);
ND_DefineCol(p, 'green',   14, [0.00, 1.00, 0.00], [0.00, 1.00, 0.00]);

