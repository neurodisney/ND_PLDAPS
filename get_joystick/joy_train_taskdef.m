function p = joy_train_taskdef(p, task)
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
p.trial.(task).EqualCorrect = 0; % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% ------------------------------------------------------------------------%
%% Reward
p.trial.(task).Reward.Pull = 0;                % If 1 then give reward for pulling the joystick

p.trial.(task).Reward.IncrConsecutive = 1;     % increase reward for subsequent correct trials. Otherwise reward will increase with the number of hits
%p.trial.(task).Reward.Dur  = [0.1, 0.25, 0.5]; % reward duration [s], user vector to specify values used for incremental reward scheme
p.trial.(task).Reward.Dur  = 0.40; % reward duration [s], user vector to specify values used for incremental reward scheme
p.trial.(task).Reward.Step = [2, 4, 6];        % define the number of trials when to increase reward. CVector length can not be longer than p.trial.(task).Reward.Dur

p.trial.(task).Reward.Lag    = 0.150;          % Delay between response and reward onset
p.trial.(task).Reward.ManDur = 0.500;          % reward duration [s] for reward given by keyboard presses

% ------------------------------------------------------------------------%
%% Task Timings
p.trial.(task).Timing.WaitStart   =  0.05;    % maximal time period [s] in seconds to press the lever in order to start a trial.
p.trial.(task).Timing.HoldTime    =  0.10;    % Minimum time before response is expected
p.trial.(task).Timing.WaitResp    =  0.10;    % Only response times [s] after this wait period will be considered stimulus driven responses
p.trial.(task).Timing.MaxResp     = 10.00;    % maximum release time [s] considered as stimulus driven response

% inter-trial interval
p.trial.(task).Timing.MinITI      = 0.1;      % minimum time period [s] between subsequent trials
p.trial.(task).Timing.MaxITI      = 0.1;      % maximum time period [s] between subsequent trials

p.trial.(task).Timing.TimeOut     =    1;      % Time [s] out for incorrect responses
p.trial.(task).Timing.PullTimeOut =    2;      % Minimum time [s] passed before a trial starts after random lever presses

% ------------------------------------------------------------------------%
%% Stimulus parameters
p.trial.(task).TargetSz_dva       = 2;         % Stimulus diameter in dva
p.trial.(task).TargetSz_pxl       = ND_dva2pxl(p.trial.(task).TargetSz_dva, p); % Stimulus diameter in dva
p.trial.(task).TargetPos_dva      = [0, 0];    % Stimulus diameter in dva
p.trial.(task).TargetPos_pxl      = pds.deg2px(p.trial.(task).TargetPos_dva);

p.trial.(task).TargetRect = ND_GetRect(p.trial.(task).TargetPos_pxl, p.trial.(task).TargetSz_pxl);

% ------------------------------------------------------------------------%
%% initialize event times as NaN
p.trial.(task).EV.TaskStart   = NaN; % actual task start after animal got ready (i.e. joystick is released)
p.trial.(task).EV.JoyPress    = NaN; % Press time to start task
p.trial.(task).EV.GoCue       = NaN; % Onset of Go-signal
p.trial.(task).EV.JoyRelease  = NaN; % time of joystick release
p.trial.(task).EV.Reward      = NaN; % time of reward delivery

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 60; % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.





