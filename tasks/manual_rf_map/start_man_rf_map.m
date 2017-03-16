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

% prepare for eye tracking and joystick monitoring
SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use
SS.mouse.useAsEyepos  = 0;

SS.pldaps.nosave = 1;  % For now do not bother with the pldaps file format, use plain text file instead.

% For now turn off reward since not setup for rig2 where I am testing this.
SS.datapixx.useForReward = 0;

% Turn off joystick
SS.datapixx.useJoystick = 0;

% SS.datapixx.adc.channels                        = []; % List of channels to collect data from. Channel 3 is as default reserved for reward.               !!!
% SS.datapixx.adc.channelMapping = {'AI.adc'}; % Specify where to store the collected data. WZ: Seems that the names need to start with 'datapixx.' to ensure that the fields are created (apparently only in the datapixx substructure).


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