% fix_train_taskdef.m
%
%
%
%

%% Condition/Block design
p.trial.task.EqualCorrect = 0; % if set to one, trials within a block are
%repeated until the same number of correct trials is obtained for all
%conditions

%% Reward
p.trial.task.Reward.Pull    = 0;            
% If 1 then give reward for pulling the joystick
p.trial.task.Reward.PullRew = 0.2;           
% reward amount for pulling joystick (if p.trial.task.Reward.Pull == 1)

p.trial.task.Reward.IncrConsecutive = 1;     
% increase reward for subsequent correct trials. Otherwise reward will 
% increase with the number of hits (but not correct rejections)
% AB: 
p.trial.task.Reward.Dur  = [0.25, 0.50, 0.75]; 
% reward duration [s], user vector to specify values used for incremental
% reward scheme
p.trial.task.Reward.Step = [2, 4, 6];        
% define the number of trials when to increase reward. CVector length can 
% not be longer than p.trial.task.Reward.Dur

p.trial.task.Reward.Lag    = 0.10;           
% Delay between response and reward onset
p.trial.task.Reward.ManDur = 120;            
% reward duration [s] for reward given by keyboard presses
% AB: units seem wrong here, 120 seconds??

%% Task Timings
p.trial.task.Timing.WaitStart   = 2.50;    
% maximal time period [s] in seconds to press the lever in order to start a
% trial.
p.trial.task.Timing.WaitResp    = 1.50;    
% Only response times [s] after this wait period will be considered 
% stimulus driven responses

% inter-trial interval
p.trial.task.Timing.MinITI      = 0.5;    % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI      = 1.5;    % maximum time period [s] between subsequent trials

p.trial.task.Timing.TimeOut     =  2;     % Time [s] out for incorrect responses
p.trial.task.Timing.PullTimeOut =  2;     % Minimum time [s] passed before a trial starts after random lever presses

p.trial.behavior.joystick.minRT =  0.20;     % If a response occurs prior this time it is considered an early response