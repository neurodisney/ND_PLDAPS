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
% TODO: Right now, this function is used in addition to the defaultColors
% function in PLDAPS. We might want to consider to replace it (get rid of
% the redundant call) and clean it up.
%
%
% wolf zinke, Jan. 2017



disp('****************************************************************')
disp('>>>>  ND:  Setting Default Colors <<<<')
disp('****************************************************************')
disp('');

% keep the currently defined background color
bgcol = p.defaultParameters.display.bgColor;

%% remove PLDAPS default colors
% this ensures that there is not interference with the PLDAPS definitions,
% but make sure that required colors will be re-defined to not break pldaps.
% should be obsolet now in the PLDAPS neurodisney or ND_dev branch.
p_disp = p.defaultParameters.display;

if(isfield(p_disp, 'clut'))
    p_disp = rmfield(p_disp, {'clut', 'humanCLUT', 'monkeyCLUT'});
    p.defaultParameters.display = p_disp;
end

%% pre-allocate lookup table
p.defaultParameters.display.humanCLUT  = zeros(256,3); 
p.defaultParameters.display.monkeyCLUT = zeros(256,3);

%% define default set of colors
% some color names are used by pldaps and should not be changed
ND_DefineCol(p, 'bg',          1, bgcol);  % background color
ND_DefineCol(p, 'TrialStart',  2, [0.65, 0.65, 0.65]); % indicate that a trial started
ND_DefineCol(p, 'joypos',      3, [1.00, 0.80, 0.20], bgcol);  % current joystick position
ND_DefineCol(p, 'joybox',      4, [0.45, 0.20, 0.00], bgcol);  % color representing released state
ND_DefineCol(p, 'joythr',      5, [0.65, 0.25, 0.00], bgcol);  % color representing pressed state
ND_DefineCol(p, 'eyepos',      6, [0.00, 1.00, 1.00], bgcol);  % current eye position
ND_DefineCol(p, 'eyeold',      7, [0.00, 0.65, 0.65], bgcol);  % eye positions from previous frames
ND_DefineCol(p, 'window',      8, [0.80, 0.80, 0.80], bgcol);
ND_DefineCol(p, 'fixspot',     9, [0.80, 0.80, 0.80], bgcol);
ND_DefineCol(p, 'fixwin',     10, [0.00, 1.00, 1.00], bgcol);
ND_DefineCol(p, 'targetfix',  11, [1.00, 0.00, 0.00], bgcol);
ND_DefineCol(p, 'cursor',     12, [0.90, 0.90, 0.90], bgcol);
ND_DefineCol(p, 'black',      13, [0.00, 0.00, 0.00]);
ND_DefineCol(p, 'blackbg',    14, [0.00, 0.00, 0.00], bgcol);
ND_DefineCol(p, 'white',      15, [1.00, 1.00, 1.00]);
ND_DefineCol(p, 'whitebg',    16, [1.00, 1.00, 1.00], bgcol);
ND_DefineCol(p, 'red',        17, [1.00, 0.00, 0.00]);
ND_DefineCol(p, 'redbg',      18, [1.00, 0.00, 0.00], bgcol);
ND_DefineCol(p, 'blue',       19, [0.00, 0.00, 1.00]);
ND_DefineCol(p, 'green',      20, [0.00, 1.00, 0.00]);
ND_DefineCol(p, 'greenbg',    21, [0.00, 1.00, 0.00], bgcol);


%ND_DefineCol(p, 'text',       32, [1.00, 1.00, 1.00], bgcol);



%ND_DefineCol(p, 'targetgood', 50, [0.00, 1.00, 0.00]);
%ND_DefineCol(p, 'targetnull', 51, [1.00, 0.00, 0.00]);
%ND_DefineCol(p, 'fixation',   52, [1.00, 0.00, 0.00]);

