function p = ND_TaskEpochs(p)
% Defines possible task epochs that can be called during a trial.
%
%
% wolf zinke, Feb. 2017


disp('****************************************************************')
disp('>>>>  ND:  Defining Task Epochs <<<<')
disp('****************************************************************')
disp('');

% ------------------------------------------------------------------------%
%% Define task epoch flags
% 
% Use minimalistic approach by trying to define more general epochs that 
% can be used within a broader range of meanings instead of defining a lot 
% of very specific epochs that only make sense in one single task.
%
% TODO: Get a set of required task epochs with a clear naming convention

p.defaultParameters.epoch.GetReady        =  -1;  % Wait to initialize task
p.defaultParameters.epoch.WaitStart       =   1;  % Wait for a joystick press to indicate readiness to work on a trial
p.defaultParameters.epoch.WaitResponse    =   2;  % Wait for task response (saccade or joystick state change)
p.defaultParameters.epoch.CheckResponse   =   4;  % A response occurred, check if it was a correct one
p.defaultParameters.epoch.TrialStart      =   3;  % trial starts for animal
p.defaultParameters.epoch.WaitEnd         =  14;  % trial completed (successful or not)
p.defaultParameters.epoch.TaskEnd         =  11;  % trial completed (successful or not)

p.defaultParameters.epoch.WaitCue         =   5; 
p.defaultParameters.epoch.WaitChange      =   6;

p.defaultParameters.epoch.WaitTarget      =   8;  % wait for target onset
p.defaultParameters.epoch.WaitGo          =   9;  % delay period before response is required

p.defaultParameters.epoch.WaitReward      =  10;  % delay before reward delivery

p.defaultParameters.epoch.TimeOut         =  12;  % extra penalty (might just be merged with ITI)
p.defaultParameters.epoch.ITI             =  13;  % inter-trial interval: wait before next trial to start

p.defaultParameters.epoch.AbortError      = 666;  % Error occurred, finish trial (maybe add time out)

% joystick related
if(p.defaultParameters.behavior.joystick.use)
    p.defaultParameters.epoch.CheckBarRel =  40;  % time period to ensure bar release (WZ: might be merged with GetReady)
    p.defaultParameters.epoch.Pressing    =  41;  % Ongoing joystick press
    p.defaultParameters.epoch.WaitPress   =  42;  % Wait for a joystick press
    p.defaultParameters.epoch.WaitRelease =  43;  % Wait for joystick release
end

% fixation related
if(p.defaultParameters.behavior.fixation.use)
    p.defaultParameters.epoch.WaitFix       =   31;  % Target not acquired yet, wait for fixation
    p.defaultParameters.epoch.Fixating      =   32;  % Ongoing fixation
    p.defaultParameters.epoch.LostFix       =   33;  % fixation break detected, wait to verify clear break
    p.defaultParameters.epoch.Saccade       =   34;  % saccade needed
    p.defaultParameters.epoch.WaitSaccade   =   36;  % waiting for saccade response
    p.defaultParameters.epoch.BreakFixCheck =   35;  % Fixation break has occured, check where eyes have gone
end

% Wait for intervention from experimenter
p.defaultParameters.epoch.WaitExperimenter =  20;

