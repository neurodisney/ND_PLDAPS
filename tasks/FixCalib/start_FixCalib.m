function p = start_FixCalib(subjname, rig)
% main function to run a task - this variant will have settings that uses the Fixtrain 
% task to calibrate eye position and therefore should be used for initial fixation training.
%
% This function prepares a task by defining setting task related matlab functions,
% setting parameters for the session, creating a pldaps class and running the experiment.
%
% wolf zinke, Dec. 2017

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

%-------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_RigDefaults(rig);    % load default settings according to the current rig setup

%% ################## Edit within the following block ################## %%

%% Define task related functions

% function to set up experiment (and maybe also including the trial function)
exp_fun = 'FixCalib';

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun;                % This function is both, set-up for the experiment session as well as the trial function
SS.task.TaskDef    = 'FixCalib_taskdef';      % function that provides task specific parameter definitions
SS.task.AfterTrial = 'FixCalib_aftertrial';   % function that provides runs task specific actions after a trial
SS.plot.routine    = '';        % function for online plotting of session progress


% ------------------------------------------------------------------------%
%% Initialize Datapixx
% ND_reset;

% ------------------------------------------------------------------------%
%% define variables that need to passed to next trial
SS.editable = {'task.RandomPos', 'stim.FIXSPOT.pos'};
                  
% ------------------------------------------------------------------------%
%% Enable required components if needed
% Most of the components are disabled as default. If needed for the task enable them here.
SS.sound.use                  = 1;
SS.sound.useDatapixx          = 1;
SS.behavior.fixation.use      = 1; % eye position is behavioral relevant
SS.plot.do_online             = 0; % run online data analysis between two subsequent trials
SS.pldaps.nosave              = 1; % disable saving data to pds files
SS.pldaps.draw.eyepos.use     = 1; % enable drawing of the eye position.
SS.pldaps.draw.photodiode.use = 0; % enable drawing the photo diode square
SS.datapixx.useForReward      = 1; % use datapixx analog output for reward

SS.pldaps.draw.grid.use       = 1; % show reference grid on control screen

SS.datapixx.useAsEyepos       = 1;
SS.datapixx.TTL_trialOn       = 0;

% switch here to get calibration functionality
SS.behavior.fixation.useCalibration = 1;
SS.behavior.fixation.enableCalib    = 1;

SS.pldaps.GetTrialStateTimes  = 0; % for debugging, save times when trial states are called

% ------------------------------------------------------------------------%
%% make modifications of default settings
% If there are modification from the default settings needed, copy the
% needed lines from ND_RigDefaults and alter the values here.

SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use

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

