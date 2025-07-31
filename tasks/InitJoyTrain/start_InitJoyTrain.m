function p = start_InitJoyTrain(subjname, rig)
% function adapted from wolf's original joy train task for successful implementation 
% in ND_PLDAPS ecosystem - michael harris, Jul. 2025

% use this script to define a default configuration in order to create a
% pldaps object and run it with the InitJoyTrain function.

% ------------------------------------------------------------------------%
%% Set default variables

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('subjname','var') || isempty(subjname))
    subjname = 'tst';
end

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('rig','var') || isempty(rig))
    [~, rigname] = system('hostname');
    rig = str2num(rigname);
end
%% load default settings into a struct
SS = ND_RigDefaults(rig);    % load default settings according to the current rig setup


%% ################## Edit within the following block ################## %%

%% Define task related functions

% function to set up experiment (and maybe also including the trial function)
exp_fun = 'InitJoyTrain';

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun;               % This function is both, set-up for the experiment session as well as the trial function
SS.task.TaskDef     = 'InitJoyTrain_taskdef';    % function that provides task specific parameter definitions
SS.task.AfterTrial  = 'InitJoyTrain_aftertrial'; % << MJH 7/11/25 -This script doesn't exist yet. Need to fashion similar to fixtrain.
SS.plot.routine     = 'InitJoyTrain_plots';      % function for online plotting of session progress
% ------------------------------------------------------------------------%
%% define variables to be passed to next trial
% MJH 7/11/2025 - I'll need to fill these in once I figure out what would be need. 
% will need to make a conditions folder for this that follows a trajectory
% step 1: handle = juice paired w/ dot on screen; step 2: handle in a direction = juice
% step 3: handle after cue, etc...

% What start_InitFixTrain uses:
SS.editable = {'task.RandomPos', 'task.Color_list', 'stim.FIXSPOT.pos'};

%% Enable required components if needed
% Most of the components are disabled as default. If needed for the task enable them here.
SS.sound.use                  = 1; % no sound for now
SS.sound.useDatapixx          = 1; % no sound for now
SS.behavior.fixation.use      = 0; % eye position is behavioral relevant
SS.behavior.joystick.use      = 1; % joystick is behavioral relevant
SS.plot.do_online             = 0; % run online data analysis between two subsequent trials
SS.pldaps.nosave              = 0; % disable saving data to pds files
SS.pldaps.draw.joystick.use   = 1; % draw joystick states on control screen
SS.pldaps.draw.eyepos.use     = 0; % enable drawing of the eye position.
SS.pldaps.draw.photodiode.use = 0; % enable drawing the photo diode square
SS.datapixx.useForReward      = 1; % use datapixx analog output for reward

SS.pldaps.draw.grid.use       = 1;

SS.datapixx.useAsEyepos       = 0;
SS.datapixx.useJoystick       = 1;
SS.datapixx.TTL_trialOn       = 0;

% switch here to get calibration functionality
SS.behavior.fixation.useCalibration = 0;
SS.behavior.fixation.enableCalib    = 0;


SS.pldaps.GetTrialStateTimes  = 0; % for debugging, save times when trial states are called

% ------------------------------------------------------------------------%
%% make modifications of default settings
% If there are modification from the default settings needed, copy the
% needed lines from ND_RigDefaults and alter the values here.

%SS.display.bgColor    = [0.2, 0.2, 0.2];  % change background color
SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use


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




