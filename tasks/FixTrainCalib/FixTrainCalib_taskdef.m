function p = FixTrainCalib_taskdef(p)
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
p.trial.task.Reward.JackPot         = 0.75;  % unlikely he gets here

% reward series for continous fixation
p.trial.task.Reward.WaitNext = [0.75, 0.5, 0.25];  % wait period until next reward
p.trial.task.Reward.Dur      = 0.1;               % reward duration [s], user vector to specify values used for incremental reward scheme
p.trial.task.Reward.Step     = [2, 6, 8];          % define the number of subsequent rewards after that the next delay period should be used.

% manual reward from experimenter
p.trial.task.Reward.ManDur = 0.2;         % reward duration [s] for reward given by keyboard presses

% ------------------------------------------------------------------------%
%% Task Timings
p.trial.task.Timing.WaitFix = 1;    % time window to allow gaze to get into fixation window in order to continue trial
p.trial.task.Timing.MaxFix  = 12;   % maximal time for fixation (avoid matlab buffer overflows)

% inter-trial interval
p.trial.task.Timing.MinITI  = 1.5;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 3;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.task.fixrect = ND_GetRect(p.trial.behavior.fixation.FixPos, ...
                                  p.trial.behavior.fixation.FixWin);  % make sure that this will be defined in a variable way in the future

p.trial.behavior.fixation.BreakTime = 0.025;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.EnsureFix = 0.025;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.behavior.fixation.FixType = 'disc';     % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.behavior.fixation.FixCol  = 'fixspot';  % color of fixation spot (as defined in the lookup tables)
p.trial.behavior.fixation.FixSz   = 0.1;        % size of the fixation spot

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix + p.trial.task.Timing.MaxFix); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

