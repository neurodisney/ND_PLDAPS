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
%% Condition/Block design
p.trial.task.EqualCorrect = 0; % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% ------------------------------------------------------------------------%
%% Reward

% manual reward from experimenter
p.trial.reward.initialFixRwd  = 0.00; % Small reward for achieving full fixation - set to zero to disable
p.trial.reward.ManDur = 0.05;         % reward duration [s] for reward given by keyboard presses
p.trial.reward.Dur    = 1.0;         % Reward for completing the task successfully
p.trial.reward.IncrConsecutive = 1;  % use rewarding scheme that gives more rewards with subsequent correct trials
p.trial.reward.nPulse          = 1;  % number of reward pulses
p.trial.reward.PulseStep       = [2, 3, 4, 5]; % increase number of pulses with this trial number

% ------------------------------------------------------------------------%
%% Timing
p.trial.task.Timing.WaitFix = 2;    % Time to fixate before NoStart

% Main trial timings
p.trial.task.fixLatency       = 0.1; % Time to hold fixation before initial reward is given
p.trial.task.stimLatency      = ND_GetITI(0.3, 0.9); % Time from initial reward to stim appearing
% Time from fixation to stim appearing is fixLatency + stimLatency

p.trial.task.centerOffLatency = ND_GetITI(0.25, 0.8); % Time from stim appearing to fixspot disappearing

p.trial.task.saccadeTimeout   = 0.5;   % Time allowed to make the saccade to the stim before error
p.trial.task.minSaccReactTime = 0.1;   % If saccade to target occurs before this, it was just a lucky precocious saccade, mark trial Early.
p.trial.task.minTargetFixTime = 1.0;   % Must fixate on target for at least this time before it counts

% inter-trial interval
p.trial.task.Timing.MinITI  = 1.0;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 2.5;  % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos    = [0,0];
p.trial.stim.FIXSPOT.type   = 'disc';     % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color  = 'magenta';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size   = 0.15;        % size of the fixation spot
p.trial.stim.FIXSPOT.fixWin = 4;

% ------------------------------------------------------------------------%
%% Grating stimuli parameters

p.trial.stim.GRATING.fixWin       = 4;

% Eccentricity in degrees from origin
p.trial.stim.GRATING.eccentricity = 4;

% Locations of the stimuli (will scale to the proper eccentricity in the task)
% Right now use the 4 diagonal quadrants and the right and left cardinals.
%  directions                     = [1  0 ; -1  0 ;  1  1 ; ...
%                                   -1  1 ; -1 -1 ;  1 -1];
%  p.trial.stim.GRATING.direction = datasample(directions,1,1);

p.trial.stim.GRATING.direction  = [1 1];

p.trial.stim.GRATING.radius    = 1;    % radius of grating

%  orientations               = [-75,30,0,135,90,45,-110];  %  angles for the stim
%  p.trial.stim.GRATING.angle = datasample(orientations,1);
p.trial.stim.GRATING.angle = 0;

% spatial frequency
% p.trial.stim.GRATING.sFreq        = datasample([1,2,3,4,5],1); % spatial frequency as cycles per degree, suggested range (WZ): 1-10 cycles/degree
p.trial.stim.GRATING.sFreq        = 2; % spatial frequency as cycles per degree, suggested range (WZ): 1-10 cycles/degree

% temporal frequency
p.trial.stim.GRATING.tFreq        = 0;    % temporal frequency of grating; drift speed, 0 is stationary

% contrast
%currcont = datasample([0.01, 0.02, 0.05, 0.1, 0.2], 1);
currcont = 0.10;

p.trial.stim.GRATING.lowContrast  = currcont;  % grating contrast value when stim.on = 1
p.trial.stim.GRATING.highContrast = currcont;  % grating contrast value when stim.on = 2

p.trial.stim.GRATING.res          = 300;

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
