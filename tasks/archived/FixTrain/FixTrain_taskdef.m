function p = FixTrain_taskdef(p)
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
p.trial.reward.ManDur         = 0.2;         % reward duration [s] for reward given by keyboard presses

p.trial.reward.Dur            = [0.15 0.15 0.12];
p.trial.reward.jackpotTime    = 3;
p.trial.reward.jackpotDur     = 0.5;
p.trial.reward.nRewards       = [1 3 4];
p.trial.reward.Period         = [0.25 0.20 0.15];

p.trial.reward.MinWaitInitial = 0.25;
p.trial.reward.MaxWaitInitial = 0.50;

% ------------------------------------------------------------------------%
%% Timing
p.trial.task.Timing.WaitFix = 0.100;    % Time to get a solid fixation before trial ends unsuccessfully

% inter-trial interval
p.trial.task.Timing.MinITI  = 1.5;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 3;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.type    = 'disc';     % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.size    = 50;        % size of the fixation spot
p.trial.stim.FIXSPOT.fixWin  = 0;         %

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.025;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.025;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix + p.trial.reward.MaxWaitInitial + p.trial.reward.jackpotTime); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

