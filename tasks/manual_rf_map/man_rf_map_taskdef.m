function p = man_rf_map_taskdef(p)
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
%% Condition/Block design
p.trial.task.EqualCorrect = 0; % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% ------------------------------------------------------------------------%
%% Reward

% manual reward from experimenter
p.trial.reward.ManDur = 0.05;         % reward duration [s] for reward given by keyboard presses

p.trial.reward.Dur    = 0.05;         % Reward given after each complete stim presentation

p.trial.reward.Dur            = [0.15 0.15 0.12];
p.trial.reward.jackpotTime    = 3;
p.trial.reward.jackpotDur     = 0.5;
p.trial.reward.nRewards       = [1 3 4];
p.trial.reward.Period         = [0.25 0.20 0.15];

p.trial.reward.jackpotDur = 0.3;     % Reward for holding fixation until jackpotTime
p.trial.reward.IncrConsecutive = 1;  % use rewarding scheme that gives more rewards with subsequent correct trials
p.trial.reward.nPulse          = 2;  % number of reward pulses
p.trial.reward.PulseStep       = [2, 3, 4, 5]; % increase number of pulses with this trial number

% ------------------------------------------------------------------------%
%% Timing
p.trial.task.Timing.WaitFix = 4;    % Time to wait for fixation before NoStart

% Main trial timings
p.trial.task.fixLatency       = 0.15; % Time to hold fixation before mapping begins


p.trial.task.stimOnTime       = 0.1;   % How long each stimulus is presented
p.trial.task.stimOffTime      = 0.1;     % Gaps between succesive stimuli

p.trial.task.jackpotTime      = 5;     % How long stimuli are presented before trial ends and jackpot is given

% inter-trial interval
p.trial.task.Timing.MinITI  = 1.0;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 2.5;  % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos    = [0,0];
p.trial.stim.FIXSPOT.type   = 'disc';     % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color  = 'white';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size   = 0.15;        % size of the fixation spot
p.trial.stim.FIXSPOT.fixWin = 2;

% ------------------------------------------------------------------------%
%% Grating stimuli parameters
p.trial.stim.GRATING.res          = 300;
p.trial.stim.GRATING.fixWin       = 0;

% For the following parameters, an array can be specified and all possible combinations
% will be tested.

p.trial.stim.angle      = sort([0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5]);
% spatial frequency (cycles per degree)
p.trial.stim.sFreq    = sort([0.75, 1.125, 1.5, 2.25, 3.25, 4.5, 5.75]);

% These should just be one number
p.trial.stim.GRATING.radius   = 0.75;

% temporal frequency (cycles per second, 0 is stationary)
p.trial.stim.GRATING.tFreq      = 0;

% contrast
p.trial.stim.GRATING.contrast = 1;

% ------------------------------------------------------------------------%
%% Fixation parameters

p.trial.behavior.fixation.BreakTime = 0.050;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.150;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 15;
