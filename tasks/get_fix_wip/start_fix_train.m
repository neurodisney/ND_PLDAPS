function start_fix_train(subjname)
%
% function is good to go
% maybe migrate/initialize some future parameter parameters here?
%
% created 08/02/2017 AB
% last edited 03/03/2017 AB
% - added comments, reviewed code
% based on 'start_joy_train.m' WZ
%
% run this function to begin a fixation training experiment

%% set default variables

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('subjname','var') || isempty(subjname))
    subjname = 'tst';
end

% function to set up experiment (and maybe also including trial function)
exp_fun = 'fix_train_task'; 

%% load default settings
SS=ND_RigDefaults;  % load default settings according to the current rig setup

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun; % This function is both, set-up for the experiment session as well as the trial function

%% make modifications of default settings
SS.sound.use          = 0;  % no sound for now
SS.display.bgColor    = [50, 50, 50] / 255;

% prepare for eye tracking and joystick monitoring
SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use
SS.mouse.useAsEyepos     = 0;
SS.datapixx.useAsEyepos  = 1;
SS.behavior.fixation.use = 1;

% reward
% moved to *_taskdef.m
% SS.task.Reward.RewTrain = 1;         % give a series of rewards during hold time
% SS.task.Reward.TrainRew = 0.2;       % reward amount for during the burst train (if p.trial.task.Reward.RewTrain == 1)
% SS.task.Reward.RewGap   = 0.5;       % spacing between subsequent reward pulses, in seconds?

% fixation parameters
%SS.beha

SS.pldaps.nosave = 0;  % For now do not bother with the pldaps file format, use plain text file instead.

%% create the pldaps class
p = pldaps(subjname, SS, exp_fun);

%% run the experiment
p.run

%% Ensure DataPixx is closed
if(Datapixx('IsReady'))
    Datapixx('Close');
end
