function p = ScreenReversal_taskdef(p)
%  Screen Luminance/Contrast Reversal Paradigm
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
p.trial.reward.InitialRew   = 0.05; % duration of the initial reward

p.trial.reward.GiveSeries   = 1; % If set to 1 give a continous series of rewards until end of fixation period
p.trial.reward.Dur          = 0.05; % reward duration for pulse in reward series while keeping fixation
p.trial.reward.Step         = [0, 5, 10, 15];     % define the number of subsequent rewards after that the next delay period should be used.
p.trial.reward.Period       = [0.5 0.4 0.3 0.2]; % the period between one reward and the next NEEDS TO BE GREATER THAN Dur
p.trial.task.CurRewDelay    = 0.5;  % time to first reward

p.trial.reward.ManDur       = 0.05; % reward duration [s] for reward given by keyboard presses

p.trial.reward.jackpotTime  = 5;     % total time required to fixate to get full reward
p.trial.reward.jackpotDur   = 0.5;  % final reward after keeping fixation for the complete time

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = 0.15; % minimum time to wait for robust fixation, if GiveInitial == 1 after this period a reward is given

p.trial.task.Timing.WaitFix = 1.5;  % Time to get a solid fixation before trial ends unsuccessfully

% inter-trial interval
p.trial.task.Timing.MinITI  = 0.75;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 1.25;  % maximum time period [s] between subsequent trials

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.type  = 'disc';         % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.size  = 0.15;           % size of the fixation spot
p.trial.stim.FIXSPOT.color = 'magenta';      % color of fixation spot (as defined in the lookup tables)
p.trial.behavior.fixation.FixWinStp = 0.05;  % refine resizing of fixation step for this task only(modify default rig settings)

% Enable random positions
p.trial.task.RandomPosRange = [4, 4];  % range of x and y dva for random position

% ------------------------------------------------------------------------%
%% Screen Modulation
% p.trial.task.HIperiod = 0.5 * 1/8; % time period where luminance is above mean screen luminance
% p.trial.task.LOperiod = 0.5 * 1/8; % time period where luminance is below mean screen luminance
p.trial.task.HIperiod = 0.2;      % time period where luminance is above mean screen luminance
p.trial.task.LOperiod = 2;        % time period where luminance is below mean screen luminance

p.trial.task.DoFlash = 1;  % if 1, a screen flash paradigm is used, otherwise the contrast folows a sinosoidal modulation

% p.trial.task.ContrastList = ND_LogSpace(0, 80, 8); 
p.trial.task.ContrastList   = [0, 2, 4, 8, 16, 32, 64, 100]; % ND_ValueSpacing(2, 100, 7, 'double');
p.trial.task.ScreenFixWin   = 8;  % Send trigger when fixation enters or leaves this Window
p.trial.task.WaitModulation = 1;  % how many seconds to wait before starting screen modulation

% ------------------------------------------------------------------------%
%% Drug delivery
p.trial.Drug.Give = 1;
p.trial.Drug.FlashSeriesLength = 5;
p.trial.Drug.PeriFlashTime     = -150;

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.025;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.025;  % minimum time to stay within fixation window to detect initial fixation start
