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

p.defaultParameters.epoch.GetReady       =  -1;  % Wait to initialize task
p.defaultParameters.epoch.CheckBarRel    =   0;  % time period to ensure bar release (WZ: might be merged with GetReady)
p.defaultParameters.epoch.WaitStart      =   1;  % Wait for a joystick press to indicate readiness to work on a trial
p.defaultParameters.epoch.WaitResponse   =   2;  % Wait for task response (saccade or joystick state change)
p.defaultParameters.epoch.WaitPress      =   3;  % Wait for a joystick press
p.defaultParameters.epoch.WaitRelease    =   4;  % Wait for joystick release
p.defaultParameters.epoch.WaitFix        =   5;  % Target not acquired yet, wait for fixation
p.defaultParameters.epoch.Fixating       =   6;  % Ongoing fixation
p.defaultParameters.epoch.Pressing       =   7;  % Ongoing joystick press
p.defaultParameters.epoch.WaitTarget     =   8;  % wait for target onset
p.defaultParameters.epoch.WaitGo         =   9;  % delay period before response is required
p.defaultParameters.epoch.WaitReward     =  10;  % delay before reward delivery
p.defaultParameters.epoch.TaskEnd        =  11;  % trial completed (succesful or not)
p.defaultParameters.epoch.TimeOut        =  12;  % extra penalty (might just be merged with ITI)
p.defaultParameters.epoch.ITI            =  13;  % inter-trial interval: wait before next trial to start

p.defaultParameters.epoch.AbortError     = 666;  % Error occurred, finish trial (maybe add time out)

