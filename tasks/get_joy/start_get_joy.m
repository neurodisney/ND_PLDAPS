function start_get_joy(subjname)

% use this script to define a default configuration in order to create a
% pldaps object and run it with the joy_train trial function.
%
%
% wolf zinke, Dec. 2016


% ------------------------------------------------------------------------%
%% Set default variables

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('subjname','var') || isempty(subjname))
    subjname = 'tst';
end

% function to set up experiment (and maybe also including trial function)
exp_fun = 'get_joy';

% ------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_RigDefaults;    % load default settings according to the current rig setup

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun; % This function is both, set-up for the experiment session as well as the trial function

% ------------------------------------------------------------------------%
%% make modifications of default settings
SS.sound.use          = 0;  % no sound for now
SS.display.bgColor    = [0.2, 0.2, 0.2];
SS.pldaps.draw.photodiode.use                   = 1;
% prepare for eye tracking and joystick monitoring
SS.mouse.useAsEyepos     = 0;
SS.datapixx.useAsEyepos  = 0;
SS.behavior.fixation.use = 0;

SS.pldaps.nosave = 0;  % For now do not bother with the pldaps file format, use plain text file instead.

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
