% use this script to define a default configuration in order to create a
% pldaps object and run it with the joy_train trial function.
%
%
% wolf zinke, Dec. 2016


% ------------------------------------------------------------------------%
%% Set default variables
subjname = 'test';

trial_fun = @joy_task;

% not sure how the pldaps wanted to solve this, their task concept for
% specofying a trial sub-struct just does not work, try  to use a global
% definition here to cope with it.
if(exist('task','var'))
    clear task
end

global task
task = 'joy_train';  % this will be used to create a sub-structur in the trial structure

% ------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_Rig_Defaults;    % load default settings according to the current rig setup

% make modifications of default settings
SS.display.screenSize = [100, 100, 900, 700]; % do not use full screen
SS.sound.use = 0;  % no sound for now

% prepare for eye tracking and joystick monitoring
SS.datapixx.adc.srate = 1000; % for a 1k tracker, less if you don’t plan to use it for offline use
SS.mouse.useAsEyepos  = 1;

% SS.datapixx.adc.channels          = [4, 5]; % List of channels to collect data from.        ### ignore eye position for now, so need to acquire the first three channels       
% SS.datapixx.adc.channelMapping    = {'joystick.X', 'joystick.Y'};   % label data channels

% ------------------------------------------------------------------------%
%% create the pldaps class
p = pldaps(trial_fun, subjname, SS);

% ------------------------------------------------------------------------%
%% adjust pldaps class settings


% ------------------------------------------------------------------------%
%% task dependent default settings
% I guess this needs to be done on the pldaps object not on the
% settingstruct because the pldaps function initializes the trial struct.

p.trial.flagNextTrial = 0; % flag for ending the trial

% task epoch flags
p.trial.(task).CurrEpoch = NaN;   % Indicator for the current task epoch

% Assign numbers to task epochs in order to identify the current task epoch
% in the trial function like that:
%  switch p.trial.(task).CurrEpoch
%       case p.trial.(task).epoch.WaitPress
%       case p.trial.(task).epoch.WaitTarget
%  end

p.trial.(task).epoch.WaitPress     = 1;  % Wait for a joystick press to indicate readiness to work on a trial
p.trial.(task).epoch.WaitResponse  = 2;  % Wait for a task response
p.trial.(task).epoch.WaitRelease   = 3;  % Wait for joystick release
p.trial.(task).epoch.WaitTarget    = 4;  % wait for target onset 
p.trial.(task).epoch.WaitGo        = 6; 
p.trial.(task).epoch.WaitReward    = 7; 
p.trial.(task).epoch.WaitNextTrial = 8; 


% define potential task outcomes
p.trial.(task).outcome.Correct     = 0;  % correct performance, no error occurred
p.trial.(task).outcome.NoPress     = 1;  % No joystick press occurred to initialise trial
p.trial.(task).outcome.Abort       = 2;  % early joystick release prior stimulus onset
p.trial.(task).outcome.Early       = 3;  % release prior to response window
p.trial.(task).outcome.False       = 4;  % wrong response within response window
p.trial.(task).outcome.Late        = 5;  % response occurred after response window
p.trial.(task).outcome.Miss        = 6;  % no response at a reasonable time





% ------------------------------------------------------------------------%
%% run the experiment
p.run
