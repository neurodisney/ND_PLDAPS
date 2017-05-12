function p = rndrew_taskdef(p)
%
%
% wolf zinke, Dec. 2016

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.task.EqualCorrect = 0; % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% ------------------------------------------------------------------------%
%% Reward
p.trial.reward.Pull     = 1;        % If 1 then give reward for pulling the joystick
p.trial.reward.PullRew  = 0.2;      % reward amount for pulling joystick (if p.trial.reward.Pull == 1)

p.trial.reward.TrainRew = 0.25;     % reward amount for during the burst train (if p.trial.reward.RewTrain == 1)
p.trial.reward.prob     = 0.25;     % probability of a random reward

p.trial.reward.defaultAmount = 0.75;     % just use one amount
p.trial.reward.ManDur   = 0.2;      % reward duration [s] for reward given by keyboard presses

% ------------------------------------------------------------------------%
%% Task Timings
p.trial.task.Timing.WaitStart   = 2.50;   % maximal time period [s] in seconds to press the lever in order to start a trial.
p.trial.task.Timing.WaitResp    = 2.50;   % Only response times [s] after this wait period will be considered stimulus driven responses

p.trial.task.Timing.WaitFix     = 2.50;   % time window to allow gaze to get into fixation window in order to continue trial
p.trial.behavior.fixation.BreakTime = 150;      % minimum time [ms] to identify a fixation break

p.trial.task.Timing.MinRel      = 0.5;    % minimum time to consider a bar released prior trial start
p.trial.task.Timing.minRT       = 0.20;   % If a response occurs prior this time it is considered an early response

p.trial.task.Timing.MinHoldTime = 2.5;    % minimum time to keep fixation
p.trial.task.Timing.MaxHoldTime = 5;      % maximum time to keep fixation

% inter-trial interval
p.trial.task.Timing.MinITI      = 1.0;    % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI      = 2.0;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut     =  0;     % Time [s] out for incorrect responses
p.trial.task.Timing.PullTimeOut =  2;     % Minimum time [s] passed before a trial starts after random lever presses (NIY!)

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.FixScale = [10, 10];  % scaling factor to match screen/dva [TODO: get from calibration]

p.trial.task.fixrect = ND_GetRect(p.trial.behavior.fixation.fixPos, ...
                                  p.trial.behavior.fixation.FixWin);  % make sure that this will be defined in a variable way in the future

% ------------------------------------------------------------------------%
%% Stimulus parameters
% Frame indicating active trial
p.trial.task.FrameWdth  = 0.25; % hard-coded for now, make it more flexible
p.trial.task.FrameSize  = [10, 10]; % hard-coded for now, make it more flexible

p.trial.task.FrameRect  = ND_GetRect([0,0], p.trial.task.FrameSize);

% target item
p.trial.task.TargetSz  = 2;   % Stimulus diameter in dva
p.trial.task.TargetPos = p.trial.behavior.fixation.fixPos;    % Stimulus diameter in dva25seconds

% get dva values into psychtoolbox pixel values/coordinates
p.trial.task.TargetRect = ND_GetRect(p.trial.task.TargetPos, p.trial.task.TargetSz);

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
