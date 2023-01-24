<<<<<<<< HEAD:tasks/ScreenFlash/start_ScreenFlash_Grating.m
function p = start_ScreenFlash_Grating(subjname, rig)
========
function p = start_Attention(subjname, rig)
>>>>>>>> DukeRig1_revertPreAttentionTask:tasks/Attention/start_Attention.m
% main function to run a task
%
% This function prepares a task by defining setting task related matlab functions,
% setting parameters for the session, creating a pldaps class and running the experiment.
%
% wolf zinke, Apr. 2017
% Nate Faber, May 2017
% wolf zinke, Apr 2018
% anita disney May 2020
% Veronica Galvin adapted for ScreenFlash_Grating, Sept. 2021

% ------------------------------------------------------------------------%
%% Set default variables
% name of subject. This will be used to create a subdirectory with this name.
if(~exist('subjname','var') || isempty(subjname))
    subjname = 'test';
end

% rig number, used for rig defaults call. obtained from Linux hostname if not specified
if(~exist('rig','var') || isempty(rig))
    [~, rigname] = system('hostname');
    rig = str2num(rigname);
end

%-------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_RigDefaults(rig);    % load default settings according to the current rig setup

%% ################## Edit within the following block ################## %%

%% Define task related functions

<<<<<<<< HEAD:tasks/ScreenFlash/start_ScreenFlash_Grating.m
% function to set up experiment (may also be trial function)
% exp_fun = 'RevCorr';
exp_fun = 'ScreenFlash_Grating';

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun;     % This function is both set-up for the experiment session as well as the trial function
SS.task.TaskDef    = 'ScreenFlash_Grating_taskdef';  % function that provides task specific parameter definitions
SS.task.AfterTrial = 'ScreenFlash_Grating_aftertrial';  % function that provides runs task specific actions after a trial
SS.plot.routine    = '';    % function for online plotting of session progress

% ------------------------------------------------------------------------%
%% define variables that need to be passed to next trial
SS.editable = {'stim.count', 'stim.iStim', 'stim.iPos', 'stim.RFmeth', 'stim.coarse.xRange', 'stim.coarse.yRange'};
                  
========
% function to set up experiment (and maybe also including the trial function)
exp_fun = 'Attention';
%exp_fun = 'PercEqui';
% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun;          % This function is both, set-up for the experiment session as well as the trial function
SS.task.TaskDef    = 'Attention_taskdef';     % function that provides task specific parameter definitions
SS.task.AfterTrial = 'PercEqui_aftertrial';  % function that provides runs task specific actions after a trial
SS.plot.routine    = 'PercEqui_plots';       % function for online plotting of session progress

% ------------------------------------------------------------------------%
%% define variables that need to passed to next trial
SS.editable = {'stim.GRATING.sFreq', ...
               'task.EqualStim', 'stim.GRATING.ori', 'task.RandomPar', 'stim.PosY', ...
               'task.RandomHemi', 'stim.Hemi'};
           
%      SS.editable = {'stim.GRATING.sFreq', 'stim.Ecc', 'stim.Ang',  ...
%                'stim.GRATING.ori', 'task.RandomPar', 'task.RandomHemi', 'stim.Hemi', ...
%                'stim.PosX', 'stim.PosY', 'task.RandomEcc', 'task.RandomAng'};
             
>>>>>>>> DukeRig1_revertPreAttentionTask:tasks/Attention/start_Attention.m
% ------------------------------------------------------------------------%
%% Enable required components
% Most of the components are disabled as default. If needed for the task enable them here.
<<<<<<<< HEAD:tasks/ScreenFlash/start_ScreenFlash_Grating.m
SS.sound.use                  = 0;
SS.behavior.fixation.use      = 1; % eye position is behaviorally relevant
SS.behavior.joystick.use      = 0; % joystick is behaviorally relevant
SS.plot.do_online             = 0; % run online data analysis between trials
========
SS.sound.use                  = 1; % auditory feedback?
SS.behavior.fixation.use      = 1; % eye position is behavioral relevant
SS.behavior.joystick.use      = 0; % joystick is behavioral relevant
SS.plot.do_online             = 0; % run online data analysis between two subsequent trials
>>>>>>>> DukeRig1_revertPreAttentionTask:tasks/Attention/start_Attention.m
SS.pldaps.nosave              = 0; % disable saving data to pds files
SS.pldaps.draw.joystick.use   = 0; % draw joystick states on control screen
SS.pldaps.draw.eyepos.use     = 1; % enable drawing of the eye position.
SS.pldaps.draw.photodiode.use = 0; % enable photo diode square
SS.datapixx.useForReward      = 1; % use datapixx analog output for reward

SS.pldaps.draw.grid.use       = 1;

SS.datapixx.useAsEyepos       = 1; 
SS.datapixx.useJoystick       = 0;
SS.datapixx.TTL_trialOn       = 0;

<<<<<<<< HEAD:tasks/ScreenFlash/start_ScreenFlash_Grating.m
SS.tdt.use                    = 0; % Get incoming UDP spike data from TDT

========
>>>>>>>> DukeRig1_revertPreAttentionTask:tasks/Attention/start_Attention.m
SS.behavior.fixation.useCalibration = 1;
SS.behavior.fixation.enableCalib    = 0;

SS.behavior.fixation.on = 1; % fixation.on for this task

SS.pldaps.GetTrialStateTimes  = 0; % for debugging, save times when trial states are called

% ------------------------------------------------------------------------%
%% make modifications of default settings
% If there are modification from the default settings needed, copy the
% needed lines from ND_RigDefaults and alter the values here.

<<<<<<<< HEAD:tasks/ScreenFlash/start_ScreenFlash_Grating.m
SS.display.bgColor    = [0.35, 0.35, 0.35];  % change background color
SS.datapixx.adc.srate = 1000; % for a 1k tracker

SS.behavior.fixation.FixWin     = 50.0;
SS.behavior.fixation.FixGridStp = [3, 3]; % x,y coordinates in a 9pt grid
SS.behavior.fixation.FixWinStp  = 100.00;    % change of the size of the fixation window upon key press

SS.Block.maxBlockTrials = 10000;

========
%SS.display.bgColor    = [0.25, 0.25, 0.25];  % change background color
SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use

>>>>>>>> DukeRig1_revertPreAttentionTask:tasks/Attention/start_Attention.m
%% ################## Edit within the preceding block ################### %%
%% ### Do not change code below [unless you know what you are doing]! ### %%

% ------------------------------------------------------------------------%
%% create the pldaps class
p = pldaps(subjname, SS, exp_fun);

% ------------------------------------------------------------------------%
%% run the experiment
p.run;

% ------------------------------------------------------------------------%
%% Ensure DataPixx is closed
if(Datapixx('IsReady'))
    Datapixx('Close');
end

