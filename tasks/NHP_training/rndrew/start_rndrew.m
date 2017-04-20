function p = start_rndrew(subjname, rig, experimenter)
% main function to run a task
%
% This function prepares a task by defining setting task related matlab functions,
% setting parameters for the session, creating a pldaps class and running the experiment.
%
% wolf zinke, Mar. 2017


% ------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_RigDefaults;    % load default settings according to the current rig setup


%% ################## Edit within the following block ################## %%

%% Define task related functions

% function to set up experiment (and maybe also including the trial function)
exp_fun = 'rndrew';

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun;     % This function is both, set-up for the experiment session as well as the trial function
SS.task.TaskDef  = 'rndrew_taskdef';  % function that provides task specific parameter definitions
SS.plot.routine  = 'rndrew_plots';    % function for online plotting of session progress

% ------------------------------------------------------------------------%
%% define variables that need to passed to next trial
SS.editable = {'behavior.fixation.FixWin'};

% ------------------------------------------------------------------------%
%% Enable required components if needed
% Most of the components are disabled as default. If needed for the task enable 1them here.
SS.sound.use                  = 0; % no sound for now
SS.behavior.fixation.use      = 1; % eye position is behavioral relevant
SS.behavior.joystick.use      = 1; % joystick is behavioral relevant
SS.plot.do_online             = 0; % run online data analysis between two subsequent trials
SS.pldaps.nosave              = 0; % disable saving data to pds files
SS.pldaps.draw.joystick.use   = 1; % draw joystick states on control screen
SS.pldaps.draw.eyepos.use     = 1; % enable drawing of the eye position.
SS.pldaps.draw.photodiode.use = 0; % enable drawing the photo diode square
SS.datapixx.useForReward      = 1; % use datapixx analog output for reward

SS.datapixx.useAsEyepos       = 1;
SS.datapixx.useJoystick       = 1;

SS.behavior.fixation.required = 1; % fixation required for this task

SS.pldaps.GetTrialStateTimes  = 1; % for debugging, save times when trial states are called

% ------------------------------------------------------------------------%
%% make modifications of default settings
% If there are modification from the default settings needed, copy the
% needed lines from ND_RigDefaults and alter the values here.

SS.display.bgColor    = [0.2, 0.2, 0.2];  % change background color
SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use

SS.behavior.fixation.FixPos     = [ 0 , 0];
SS.behavior.fixation.FixScale   = [2, 2];
SS.behavior.fixation.FixWin     = 4;
SS.behavior.fixation.FixGridStp = [ 4,  4]; 
SS.behavior.fixation.FixWinStp  = 0.25;   

%% ################## Edit within the preceding block ################### %%
%% ### Do not change code below [unless you know what you are doing]! ### %%

% ------------------------------------------------------------------------%
%% Set default variables

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('subjname','var') || isempty(subjname))
    subjname = 'tst';
end

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('rig','var') || isempty(rig))
    [~, rigname] = system('hostname');
    rig = str2num(rigname(4));
end

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('experimenter','var') || isempty(experimenter))
    experimenter = getenv('USER');
end

% ------------------------------------------------------------------------%
%% create the pldaps class
p = pldaps(subjname, SS, exp_fun);

% keep rig/experimenter specific inforamtion
p.defaultParameters.session.rig          = rig;
p.defaultParameters.session.experimenter = experimenter;

% ------------------------------------------------------------------------%
%% run the experiment
p.run;

% ------------------------------------------------------------------------%
%% Ensure DataPixx is closed
if(Datapixx('IsReady'))
    Datapixx('Close');
end
