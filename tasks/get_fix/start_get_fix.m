function start_get_fix(subjname, rig, experimenter)
% use this script to define a default configuration in order to create a
% pldaps object and run it with the get_fix trial function.
%
%
% wolf zinke, Dec. 2016

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
%% load default settings into a struct
SS = ND_RigDefaults;    % load default settings according to the current rig setup

% ------------------------------------------------------------------------%
%% Define task related functions

% function to set up experiment (and maybe also including the trial function)
exp_fun = 'get_fix';

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun;     % This function is both, set-up for the experiment session as well as the trial function
SS.task.TaskDef  = 'get_fix_taskdef';  % function that provides task specific parameter definitions
SS.plot.routine  = 'get_fix_plots';    % function for online plotting of session progress

% ------------------------------------------------------------------------%
%% Enable required components if needed
SS.sound.use                  = 0; % no sound for now
SS.behavior.fixation.use      = 0; % eye position is behavioral relevant
SS.behavior.joystick.use      = 1; % joystick is behavioral relevant
SS.plot.do_online             = 1; % run online data analysis between two subsequent trials
SS.pldaps.nosave              = 0; % disable saving data to pds files
SS.pldaps.draw.joystick.use   = 1; % draw joystick states on control screen
SS.pldaps.draw.eyepos.use     = 1; % enable drawing of the eye position.
SS.pldaps.draw.photodiode.use = 0; % enable drawing the photo diode square

SS.pldaps.GetTrialStateTimes  = 1; % for debugging, save times when trial states are called

% ------------------------------------------------------------------------%
%% make modifications of default settings

SS.display.bgColor    = [50, 50, 50] / 255;  % change background color
SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use

% ------------------------------------------------------------------------%
%% create the pldaps class
p = pldaps(subjname, SS, exp_fun);

% keep rig/experimenter specific inforamtion
p.defaultParameters.session.rig          = rig;
p.defaultParameters.session.experimenter = experimenter;

% ------------------------------------------------------------------------%
%% run the experiment
p.run

% ------------------------------------------------------------------------%
%% Ensure DataPixx is closed
if(Datapixx('IsReady'))
    Datapixx('Close');
end

