function p = FixCalibScene_taskdef(p)
% Parameters for FixCalibScene (InitFixTrain calibration + ViewScene image).
%
% This file is read again at the start of EVERY trial, so values changed
% and saved here during a session take effect on the next trial.
% (The starting fixation window size is set once per session in
%  FixCalibScene.m instead, so keyboard changes to it carry over.)

% ------------------------------------------------------------------------%
%% Fixation hold before the image
% The animal must hold fixation this long (counted from fixation start)
% before the image appears. Calibration points can be added during this
% period. Set MaxFixDur > MinFixDur to draw a random duration each trial.
p.trial.task.Timing.MinFixDur = 2.0;   % [s]
p.trial.task.Timing.MaxFixDur = 2.0;   % [s]

p.trial.behavior.fixation.MinFixStart = 0.5;   % [s] gaze held before fixation counts as started
p.trial.task.Timing.WaitFix           = 2.0;   % [s] time allowed to acquire fixation (else NoStart)

% inter-trial interval
p.trial.task.Timing.MinITI  = 0.5;   % [s]
p.trial.task.Timing.MaxITI  = 1.0;   % [s]
p.trial.task.Timing.TimeOut = 1.5;   % [s]

% ------------------------------------------------------------------------%
%% Reward
p.trial.reward.GiveInitial = 0;       % 1 = reward when fixation starts
p.trial.reward.InitialRew  = 0.05;    % duration of that initial reward

p.trial.reward.GiveSeries  = 1;       % 1 = reward pulses while fixation is held (before the image)
p.trial.reward.Dur         = 0.05;    % duration of each pulse
p.trial.reward.Step        = [0, 4, 8, 12];      % after this many pulses, move to the next Period
p.trial.reward.Period      = [0.5 0.4 0.3 0.2];  % time between pulses, must be > Dur

p.trial.reward.ManDur      = 0.1;     % reward given with the keyboard

p.trial.reward.jackpotDur  = 0.3;     % reward when the fixation hold is completed (image appears); 0 = none
p.trial.reward.SceneRew    = 0.1;     % reward when the image ends; 0 = none

% ------------------------------------------------------------------------%
%% Image / video
p.trial.task.stim.sceneType = 'image';   % 'image' or 'video'
p.trial.task.stim.sceneDir  = '/home/rig2-user/Documents/MATLAB/Images/pareidolia/set 2/';

scenes = dir(p.trial.task.stim.sceneDir);
p.trial.task.stim.sceneNames = {scenes(~[scenes.isdir]).name};
p.trial.task.stim.val = [];

p.trial.stim.IMAGE.sizeGain = 1.0;
p.trial.stim.IMAGE.fixWin   = 80;    % only used for display, gaze during the image does not matter
p.trial.stim.IMAGE.duration = 5;     % [s] image on time, timed from actual image onset
p.trial.stim.IMAGE.pos      = [0, 0];

p.trial.stim.VIDEO.sizeGain = 2.1;
p.trial.stim.VIDEO.fixWin   = 80;
p.trial.stim.VIDEO.playRate = 1;
p.trial.stim.VIDEO.pos      = [0, 0];

p.trial.task.durOffset = 0;          % [s] extra time added to the image/video duration

% While the image is on, block adding/removing calibration points (the
% fixation spot is off, so a point would be paired with the wrong target).
% Calibration is re-enabled automatically when the image goes off.
p.trial.task.blockCalibDuringScene = 1;

% ------------------------------------------------------------------------%
%% Condition/Block design (as in InitFixTrain)
p.trial.Block.maxBlocks    = -1;
p.trial.Block.EqualCorrect =  0;

c0.Nr = 0;
p.trial.Block.Conditions     = {c0};
p.trial.Block.maxBlockTrials = 1;

% ------------------------------------------------------------------------%
%% Fixation spot (as in InitFixTrain)
p.trial.stim.FIXSPOT.type  = 'disc';
p.trial.stim.FIXSPOT.size  = 0.2;
p.trial.stim.FIXSPOT.color = 'dRed';
p.trial.behavior.fixation.FixWinStp = 0.2;   % step for fixation window size keys

% colours cycled across trials (make sure they are defined colours)
p.trial.task.Color_list = Shuffle({'white', 'dRed', 'lRed', 'dGreen', 'orange', 'cyan'});

p.trial.task.RandomPosRange = [4, 4];   % x/y range [dva] when random position is on ('r' key)

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.025;
p.trial.behavior.fixation.entryTime = 0.025;
