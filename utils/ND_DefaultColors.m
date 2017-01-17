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
%
% wolf zinke, Jan. 2017

bgcol = p.defaultParameters.display.bgColor;


% pre-allocate lookup table
p.defaultParameters.display.humanCLUT  = zeros(256,3); 
p.defaultParameters.display.monkeyCLUT = zeros(256,3);

ND_DefCol(p, 'bg',     1, bgcol,   bgcol);
ND_DefCol(p, 'eyepos', 2, [0,1,1], bgcol);
ND_DefCol(p, 'joypos', 3, [0,1,1], bgcol);



% %% human interface
% p.defaultParameters.display.humanCLUT = [0, 0, 0;  % IGNORE THIS LINE
%     p.defaultParameters.display.bgColor; % bg                  1
%     0.8,  0, 0.5;                        % cursor              2
%     0,    1, 0;                          % target color        3
%     1,    0, 0;                          % null target color   4
%     1,    1, 1;                          % window color        5
%     1,    0, 0;                          % fixation color      6
%     1,    1, 1;                          % white (dots)        7
%     0,    1, 1;                          % eye (turqoise)      8
%     0,    0, 0;                          % black (dots)        9
%     0,    0, 1;                          % blue               10
%     1,    0, 0;                          % red/green          11
%     0,    1, 0;                          % green/bg           12
%     1,   0,  0;                          % red/bg             13
%     0,   0,  0;                          % black/bg           14
%     zeros(241,3)];
% 
% %% monkey interface
% p.defaultParameters.display.monkeyCLUT = [0,0,0; % IGNORE THIS LINE (CLUT is 0 based)
%     p.defaultParameters.display.bgColor; % bg (gray)          1
%     p.defaultParameters.display.bgColor; % cursor (bg)        2
%     1,  0,  0;                           % target color       3
%     1,  0,  0;                           % null target color  4
%     p.defaultParameters.display.bgColor; % window color       5
%     1,  0,  0;                           % fixation color     6
%     1,  1,  1;                           % white (dots)       7
%     p.defaultParameters.display.bgColor; % eyepos (bg)        8
%     0,  0,  0                            % black (dots)       9
%     0,  0,  1;                           % blue              10
%     0,  1,  0;                           % red/green         11
%     p.defaultParameters.display.bgColor; % green/bg          12
%     p.defaultParameters.display.bgColor; % red/bg            13
%     p.defaultParameters.display.bgColor; % black/bg          14
%     zeros(241,3)];
