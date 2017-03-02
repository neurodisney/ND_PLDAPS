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
% TODO: Get a set of required task epochs with a clear naming convention
p.defaultParameters.epoch.GetReady       =   0;  % Wait to initialize task
p.defaultParameters.epoch.WaitStart      =   1;  % Wait for a joystick press to indicate readiness to work on a trial
p.defaultParameters.epoch.WaitResponse   =   2;  % Wait for joystick release
p.defaultParameters.epoch.WaitPress      =   3;  % Target not acquired yet, wait for fixation
p.defaultParameters.epoch.WaitRelease    =   4;  % Target not acquired yet, wait for fixation
p.defaultParameters.epoch.WaitFix        =   5;  % Target not acquired yet, wait for fixation
p.defaultParameters.epoch.WaitTarget     =   6;  % wait for target onset
p.defaultParameters.epoch.WaitGo         =   7;  % delay period before response is required
p.defaultParameters.epoch.WaitReward     =   8;  % delay before reward delivery
p.defaultParameters.epoch.TaskEnd        =   9;  % trial completed
p.defaultParameters.epoch.ITI            =  10;  % inter-trial interval: wait before next trial to start
p.defaultParameters.epoch.CheckBarRel    =  11;  % time period to ensure bar release

p.defaultParameters.epoch.AbortError     =  -1;  % Error occurred, finish trial (maybe add time out)
