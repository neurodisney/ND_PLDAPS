% use this script to define a default configuration in order to create a
% pldaps object and run it with the joy_train trial function.
%
%
% wolf zinke, Dec. 2016

% not sure how the pldaps wanted to solve this, their task concept for
% specofying a trial sub-struct just does not work, try  to use a global
% definition here to cope with it.
if(exist('task','var'))
    clear task
end

% global task
task = 'joy_train';  % this will be used to create a sub-structur in the trial structure

% ------------------------------------------------------------------------%
%% Set default variables

% name of subject. This will be used to create a subdirectory with this name.
subjname = 'test';

% function to set up experiment (and maybe also including trial function)
exp_fun = 'joy_task'; 



% ------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_Rig_Defaults;    % load default settings according to the current rig setup

% make modifications of default settings
SS.display.screenSize = [100, 100, 1280, 1000]; % do not use full screen
SS.sound.use          = 0;  % no sound for now
SS.display.bgColor    = [50, 50, 50] / 255;

% prepare for eye tracking and joystick monitoring
SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use
SS.mouse.useAsEyepos  = 1;

% SS.datapixx.adc.channels          = [4, 5]; % List of channels to collect data from.        ### ignore eye position for now, so need to acquire the first three channels       
% SS.datapixx.adc.channelMapping    = {'joystick.X', 'joystick.Y'};   % label data channels

% determine the path to store data files
SS.pldaps.dirs.data = fullfile(SS.pldaps.dirs.data, subjname, task, datestr(now,'yyyy_mm_dd'));

SS.pldaps.nosave = 1;  % For now do not bother with the pldaps file format, use plain text file instead.


SS.pldaps.trialFunction = exp_fun; % This function is both, set-up for the experiment session as well as the trial function

% ------------------------------------------------------------------------%
%% create the pldaps class
p = pldaps(subjname, SS, exp_fun);
% ------------------------------------------------------------------------%
%% adjust pldaps class settings
p.defaultParameters.session.TaskName = task;

% ------------------------------------------------------------------------%
%% Ensure DataPixx is initialized
if(~Datapixx('IsReady'))
    dpx = Datapixx('Open');
    
    if(dpx~=1)
        error('Problem when initializeng DataPixx!');
    end
end

% ------------------------------------------------------------------------%
%% run the experiment
p.run

% ------------------------------------------------------------------------%
%% Ensure DataPixx is closed
if(Datapixx('IsReady'))
    dpx = Datapixx('Close');
end


