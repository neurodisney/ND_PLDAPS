function start_joy_train(subjname)

% use this script to define a default configuration in order to create a
% pldaps object and run it with the joy_train trial function.
%
%
% wolf zinke, Dec. 2016

% not sure how the pldaps wanted to solve this, their task concept for
% specifying a trial sub-struct just does not work, try  to use a global
% definition here to cope with it.
if(exist('task','var'))
    clear task
end


% global task
task = 'joy_train';  % this will be used to create a sub-struct in the trial structure

% ------------------------------------------------------------------------%
%% Set default variables

% name of subject. This will be used to create a subdirectory with this name.
if(~exist('subjname','var') || isempty(subjname))
    subjname = 'tst';
end

% function to set up experiment (and maybe also including trial function)
exp_fun = 'joy_task';

% ------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_RigDefaults;    % load default settings according to the current rig setup

% define trial function (could be identical with the experimentSetupFile that is passed as argument to the pldaps call
SS.pldaps.trialFunction = exp_fun; % This function is both, set-up for the experiment session as well as the trial function

% ------------------------------------------------------------------------%
%% make modifications of default settings
SS.sound.use          = 0;  % no sound for now
SS.display.bgColor    = [50, 50, 50] / 255;

% prepare for eye tracking and joystick monitoring
SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use
SS.mouse.useAsEyepos  = 0;

% determine the path to store data files
SS.pldaps.dirs.data = fullfile(SS.pldaps.dirs.data, subjname, task, datestr(now,'yyyy_mm_dd'));

SS.pldaps.nosave = 1;  % For now do not bother with the pldaps file format, use plain text file instead.

% ------------------------------------------------------------------------%
%% create the pldaps class
p = pldaps(subjname, SS, exp_fun);

% ------------------------------------------------------------------------%
%% adjust pldaps class settings
p.defaultParameters.TaskName = task;

% ------------------------------------------------------------------------%
%% run the experiment
p.run

% ------------------------------------------------------------------------%
%% Ensure DataPixx is closed
if(Datapixx('IsReady'))
    Datapixx('Close');
end

