function start_man_rf_map(subjname)

% use this script to define a default configuration in order to create a
% pldaps object and run it with the rf_map trial function.
%
% Nate Faber, Feb. 2017
% Adapted from:
% wolf zinke, Dec. 2016


% ------------------------------------------------------------------------%
%% Set default variables

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('subjname','var') || isempty(subjname))
    subjname = 'tst';
end

% function to set up experiment (and maybe also including trial function)
exp_fun = 'man_rf_map';

% ------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_RigDefaults;    % load default settings according to the current rig setup

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun; % This function is both, set-up for the experiment session as well as the trial function

% ------------------------------------------------------------------------%
%% make modifications of default settings
SS.sound.use          = 1;
SS.display.bgColor    = [0.5, 0.5, 0.5];

% Use the mouse
SS.mouse.use = 1;

SS.pldaps.nosave = 1;  % For now do not bother with the pldaps file format, use plain text file instead.

% For now turn off reward since not setup for rig2 where I am testing this.
SS.datapixx.useForReward = 0;

% Turn off joystick
SS.datapixx.useJoystick = 0;

% SS.datapixx.adc.channels                        = []; % List of channels to collect data from. Channel 3 is as default reserved for reward.               !!!
% SS.datapixx.adc.channelMapping = {'AI.adc'}; % Specify where to store the collected data. WZ: Seems that the names need to start with 'datapixx.' to ensure that the fields are created (apparently only in the datapixx substructure).

SS.sound.use                  = 0; % no sound for now
SS.behavior.fixation.use      = 0; % eye position is behavioral relevant
SS.behavior.joystick.use      = 0; % joystick is behavioral relevant
SS.plot.do_online             = 0; % run online data analysis between two subsequent trials
SS.pldaps.nosave              = 0; % disable saving data to pds files
SS.pldaps.draw.joystick.use   = 0; % draw joystick states on control screen
SS.pldaps.draw.eyepos.use     = 0; % enable drawing of the eye position.
SS.pldaps.draw.photodiode.use = 0; % enable drawing the photo diode square
SS.datapixx.useForReward      = 0; % use datapixx analog output for reward

SS.pldaps.draw.grid.use       = 0;

SS.datapixx.useAsEyepos       = 0;
SS.datapixx.useJoystick       = 0;
SS.datapixx.TTL_trialOn       = 0;

SS.behavior.fixation.useCalibration = 0;

SS.behavior.fixation.on = 0; % fixation.on for this task

SS.pldaps.GetTrialStateTimes  = 0; % for debugging, save times when trial states are called

% ------------------------------------------------------------------------%
%% create the pldaps class
p = pldaps(subjname, SS, exp_fun);


% ------------------------------------------------------------------------%
%% run the experiment
p.run

% ------------------------------------------------------------------------%
%% Ensure DataPixx is closed
if(Datapixx('IsReady'))
    Datapixx('Close');
end