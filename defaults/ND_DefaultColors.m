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
bgColor = p.defaultParameters.display.bgColor;

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
ND_DefineCol(p, 'bg',          1, bgColor);  % background color
ND_DefineCol(p, 'TrialStart',  2, [0.65, 0.65, 0.65]); % indicate that a trial started
ND_DefineCol(p, 'joypos',      3, [1.00, 0.80, 0.20], bgColor);  % current joystick position
ND_DefineCol(p, 'joybox',      4, [0.45, 0.20, 0.00], bgColor);  % color representing released state
ND_DefineCol(p, 'joythr',      5, [0.65, 0.25, 0.00], bgColor);  % color representing pressed state
ND_DefineCol(p, 'eyepos',      6, [0.00, 1.00, 1.00], bgColor);  % current eye position
ND_DefineCol(p, 'eyeold',      7, [0.00, 0.65, 0.65], bgColor);  % eye positions from previous frames
ND_DefineCol(p, 'window',      8, [0.80, 0.80, 0.80], bgColor);
ND_DefineCol(p, 'grid',        9, [0.00, 0.00, 0.00], bgColor);
ND_DefineCol(p, 'fixspot',    10, [0.80, 0.80, 0.80], bgColor);
ND_DefineCol(p, 'fixwin',     11, [0.00, 1.00, 1.00], bgColor);
ND_DefineCol(p, 'targetfix',  12, [1.00, 0.00, 0.00], bgColor);
ND_DefineCol(p, 'cursor',     13, [0.90, 0.90, 0.90], bgColor);
ND_DefineCol(p, 'black',      14, [0.00, 0.00, 0.00]);
ND_DefineCol(p, 'blackbg',    15, [0.00, 0.00, 0.00], bgColor);
ND_DefineCol(p, 'white',      16, [1.00, 1.00, 1.00]);
ND_DefineCol(p, 'whitebg',    17, [1.00, 1.00, 1.00], bgColor);
ND_DefineCol(p, 'red',        18, [1.00, 0.00, 0.00]);
ND_DefineCol(p, 'redbg',      19, [1.00, 0.00, 0.00], bgColor);
ND_DefineCol(p, 'blue',       20, [0.00, 0.00, 1.00]);
ND_DefineCol(p, 'bluebg',     21, [0.00, 0.00, 1.00], bgColor);
ND_DefineCol(p, 'green',      22, [0.00, 1.00, 0.00]);
ND_DefineCol(p, 'greenbg',    23, [0.00, 1.00, 0.00], bgColor);
ND_DefineCol(p, 'orange',     24, [1.00, 0.40, 0.00]);
ND_DefineCol(p, 'orangebg',   25, [1.00, 0.40, 0.00], bgColor);
ND_DefineCol(p, 'yellow',     26, [1.00, 1.00, 0.00]);
ND_DefineCol(p, 'yellowbg',   27, [1.00, 1.00, 0.00], bgColor);
ND_DefineCol(p, 'cyan',       28, [0.00, 1.00, 1.00]);
ND_DefineCol(p, 'cyanbg',     29, [0.00, 1.00, 1.00], bgColor);
ND_DefineCol(p, 'magenta',    30, [1.00, 0.00, 1.00]);
ND_DefineCol(p, 'magentabg',  31, [1.00, 0.00, 1.00], bgColor);
ND_DefineCol(p, 'lGreen',     32, [0.69, 1.00, 0.69]);
ND_DefineCol(p, 'lGreenbg',   33, [0.69, 1.00, 0.69], bgColor);
ND_DefineCol(p, 'dGreen',     34, [0.00, 0.69, 0.00]);
ND_DefineCol(p, 'dGreenbg',   35, [0.00, 0.69, 0.00], bgColor);
ND_DefineCol(p, 'lRed',       36, [1.00, 0.69, 0.69]);
ND_DefineCol(p, 'lRedbg',     37, [1.00, 0.69, 0.69], bgColor);
ND_DefineCol(p, 'dRed',       38, [0.69, 0.00, 0.00]);
ND_DefineCol(p, 'dRedbg',     39, [0.69, 0.00, 0.00], bgColor);
ND_DefineCol(p, 'lBlue',      40, [0.69, 0.69, 1.00]);
ND_DefineCol(p, 'lBluebg',    41, [0.69, 0.69, 1.00], bgColor);
ND_DefineCol(p, 'dBlue',      42, [0.00, 0.00, 0.69]);
ND_DefineCol(p, 'dBluebg',    43, [0.00, 0.00, 0.69], bgColor);

% Break colors are bright colors, but muted for the experimenter
ND_DefineCol(p, 'redBreak',    44, [0.25, 0.00, 0.00], [1.00, 0.00, 0.00]);
ND_DefineCol(p, 'greenBreak',  45, [0.00, 0.25, 0.00], [0.00, 1.00, 0.00]);
ND_DefineCol(p, 'blueBreak',   46, [0.00, 0.00, 0.25], [0.00, 0.00, 1.00]);
ND_DefineCol(p, 'yellowBreak', 47, [0.25, 0.25, 0.00], [1.00, 1.00, 0.00]);
ND_DefineCol(p, 'magentaBreak',48, [0.25, 0.00, 0.25], [1.00, 0.00, 1.00]);
ND_DefineCol(p, 'cyanBreak',   49, [0.00, 0.25, 0.25], [0.00, 1.00, 1.00]);
ND_DefineCol(p, 'orangeBreak', 50, [0.25, 0.10, 0.00], [1.00, 0.40, 0.00]);
ND_DefineCol(p, 'whiteBreak',  51, [0.25, 0.25, 0.25], [1.00, 1.00, 1.00]);

% define fixation spots for tasks
ND_DefineCol(p, 'FixDetection',    52, [1.00, 1.00, 0.00]); % Detection tasks where a stimulus has to be found (e.g. Contrast Detection Tasks)
ND_DefineCol(p, 'FixChange',       53, [0.25, 0.00, 0.25]);  % A change of a stimulus has to be identified (e.g. ontrast Change Detection)
ND_DefineCol(p, 'FixDiscriminate', 54, [0.00, 1.00, 1.00]);  % A difference in two or more stimuli has to be identified (e.g. Perceptual Equilibrium Task)
ND_DefineCol(p, 'FixHold',         55, [1.00, 1.00, 1.00]);  % Maintain fixation irrespective of any stimuli (e.g. Receptive Field Mapping Task)

% Grey levels Deciles (CLUT index 61-69)
for(i=1:9)
    ND_DefineCol(p, sprintf('grey%d',i), 60+i, [i, i, i] ./ 10);
end

ND_DefineCol(p,  'cueGrey',        56, [0.32, 0.32, 0.32]);
ND_DefineCol(p,  'distGrey',       57, [0.42, 0.42, 0.42]);

