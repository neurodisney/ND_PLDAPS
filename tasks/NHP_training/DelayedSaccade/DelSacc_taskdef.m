function p = DelSacc_taskdef(p)
% define task parameters for the joystick training task.
% This function will be executed at every trial start, hence it is possible
% to edit it while the experiment is in progress in order to apply online
% modifications of the task.
%
% TODO: - Make sure that changed parameters are kept in the data file, i.e.
%         that there is some log when changes happened
%       - read in only changes in order to allow quicker manipulations via the
%         keyboard without overwriting it every time by calling this routine
%
%
% wolf zinke, Dec. 2016

% ------------------------------------------------------------------------%
%% Task modifier
p.trial.task.ShowHelp = 0; % Moves the fixation spot towards target location

% ------------------------------------------------------------------------%
%% Reward

% manual reward from experimenter
p.trial.reward.GiveInitial = 0;     % If set to 1 reward animal when starting to fixate
p.trial.reward.InitialRew  = 0.01;  % duration of the initial reward
p.trial.reward.ManDur      = 0.1;   % reward duration [s] for reward given by keyboard presses
p.trial.reward.Dur         = 0.05;   % Reward for completing the task successfully

p.trial.reward.IncrConsecutive = 1; % use rewarding scheme that gives more rewards with subsequent correct trials
p.trial.reward.nPulse          = 1; % number of reward pulses
p.trial.reward.PulseStep       = [2, 4, 6, 8]; % increase number of pulses with this trial number

% ------------------------------------------------------------------------%
%% Grating stimuli parameters
p.trial.stim.GRATING.fixWin  = 2.5;

% spatial & temporal frequency
% p.trial.stim.GRATING.sFreq  = datasample([1,2,3,4,5],1); % spatial frequency as cycles per degree, suggested range (WZ): 1-10 cycles/degree
% p.trial.stim.GRATING.ori    = 45; % orientation of grating
p.trial.stim.GRATING.tFreq    = 0;  % temporal frequency of grating; drift speed, 0 is stationary
p.trial.stim.GRATING.radius   = 0.75;  % radius of grating patch

% p.trial.stim.GRATING.sFreqLst = 0.25:0.1:6; % spatial frequency as cycles per degree
% p.trial.stim.GRATING.OriLst   = 0:15:179; % orientation of grating

% position and angle assignment
%      ____________________
%     |  135 |  90  |   45 |
%     |  (7) |  (8) |  (9) |
%     |______|______|______|
%     |  180 |      |   0  |
%     |  (4) |  *   |  (6) |
%     |______|______|______|
%     |  225 |  270 |  315 |
%     |  (1) |  (2) |  (3) |
%     |______|______|______|

p.trial.stim.GRATING.eccentricity = 3;
p.trial.stim.GRATING.GridAngles   = [225, 270, 315, 180, 0, 135, 90, 45]; % angular position of grating for the 8 keypad controlled locations
p.trial.stim.GRATING.AngleArray   = 0:30:359;  %
p.trial.stim.GRATING.RandAngles   = 0:15:359;  % if in random mode chose an angle from this list

% grating contrast
p.trial.stim.GRATING.lowContrast  = 0.5;  % grating contrast value when stim.on = 1
p.trial.stim.GRATING.highContrast = 0.65;  % grating contrast value when stim.on = 2

p.trial.stim.GRATING.res          = 300;

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = 0.1; % minimum time to wait for robust fixation, if GiveInitial == 1 after this period a reward is given

p.trial.task.Timing.WaitFix = 2;    % Time to fixate before NoStart

% Main trial timings
p.trial.task.stimLatency      = ND_GetITI(0.5, 0.75); % Time from initial reward to stim appearing

p.trial.task.saccadeTimeout   =  2.5;  % Time allowed to make the saccade to the stim before error
p.trial.task.minSaccReactTime = 0.025; % If saccade to target occurs before this, it was just a lucky precocious saccade, mark trial Early.
p.trial.task.minTargetFixTime = 0.25;  % Must fixate on target for at least this time before it counts
p.trial.task.Timing.WaitEnd   = 0.25;  % ad short delay after correct response before turning stimuli off
p.trial.task.Timing.TimeOut   =    2;  % Time-out[s]  for incorrect responses
p.trial.task.Timing.ITI       = ND_GetITI(1,  2,  [], [], 1, 0.10);

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.Block.maxBlocks    = -1;  % if negative blocks continue until experimenter stops, otherwise task stops after completion of all blocks

% condition 1
c1.Nr = 1;
c1.task.MinWaitGo  = 0.05; % min wait period for fixation spot to disapear
c1.task.MaxWaitGo  = 0.15; % max wait period for fixation spot to disapear

% condition 2
c2.Nr = 2;
c2.task.MinWaitGo  = 0.15; % min wait period for fixation spot to disapear
c2.task.MaxWaitGo  = 0.25; % max wait period for fixation spot to disapear

% condition 3
c3.Nr = 3;
c3.task.MinWaitGo  = 0.25; % min wait period for fixation spot to disapear
c3.task.MaxWaitGo  = 0.35; % max wait period for fixation spot to disapear

% condition 4
c4.Nr = 4;
c4.task.MinWaitGo  = 0.35; % min wait period for fixation spot to disapear
c4.task.MaxWaitGo  = 0.45; % max wait period for fixation spot to disapear

% condition 5
c5.Nr = 5;
c5.task.MinWaitGo  = 0.45; % min wait period for fixation spot to disapear
c5.task.MaxWaitGo  = 0.55; % max wait period for fixation spot to disapear

% condition 6
c6.Nr = 6;
c6.task.MinWaitGo  = 0.55; % min wait period for fixation spot to disapear
c6.task.MaxWaitGo  = 0.65; % max wait period for fixation spot to disapear

% condition 7
c7.Nr = 7;
c7.task.MinWaitGo  = 0.65; % min wait period for fixation spot to disapear
c7.task.MaxWaitGo  = 0.75; % max wait period for fixation spot to disapear

% condition 8
c8.Nr = 8;
c8.task.MinWaitGo  = 0.75; % min wait period for fixation spot to disapear
c8.task.MaxWaitGo  = 0.85; % max wait period for fixation spot to disapear

% condition 9
c9.Nr = 9;
c9.task.MinWaitGo  = 0.85; % min wait period for fixation spot to disapear
c9.task.MaxWaitGo  = 0.95; % max wait period for fixation spot to disapear

% condition 10
c10.Nr = 10;
c10.task.MinWaitGo  = 0.95;  % min wait period for fixation spot to disapear
c10.task.MaxWaitGo  = 0.105; % max wait period for fixation spot to disapear

p.defaultParameters.Block.Conditions     = {c1, c2, c3, c4, c5, c6, c7, c8, c9};
p.defaultParameters.Block.maxBlockTrials =  [1, 2, 3, 4,  4,  3, 3, 2,1]; 

p.defaultParameters.Block.Conditions     = {c2, c3, c4, c5, c6};
p.defaultParameters.Block.maxBlockTrials =  [2, 3, 4, 3, 2]; 

p.defaultParameters.Block.Conditions     = {c9};
p.defaultParameters.Block.maxBlockTrials =  5; 


% p.defaultParameters.Block.Conditions     = {c1, c2, c3};
% p.defaultParameters.Block.maxBlockTrials =  [2, 3, 4]; 

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos    = [0,0];
p.trial.stim.FIXSPOT.type   = 'disc';     % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color  = 'magenta';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size   = 0.15;       % size of the fixation spot

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.050;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.150;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Task parameters
p.trial.task.breakFixCheck = 0.2; % Time after a stimbreak where if task is marked early or stim break is calculated

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.
p.trial.pldaps.maxTrialLength = 15;

