function p = FixCalib_taskdef(p)
%  fixation calibration task
%
%
% TODO: -
%
%
% wolf zinke, Sep. 2017

% ------------------------------------------------------------------------%
%% Reward
% manual reward from experimenter
p.trial.reward.GiveInitial  = 0; % If set to 1 reward animal when starting to fixate
p.trial.reward.InitialRew   = 0.025; % duration of the initial reward

p.trial.reward.GiveSeries   = 1; % If set to 1 give a continous series of rewards until end of fixation period
p.trial.reward.Dur          = 0.04; % reward duration for pulse in reward series while keeping fixation
p.trial.reward.Step         = [0, 6, 12, 18 24];     % define the number of subsequent rewards after that the next delay period should be used.
p.trial.reward.Period       = [1 0.8 0.60 0.4 0.25]; % the period between one reward and the next NEEDS TO BE GREATER THAN Dur
p.trial.task.CurRewDelay    = 0.65;  % time to first reward

p.trial.reward.ManDur       = 0.05; % reward duration [s] for reward given by keyboard presses

p.trial.reward.jackpotTime  = 12;    % total time required to fixate to get full reward
p.trial.reward.jackpotDur   = 0.25;  % final reward after keeping fixation for the complete time

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = 0.15; % minimum time to wait for robust fixation, if GiveInitial == 1 after this period a reward is given

p.trial.task.Timing.WaitFix = 0.5;  % Time to get a solid fixation before trial ends unsuccessfully

% inter-trial interval
p.trial.task.Timing.MinITI  = 1.25;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 2.75;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  2;     % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.type = 'disc';   % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.size = 0.15;     % size of the fixation spot
%p.trial.stim.FIXSPOT.color  = 'FixHold';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.color   = 'red';  % color of fixation spot (as defined in the lookup tables)
p.trial.behavior.fixation.FixWinStp = 0.05;  % refine resizing of fixation step for this task only(modify default rig settings)

% color options (make sure colors are defined!)

% Enable random positions
p.trial.task.RandomPosRange = [4, 4];  % range of x and y dva for random position

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.025;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.025;  % minimum time to stay within fixation window to detect initial fixation start
