function p = joy_train_taskdef(p)
% define task parameters for the joystick training task.
% This function will be executed at every trial start, hence it is possible
% to edit it while the experiment is in progress in order to apply online
% modifications of the task.
%
% TODO: - Make sure that changed parameters are kept in the data file, i.e.
%         that there is some log when changes happened
%
%
% wolf zinke, Dec. 2016

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.task.EqualCorrect = 0; % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% ------------------------------------------------------------------------%
%% levels of complexity
% the full task requires to press the joystick after trial start cue gets
% on, wait for a change of the target and then release the joystick as
% response. If FullTask is set to zero it just waits for the trial start
% cue and rewards when pressed as response to the cue onset.
p.trial.task.FullTask = 1;

% ------------------------------------------------------------------------%
%% Reward
p.trial.task.Reward.Pull    = 1;          % If 1 then give reward for pulling the joystick
p.trial.task.Reward.PullRew = 0.05;        % reward amount for pulling joystick (if p.trial.task.Reward.Pull == 1)

p.trial.task.Reward.IncrConsecutive = 1;  % increase reward for subsequent correct trials. Otherwise reward will increase with the number of hits
p.trial.task.Reward.Dur  = [0.6, 0.75];   % reward duration [s], user vector to specify values used for incremental reward scheme
p.trial.task.Reward.Step = [1, 2];        % define the number of trials when to increase reward. CVector length can not be longer than p.trial.task.Reward.Dur

p.trial.task.Reward.ManDur = 0.2;         % reward duration [s] for reward given by keyboard presses

% ------------------------------------------------------------------------%
%% Task Timings
p.trial.task.Timing.WaitStart   = 2.50;   % maximal time period [s] in seconds to press the lever in order to start a trial.
p.trial.task.Timing.WaitResp    = 2.50;   % Only response times [s] after this wait period will be considered stimulus driven responses

p.trial.task.Timing.MinRel      = 1.0;    % minimum time to consider a bar released prior trial start
p.trial.task.Timing.minRT       = 0.20;   % If a response occurs prior this time it is considered an early response

% inter-trial interval
p.trial.task.Timing.MinITI      = 0.25;   % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI      = 1.5;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut     =  0;     % Time [s] out for incorrect responses
p.trial.task.Timing.PullTimeOut =  2;     % Minimum time [s] passed before a trial starts after random lever presses (NIY!)

% ------------------------------------------------------------------------%
%% Stimulus parameters

% Frame indicating active trial
p.trial.task.FrameWdth  = 20; % hard-coded for now, make it more flexible
p.trial.task.FrameSize  = ND_dva2pxl([18 18], p); % hard-coded for now, make it more flexible
p.trial.task.FrameRect  = ND_GetRect(p.trial.display.ctr(1:2), p.trial.task.FrameSize);

% target item
p.trial.task.TargetSz_dva  = 4;           % Stimulus diameter in dva
p.trial.task.TargetPos_dva = [0, 0];      % Stimulus diameter in dva25seconds

% get dva values into psychtoolbox pixel values/coordinates
p.trial.task.TargetSz_pxl  = ND_dva2pxl(p.trial.task.TargetSz_dva, p); % Stimulus diameter in dva
p.trial.task.TargetPos_pxl = ND_cart2ptb(p, ND_dva2pxl(p.trial.task.TargetPos_dva, p));
p.trial.task.TargetRect    = ND_GetRect(p.trial.task.TargetPos_pxl, p.trial.task.TargetSz_pxl);

% ------------------------------------------------------------------------%
%% Joystick parameters
p.trial.behavior.joystick.use     = 1;    % Use the joystick
p.trial.behavior.joystick.PullThr = 1.5;  % threshold to detect a joystick press
p.trial.behavior.joystick.RelThr  = 1.0;  % threshold to detect a joystick release

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 60; % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

