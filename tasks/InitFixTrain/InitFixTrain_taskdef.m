function p = InitFixTrain_taskdef(p)
% Initial fixation training task
%
%   This task should be used to train an animal to keep its gaze continously on a target item
%   and basically  prepare for eye calibration. Fixation targets could be shown at random location
%   or location is manually controlled. And depending on the settings, the animal could receive an
%   ititial reward when starting to fixate, then receive a series of reward pulses until a specified
%   fixation time when a large reward will be given.
%
% TODO: -
%
%
% wolf zinke, Sep. 2017


% ------------------------------------------------------------------------%
%% Reward
% manual reward from experimenter
p.trial.reward.GiveInitial  = 0; % If set to 1 reward animal when starting to fixate
p.trial.reward.InitialRew   = 0.05; % duration of the initial reward

p.trial.reward.GiveSeries   = 0; % If set to 1 give a continous series of rewards until end of fixation period
p.trial.reward.Dur          = 0.1; % reward duration for pulse in reward series while keeping fixation
p.trial.reward.Step         = [0, 4, 8, 12];     % define the number of subsequent rewards after that the next delay period should be used.
p.trial.reward.Period       = [2.5 3.4 4.3 5.2]; % the period between one reward and the next NEEDS TO BE GREATER THAN Dur

p.trial.reward.ManDur       = 0.12; % reward duration [s] for reward given by keyboard presses

p.trial.reward.jackpotTime  = 0.15;     % total time required to fixate to get full reward
p.trial.reward.jackpotDur   = 0.3;  % final reward after keeping fixation for the complete time

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = 0.500; % minimum time to wait for robust fixation, if GiveInitial == 1 after this period a reward is given

p.trial.task.Timing.WaitFix = 3.0;  % Time to get a solid fixation before trial ends unsuccessfully

% inter-trial interval
p.trial.task.Timing.MinITI  = 0.5;   % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 1;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;     % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.Block.maxBlocks    = -1;  % if negative blocks continue until experimenter stops, otherwise task stops after completion of all blocks
p.trial.Block.EqualCorrect =  0;  % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% % condition 1
% c1.Nr = 1;
% c1.reward.MinWaitInitial  = 0.05; % min wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c1.reward.MaxWaitInitial  = 0.1;  % max wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% 
% % condition 2
% c2.Nr = 2;
% c2.reward.MinWaitInitial  = 0.1;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c2.reward.MaxWaitInitial  = 0.25; % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% 
% % condition 3
% c3.Nr = 3;
% c3.reward.MinWaitInitial  = 0.25; % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c3.reward.MaxWaitInitial  = 0.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% 
% % condition 4
% c4.Nr = 4;
% c4.reward.MinWaitInitial  = 0.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c4.reward.MaxWaitInitial  = 0.75;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% 
% % condition 5
% c5.Nr = 5;
% c5.reward.MinWaitInitial  = 0.75;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c5.reward.MaxWaitInitial  = 1.0;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% 
% % condition 6
% c6.Nr = 6;
% c6.reward.MinWaitInitial  = 1.0;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c6.reward.MaxWaitInitial  = 1.25;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% 
% % condition 7
% c7.Nr = 7;
% c7.reward.MinWaitInitial  = 1.25;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c7.reward.MaxWaitInitial  = 1.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% 
% % condition 8
% c8.Nr = 8;
% c8.reward.MinWaitInitial  = 1.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c8.reward.MaxWaitInitial  = 1.75;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
%  
% % condition 9
% c9.Nr = 9;
% c9.reward.MinWaitInitial  = 1.75;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c9.reward.MaxWaitInitial  = 2;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% 
% c0.Nr = 0;
% c0.reward.MinWaitInitial  = 0.75;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% c0.reward.MaxWaitInitial  = 0.75;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
% 
% 
% p.trial.Block.Conditions     = {c0};
% p.trial.Block.maxBlockTrials =  [1]; 

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.type = 'rect';   % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off' 
p.trial.stim.FIXSPOT.size = 0.4;     % size of the fixation spot

p.defaultParameters.stim.FIXSPOT.fixWin = 4;    
p.trial.behavior.fixation.FixWinStp = 0.5;  % refine resizing of fixation step for this task only(modify default rig settings)

% color options (make sure colors are defined!)
%p.trial.task.Color_list = Shuffle({'white', 'dRed', 'lRed', 'dGreen', 'orange', 'cyan'});
p.trial.task.Color_list = {'yellow'};

% Enable random positions
p.trial.task.RandomPos = 0; 
p.trial.task.RandomPosRange = [4, 4];  % range of x and y dva for random position

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.025;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.025;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

%p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix + p.trial.reward.MaxWaitInitial + p.trial.reward.jackpotTime); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.
