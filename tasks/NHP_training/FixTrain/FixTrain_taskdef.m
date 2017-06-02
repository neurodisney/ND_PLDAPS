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
p.trial.reward.Dur            = 0.08;
p.trial.reward.jackpotTime    = 10;
p.trial.reward.jackpotDur     = 0.4;
p.trial.reward.nRewards       = 30;
p.trial.reward.Period         = 0.25;

p.trial.reward.MinWaitInitial = 0.25;
p.trial.reward.MaxWaitInitial = 0.3;

% ------------------------------------------------------------------------%
%% Task Timings
p.trial.task.Timing.WaitFix = 3;    % Time to get a solid fixation before trial ends unsuccessfully
p.trial.task.Timing.MaxFix = 20;    % Maximum amount of time of fixation
% inter-trial interval
p.trial.task.Timing.MinITI  = 1.5;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 3;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  5;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.task.fixrect = ND_GetRect(p.trial.behavior.fixation.fixPos, ...
                                  p.trial.behavior.fixation.FixWin);  % make sure that this will be defined in a variable way in the future

p.trial.behavior.fixation.BreakTime = 0.025;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.025;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.behavior.fixation.FixType = 'disc';     % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.behavior.fixation.FixCol  = 'fixspot';  % color of fixation spot (as defined in the lookup tables)
p.trial.behavior.fixation.FixSz   = 0.15;        % size of the fixation spot

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix + p.trial.task.Timing.MaxFix); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

