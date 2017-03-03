function start_joy_train(subjname, rig, experimenter)

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

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('rig','var') || isempty(rig))
    [~, rigname] = system('hostname');
    rig = str2num(rigname(4));
end

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('experimenter','var') || isempty(experimenter))
    experimenter = getenv('USER');
end

% function to set up experiment (and maybe also including trial function)
exp_fun = 'joy_train';

% ------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_RigDefaults;    % load default settings according to the current rig setup

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun; % This function is both, set-up for the experiment session as well as the trial function

% ------------------------------------------------------------------------%
%% make modifications of default settings
SS.sound.use          = 0;  % no sound for now
SS.display.bgColor    = [50, 50, 50] / 255;
SS.pldaps.draw.photodiode.use = 0;

% prepare for eye tracking and joystick monitoring
SS.datapixx.adc.srate    = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use
SS.mouse.useAsEyepos     = 0;
SS.datapixx.useAsEyepos  = 0;
SS.behavior.fixation.use = 0;

SS.pldaps.nosave         = 0;  
SS.pldaps.GetTrialStateTimes  = 1; 

% ------------------------------------------------------------------------%
%% create the pldaps class
p = pldaps(subjname, SS, exp_fun);

% keep rig/experimeter specific infroamtion
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

