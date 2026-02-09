function p = InitJoyTrain_taskdef(p)
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
%% levels of complexity
% Full task requires to press joystick after trial start cue goes on, waits for a change of target and then 
% release the joystick as response. 
% If FullTask is set to zero, it just waits for trial start cue and rewards when pressed as response to cue onset.
p.trial.task.FullTask = 1;
% ------------------------------------------------------------------------%

p.trial.task.AltDesign = 1; % MJH 9/1/2025 - If true, circumvent timing-related condition, and proceed to alternate circle stim task.

%% Task Timings
p.trial.task.Timing.WaitStart   = 2.50;   % maximal time period [s] in seconds to press the lever in order to start a trial.
p.trial.task.Timing.WaitResp    = 2.50;   % Only response times [s] after this wait period will be considered stimulus driven responses

p.trial.task.Timing.MinRel      = 0.2;    % minimum time to consider a bar released prior trial start
p.trial.task.Timing.minRT       = 0.20;   % If a response occurs prior this time it is considered an early response

% inter-trial interval
p.trial.task.Timing.MinITI      = 0.25;   % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI      = 1.0;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut     =  0;     % Time [s] out for incorrect responses
p.trial.task.Timing.PullTimeOut =  2;     % Minimum time [s] passed before a trial starts after random lever presses (NIY!)

% ------------------------------------------------------------------------%
%% Reward
p.trial.reward.Pull    = 0;          % If 1 then give reward for pulling the joystick
p.trial.reward.PullRew = 0.05;        % reward amount for pulling joystick (if p.trial.reward.Pull == 1)

p.trial.reward.IncrConsecutive = 1;  % increase reward for subsequent correct trials. Otherwise reward will increase with the number of hits

%p.trial.reward.Dur  = [0.6, 0.75];   % reward duration [s], user vector to specify values used for incremental reward scheme
p.trial.reward.Dur  = [0.6];   % 8/7/25 - MJH - currently the above definition is causing an error. It must be not calling element-wise into the array. just using a single value for the time being. reward duration [s], user vector to specify values used for incremental reward scheme

p.trial.reward.Step = [1, 2];        % define the number of trials when to increase reward. CVector length can not be longer than p.trial.reward.Dur

p.trial.reward.ManDur = 0.05;         % reward duration [s] for reward given by keyboard presses

% ------------------------------------------------------------------------%

%% Condition/Block design
p.trial.task.EqualCorrect = 0; % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

%% Determine conditions and their sequence
% define conditions (conditions could be passed to the pldaps call as
% cell array, or defined here within the main trial function. The
% control of trials, especially the use of blocks, i.e. the repetition
% of a defined number of trials per condition, needs to be clarified.

%maxTrials_per_BlockCond = 4;
%maxBlocks = 1000;

p.trial.Block.maxBlocks = -1; % appears to be a change to this structure from old (commented out above), -1 indicates the experimenter determines when max block has occurred. This would be different for an actual task.

% condition 1
c1.Nr = 1;
c1.task.Timing.MinHoldTime = 0.2;
c1.task.Timing.MaxHoldTime = 0.4;

% condition 2
c2.Nr = 2;
c2.task.Timing.MinHoldTime = 0.4;
c2.task.Timing.MaxHoldTime = 0.6;

% condition 3
c3.Nr = 3;
c3.task.Timing.MinHoldTime = 0.6;
c3.task.Timing.MaxHoldTime = 0.8;

% condition 4
c4.Nr = 4;
c4.task.Timing.MinHoldTime = 0.8;
c4.task.Timing.MaxHoldTime = 1.0;

% condition 5
c5.Nr = 5;
c5.task.Timing.MinHoldTime = 1.0;
c5.task.Timing.MaxHoldTime = 1.2;

% condition 6
c6.Nr = 6;
c6.task.Timing.MinHoldTime = 1.2;
c6.task.Timing.MaxHoldTime = 1.4;

% condition 7
c7.Nr = 7;
c7.task.Timing.MinHoldTime = 1.4;
c7.task.Timing.MaxHoldTime = 1.6;

% condition 8
c8.Nr = 8;
c8.task.Timing.MinHoldTime = 1.6;
c8.task.Timing.MaxHoldTime = 1.8;

% condition 9
c9.Nr = 9;
c9.task.Timing.MinHoldTime = 1.8;
c9.task.Timing.MaxHoldTime = 2.0;

% create a cell array containing all conditions
% conditions = {c1, c2, c3, c4, c5};
%conditions = {c1, c2, c3, c4, c5, c6, c7, c8, c9};
%conditions = {c1, c2, c3, c4, c5, c6};

%p = ND_GetConditionList(p, conditions, maxTrials_per_BlockCond, maxBlocks);

p.trial.Block.Conditions = {c5}; % 7/31/2025 adding here so p will -hopefully- pass these into p.trial.task similarly to how fixtrain-taskdef works for its 'MinWaitInitial' fields.

% ------------------------------------------------------------------------%

%% Get both screens to s how the same
p.defaultParameters.display.monkeyCLUT = p.defaultParameters.display.humanCLUT; % simple switch so that display shows up on both...may need to check output logs though.

%% Stimulus parameters

% 7/30/2025 - MJH - error throws because p.trial.display does not exist yet according to the newer structure. stimulus parameters may need to go directly to InitJoyTrain? ...

% % target item
% p.trial.task.TargetSz_dva  = 4;   % Stimulus diameter in dva
% p.trial.task.TargetPos_dva = [0, 0];    % Stimulus diameter in dva25seconds
% p.trial.task.TargetRect = ND_GetRect(p.trial.task.TargetPos_dva, p.trial.task.TargetSz_dva);
% 
% if ~p.trial.display.useDegreeUnits
%     p.trial.task.TargetSz_pxl  = ND_dva2pxl(p.trial.task.TargetSz_dva, p); % Stimulus diameter in dva
%     p.trial.task.TargetPos_pxl = ND_cart2ptb(p, p.trial.task.TargetPos_dva);
%     p.trial.task.TargetRect    = ND_GetRect(p.trial.task.TargetPos_pxl, p.trial.task.TargetSz_pxl);
% end
% 
% % Frame indicating active trial
% if ~p.trial.display.useDegreeUnits
%     p.trial.task.FrameWdth  = 20; % hard-coded for now, make it more flexible
%     p.trial.task.FrameSize  = ND_dva2pxl([18 18], p); % hard-coded for now, make it more flexible
% else
%     p.trial.task.FrameWdth = 0.3;
%     p.trial.task.FrameSize  = [18, 18];
% end
% 
% p.trial.task.FrameRect  = ND_GetRect([0,0], p.trial.task.FrameSize);

% ------------------------------------------------------------------------%
%% Joystick parameters
p.trial.behavior.joystick.use     = 1;    % Use the joystick
p.trial.behavior.joystick.PullThr = 1.5;  % threshold to detect a joystick press
p.trial.behavior.joystick.RelThr  = 1.0;  % threshold to detect a joystick release

% ------------------------------------------------------------------------%
%% Boundary parameters
%     % trying to get stimulus properties set that will present ring stimulus MJH 9/1/2025
p.trial.stim.RING.linewidth = 3;
p.trial.stim.RING.pos = [0,0];
p.trial.stim.RING.fixWin = 3;
p.trial.stim.RING.radius = 10;
p.trial.stim.RING.lineWeight = 3;
p.trial.stim.RING.color = 'blue';


    
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

%p.trial.pldaps.maxTrialLength = 60; % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

