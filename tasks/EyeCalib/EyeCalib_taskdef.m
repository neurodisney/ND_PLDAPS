function p = EyeCalib_taskdef(p)
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
p.trial.reward.ManDur = 0.1;         % reward duration [s] for reward given by keyboard presses
p.trial.reward.MinWaitInitial = 0.2;
p.trial.reward.MaxWaitInitial = 0.2;
p.trial.reward.Dur            = 0.1;
p.trial.reward.Period         = 0.5;

% ------------------------------------------------------------------------%
%% Task Timings
p.trial.task.Timing.WaitFix = 3;    % time window to allow gaze to get into fixation window in order to continue trial
p.trial.task.Timing.MaxFix  = 12;   % maximal time for fixation (avoid matlab buffer overflows)

% inter-trial interval
p.trial.task.Timing.MinITI  = 1.5;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 3;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.fixspot.type    = 'disc';     % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.fixspot.color   = 'white';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.fixspot.size    = 0.25;        % size of the fixation spot

% ------------------------------------------------------------------------%
%% Fixation parameters

p.trial.behavior.fixation.BreakTime = 0.025;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.025;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix + p.trial.task.Timing.MaxFix); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

