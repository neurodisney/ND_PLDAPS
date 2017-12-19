function p = CuedChangeDetect_taskdef(p)
% define task parameters for the contrast detection task.
% This function will be executed at every trial start, hence it is possible
% to edit it while the experiment is in progress in order to apply online
% modifications of the task.
%
%
% wolf zinke, Dec. 2016

% ------------------------------------------------------------------------%
%% Task modifier
p.trial.task.ShowHelp = 0; % Moves the fixation spot towards target location

% ------------------------------------------------------------------------%
%% Reward
% manual reward from experimenter
p.trial.reward.ManDur         = 0.05;  % reward duration [s] for reward given by keyboard presses
p.trial.reward.IncrementTrial = [ 150, 300,  400, 500,  600, 650, 700]; % number of correct trials after which reward increases
p.trial.reward.IncrementDur   = [0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.4]; % reward opening time

% ----------------------------------- -------------------------------------%
%% Grating stimuli parameters
p.trial.stim.PosX    = 3;

p.trial.stim.GRATING.fixWin = 2.5;

p.trial.stim.GRATING.radius = 0.75;  % radius of grating patch

p.trial.stim.GridPos = linspace(-3,3,9); % position on y axis

p.trial.stim.GRATING.res          = 600;
p.trial.stim.GRATING.tFreq   = 0;  % temporal frequency of grating; drift speed, 0 is stationary
% grating contrast
p.trial.stim.GRATING.lowContrast  = 0.4;  % grating contrast value when stim.on = 1
% p.trial.stim.GRATING.highContrast = 0.5;  % grating contrast value when stim.on = 2
p.trial.stim.GRATING.highContrast = datasample(0.425:0.05:0.65, 1);

% cue definition
p.trial.stim.cue.offcolor = 'grey3';
p.trial.stim.cue.oncolor  = 'grey5'; 

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = 0.1; % minimum time to wait for robust fixation, if GiveInitial == 1 after this period a reward is given

p.trial.task.Timing.WaitFix = 2;    % Time to fixate before NoStart

% Main trial timings
p.trial.task.stimLatency      = ND_GetITI(0.5, 1.25); % Time from fixation onset to stim appearing

p.trial.task.saccadeTimeout   = 0.5;  % Time allowed to make the saccade to the stim before error
p.trial.task.minSaccReactTime = 0.025; % If saccade to target occurs before this, it was just a lucky precocious saccade, mark trial Early.
p.trial.task.minTargetFixTime = 0.75;  % Must fixate on target for at least this time before it counts
p.trial.task.Timing.WaitEnd   = 0.25;  % ad short delay after correct response before turning stimuli off
p.trial.task.Timing.TimeOut   =  4;  % Time-out[s]  for incorrect responses
p.trial.task.Timing.ITI       = ND_GetITI(0.75,  1.25,  [], [], 1, 0.10);

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.Block.maxBlocks    = -1;  % if negative blocks continue until experimenter stops, otherwise task stops after completion of all blocks

% condition 1
c1.Nr = 1;
c1.task.MinWaitGo  = 0.25; % min wait period for fixation spot to disapear
c1.task.MaxWaitGo  = 0.50; % max wait period for fixation spot to disapear

% condition 2
c2.Nr = 2;
c2.task.MinWaitGo  = 0.50; % min wait period for fixation spot to disapear
c2.task.MaxWaitGo  = 0.75; % max wait period for fixation spot to disapear

% condition 3
c3.Nr = 3;
c3.task.MinWaitGo  = 0.75; % min wait period for fixation spot to disapear
c3.task.MaxWaitGo  = 1.00; % max wait period for fixation spot to disapear

% condition 4
c4.Nr = 4;
c4.task.MinWaitGo  = 1.00; % min wait period for fixation spot to disapear
c4.task.MaxWaitGo  = 1.25; % max wait period for fixation spot to disapear

% condition 5
c5.Nr = 5;
c5.task.MinWaitGo  = 1.25; % min wait period for fixation spot to disapear
c5.task.MaxWaitGo  = 1.50; % max wait period for fixation spot to disapear

% condition 6
c6.Nr = 6;
c6.task.MinWaitGo  = 1.50; % min wait period for fixation spot to disapear
c6.task.MaxWaitGo  = 1.75; % max wait period for fixation spot to disapear

% condition 7
c7.Nr = 7;
c7.task.MinWaitGo  = 1.75; % min wait period for fixation spot to disapear
c7.task.MaxWaitGo  = 2.00; % max wait period for fixation spot to disapear

% condition 8
c8.Nr = 8;
c8.task.MinWaitGo  = 2.00; % min wait period for fixation spot to disapear
c8.task.MaxWaitGo  = 2.25; % max wait period for fixation spot to disapear

% condition 9
c9.Nr = 9;
c9.task.MinWaitGo  = 2.25; % min wait period for fixation spot to disapear
c9.task.MaxWaitGo  = 2.50; % max wait period for fixation spot to disapear

p.trial.Block.Conditions     = {c1, c2, c3, c4};
p.trial.Block.maxBlockTrials =  [1, 3, 4, 2];

p.trial.Block.Conditions     = { c2, c3, c4, c5, c6, c7};
p.trial.Block.maxBlockTrials =  [2,  3,  4,  4,  4,  3];

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos    = [0,0];
p.trial.stim.FIXSPOT.type   = 'disc';     % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color  = 'FixChange';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size   = 0.15;       % size of the fixation spot

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.05;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.10;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Task parameters
p.trial.task.breakFixCheck = 0.2; % Time after a stimbreak where if task is marked early or stim break is calculated

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.
p.trial.pldaps.maxTrialLength = 15;

