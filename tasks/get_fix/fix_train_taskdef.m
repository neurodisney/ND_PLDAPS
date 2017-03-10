% fix_train_taskdef.m
%
% 03/02/2017 AB last edited
% 02/08/2017 AB created 
% modified from: joy_train_taskdef.m (WZ)

%% parameters which are modified on the fly/trial-by-trial manually by experimenter



%% Condition/Block design
p.trial.task.EqualCorrect = 0; % if set to one, trials within a block are
%repeated until the same number of correct trials is obtained for all
%conditions

%% Reward
p.trial.task.Reward.Pull    = 0;            
% If 1 then give reward for pulling the joystick
p.trial.task.Reward.PullRew = 0.2;           
% reward amount for pulling joystick (if p.trial.task.Reward.Pull == 1)

p.trial.task.Reward.IncrConsecutive = 1;     
% increase reward for subsequent correct trials. Otherwise reward will 
% increase with the number of hits (but not correct rejections)
p.trial.task.Reward.Dur  = [0.25, 0.50, 0.75]; 
% reward duration [s], user vector to specify values used for incremental
% reward scheme
p.trial.task.Reward.Step = [2, 4, 6];        
% define the number of trials when to increase reward. CVector length can 
% not be longer than p.trial.task.Reward.Dur

p.trial.task.Reward.Lag    = 0.10;           
% Delay between response and reward onset
p.trial.task.Reward.ManDur = 0.2;            
% reward duration [s] for reward given by keyboard presses

p.trial.task.Reward.RewTrain = 1;         % give a series of rewards during hold time
p.trial.task.Reward.TrainRew = 0.2;       % reward amount for during the burst train (if p.trial.task.Reward.RewTrain == 1)
p.trial.task.Reward.RewGap   = 0.5;       % spacing between subsequent reward pulses
p.trial.task.Reward.Timer    = NaN;       % initialize timer to control subsequent rewards

%% Task Timings
p.trial.task.Timing.WaitStart   = 2.50;    
% maximal time period [s] in seconds to press the lever in order to start a
% trial.
p.trial.task.Timing.WaitResp    = 1.50;    % AB: not sure if this is relevant here
% Only response times [s] after this wait period will be considered 
% stimulus driven responses

% inter-trial interval
p.trial.task.Timing.MinITI      = 0.5;    % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI      = 1.5;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut     =  0;     % Time [s] out for incorrect responses
p.trial.task.Timing.PullTimeOut =  0;     % Minimum time [s] passed before a trial starts after random lever presses (NIY!)
p.trial.task.Timing.minRT       =  0.15;  % If a response occurs prior this time it is considered an early response
p.trial.behavior.joystick.minRT =  0.15;
% this is still used for fixation, maybe set low or eliminate?
p.trial.task.Timing.MinRel      = 0.5;    % minimum time to consider a bar released prior trial start

%% Stimulus parameters
% target item
p.trial.task.TargetSz_dva  = 10;          % Stimulus diameter in dva
p.trial.task.TargetPos_dva = [0, 0];      % Stimulus diameter in dva25seconds

p.trial.task.TargetSz_pxl  = ND_dva2pxl(p.trial.task.TargetSz_dva, p); % Stimulus diameter in dva
p.trial.task.TargetPos_pxl = ND_cart2ptb(p, p.trial.task.TargetPos_dva);
p.trial.task.TargetRect    = ND_GetRect(p.trial.task.TargetPos_pxl, p.trial.task.TargetSz_pxl);

% can probably just use above 'target' for now and erase this
% fixation spot
p.trial.task.FixSpotSz_dva  = 4;          % Stimulus diameter in dva
p.trial.task.FixSpotPos_dva = [0, 0];      % Stimulus position in dva25seconds

p.trial.task.FixSpotSz_pxl  = ND_dva2pxl(p.trial.task.FixSpotSz_dva, p); % Stimulus diameter in dva
p.trial.task.FixSpotPos_pxl = ND_cart2ptb(p, p.trial.task.FixSpotPos_dva);
p.trial.task.FixSpotRect    = ND_GetRect(p.trial.task.FixSpotPos_pxl, p.trial.task.FixSpotSz_pxl);

% Frame indicating active trial
p.trial.task.FrameWdth  = 25; % hard-coded for now, make it more flexible
p.trial.task.FrameSize  = ND_dva2pxl([20 20], p); % hard-coded for now, make it more flexible
p.trial.task.FrameRect  = ND_GetRect(p.trial.display.ctr(1:2), p.trial.task.FrameSize);


% ------------------------------------------------------------------------%
%% Joystick parameters
p.trial.behavior.joystick.PullThr = 1.5;  % threshold to detect a joystick press
p.trial.behavior.joystick.RelThr  = 1.0;  % threshold to detect a joystick release

% fixation-related temporal parameters
% p.trial.task.Timing.minFixHoldTime = 0.2; % amb 03/03/17 added
% p.trial.task.Timing.maxFixHoldTime = 0.4;
% declare this via conditions in fix_train_task.m instead

%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.
p.trial.pldaps.maxTrialLength = 60; % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

