function p = InitFixTrain_taskdef(p)
% Initial fixation training task
%
%   This task should be used to train an animal to keep its gaze continously on a target item
%   and basically  prepare for eye calibration. Fixation targets could be shown at random location
%   or location is manually controlled. ANd depending on the settings, the animal could receive an
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
p.trial.reward.GiveInitial    = 1; % If set to 1 reward animal when starting to fixate
p.trial.reward.GiveSeries     = 1; % If set to 1 give a continous series of rewards until end of fixation period

p.trial.reward.ManDur         = 0.2;  % reward duration [s] for reward given by keyboard presses
p.trial.reward.Dur            = 0.1;  % reward duration for pulse in reward series while keeping fixation
p.trial.reward.InitialRew     = 0.2;  % duration of the initial reward

p.trial.reward.jackpotTime    = 6;    % total time required to fixate to get full reward
p.trial.reward.jackpotDur     = 0.4;  % final reward after keeping fixation for the complete time

p.trial.reward.Step           = [0, 4, 12];       % define the number of subsequent rewards after that the next delay period should be used.
p.trial.reward.Period         = [0.4 0.25 0.15];  % the period between one reward and the next NEEDS TO BE GREATER THAN Dur

p.trial.reward.MinWaitInitial = 0.4;
p.trial.reward.MaxWaitInitial = 0.6;

% ------------------------------------------------------------------------%
%% Timing
p.trial.task.Timing.WaitFix = 1.5;  % Time to get a solid fixation before trial ends unsuccessfully

% inter-trial interval
p.trial.task.Timing.MinITI  = 0.75;   % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 1.5;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;     % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.Block.maxBlocks    = -1;  % if negative blocks continue until experimenter stops, otherwise task stops after completion of all blocks
p.trial.Block.EqualCorrect =  0;  % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% condition 1
c1.Nr = 1;
c1.reward.MinWaitInitial  = 0.05; % min wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c1.reward.MaxWaitInitial  = 0.1;  % max wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c1.reward.InitialRew      = 0.1;  % duration for initial reward pulse

% condition 2
c2.Nr = 2;
c2.reward.MinWaitInitial  = 0.1;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c2.reward.MaxWaitInitial  = 0.25; % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c2.reward.InitialRew      = 0.2;  % duration for initial reward pulse

% condition 3
c3.Nr = 3;
c3.reward.MinWaitInitial  = 0.25; % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c3.reward.MaxWaitInitial  = 0.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c3.reward.InitialRew      = 0.4;  % duration for initial reward pulse

% condition 4
c4.Nr = 4;
c4.reward.MinWaitInitial  = 0.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c4.reward.MaxWaitInitial  = 1.0;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c4.reward.InitialRew      = 0.6;  % duration for initial reward pulse

% condition 5
c5.Nr = 5;
c5.reward.MinWaitInitial  = 1.0;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c5.reward.MaxWaitInitial  = 1.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
c5.reward.InitialRew      = 0.8;  % duration for initial reward pulse

p.trial.Block.Conditions  = {c1, c2, c3};
% p.trial.Block.Conditions  = {c1, c2};

p.trial.Block.maxBlockTrials =  [2, 3, 1];  % how often to repeat each condition within a block
% p.trial.Block.maxBlockTrials =  [2, 2];  % how often to repeat each condition within a block

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.type    = 'disc';   % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.size    = 0.5;        % size of the fixation spot
% p.trial.stim.FIXSPOT.fixWin  = 6;         %

% color options (make sure colors are defined!)
%p.trial.task.Color_list = Shuffle({'white', 'dRed', 'lRed', 'dGreen', 'orange', 'cyan'});
p.trial.task.Color_list = {'white'};

% Enable random positions
% p.trial.task.RandomPos = 0;
p.trial.task.RandomPosRange = [5, 5];  % range of x and y dva for random position

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.025;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.025;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix + p.trial.reward.MaxWaitInitial + p.trial.reward.jackpotTime); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

