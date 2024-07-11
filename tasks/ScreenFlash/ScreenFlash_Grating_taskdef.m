function p = ScreenFlash_Grating_taskdef(p)
% define task for ScreenFlash of a whole screen grating. Define grating
% parameters here
%
% Based off of RFmap code
%
%
% Veronica Galvin, Sept. 2021

% ------------------------------------------------------------------------%
%% Grating stimuli parameters

p.trial.stim.LocCtr = [-1, 1];

p.trial.stim.RFmeth = 'coarse';
% p.trial.stim.RFmeth = 'fine';

% define grating parameters depending on mapping approach.
switch p.trial.stim.RFmeth
    case 'coarse'
        p.trial.stim.coarse.ori      = 45;          % orient of grating
        p.trial.stim.coarse.radius   = 50.0;        % size of grating 
        p.trial.stim.coarse.contrast = 0.75;           % intensity contrast
        p.trial.stim.coarse.sFreq    = 0.5;         % spatial frequency 
        p.trial.stim.coarse.tFreq    = 0;           % temporal frequency (0 means static grating) 
        p.trial.stim.coarse.grdStp   = 0.01;         % spacing of grating centers       
        
        p.trial.stim.coarse.xRange   = [-0.0, -0.0];
        p.trial.stim.coarse.yRange   = [-0.0, -0.0];

        % do not change below
        p.trial.stim.LocCtr   = [mean(p.trial.stim.coarse.xRange),    ...
                                 mean(p.trial.stim.coarse.yRange)];  
        p.trial.stim.extent   = [range(p.trial.stim.coarse.xRange),   ...
                                 range(p.trial.stim.coarse.yRange)];  

    case 'fine'
        p.trial.stim.fine.ori      = [0:7] * 22.5;
        p.trial.stim.fine.radius   = 0.75;
        p.trial.stim.fine.contrast = 0.9;
        p.trial.stim.fine.sFreq    = 1.5;
        p.trial.stim.fine.grdStp   = 0.25;
        
        p.trial.stim.fine.extent   = [2, 2];
        
        % do not change below
        p.trial.stim.fine.xRange   =  [-1, 1] * p.trial.stim.extent(1) + p.trial.stim.LocCtr(1);
        p.trial.stim.fine.yRange   =  [-1, 1] * p.trial.stim.extent(2) + p.trial.stim.LocCtr(2);
end

p.trial.stim.GRATING.res    = 300;
p.trial.stim.GRATING.fixWin = 0;

p.trial.stim.OnTime  = 0.5;   % How long each stimulus is presented
p.trial.stim.OffTime = 5.0;   % Gaps between succesive stimuli
p.trial.stim.Period  = p.trial.stim.OnTime + p.trial.stim.OffTime;

% ------------------------------------------------------------------------%
% Behaviorally integrated drug parameters -CR
p.trial.datapixx.TTL_ON = 0;
p.trial.datapixx.TTL_chan = 5;
p.trial.datapixx.TTL_PulseDur = .05; 
p.trial.datapixx.TTL_Npulse = 1;
p.trial.datapixx.TTL_GapDur = 1.5; 
p.trial.datapixx.TTL_Nseries = 1;
p.trial.datapixx.TTL_SeriesPause = 0;
p.trial.datapixx.TTL_InjStrobe = 6110; 

% ------------------------------------------------------------------------%
%% Reward

% manual reward from experimenter
p.trial.reward.GiveInitial  = 0; % If set to 1 reward animal when starting to fixate
p.trial.reward.InitialRew   = 0.1; % duration of the initial reward
p.trial.reward.GiveSeries   = 0; % If set to 1 give a continous series of rewards until end of fixation period
p.trial.reward.Dur          = 0.0; % reward duration for pulse in reward series while keeping fixation
p.trial.reward.Step         = [0];     % define the number of subsequent rewards after that the next delay period should be used.
p.trial.reward.Period       = [0]; % the period between one reward and the next NEEDS TO BE GREATER THAN Dur
p.trial.reward.ManDur       = 0.05; % reward duration [s] for reward given by keyboard presses
p.trial.reward.jackpotDur   = 0.0;  % fSS.datapixx.useJoystick       = 0;inal reward after keeping fixation for the complete time
p.trial.reward.jackpotnPulse = 0;

% ------------------------------------------------------------------------%
%% Timing
p.trial.task.Timing.WaitFix = 4;    % Time to wait for fixation before NoStart

% Main trial timings
p.trial.task.CurRewDelay    = 0.5;  % Time to first reward
p.trial.task.fixLatency     = 0.15;  % Time to hold fixation before mapping begins
p.trial.task.jackpotTime    = 4;   % How long stimuli are presented before trial ends and jackpot is given
p.trial.task.stimOnTime     = 0.15;   % How long each stimulus is presented
p.trial.task.stimOffTime    = 2.00;   % Gaps between succesive stimuli

% inter-trial interval
p.trial.task.Timing.MinITI  = 0.5;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 2.0;  % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos   = [0,0];
p.trial.stim.FIXSPOT.type  = 'rect';   % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color = 'white';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size  = 0.0001;     % size of the fixation spot

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.050;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.150;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Task parameters
p.trial.task.breakFixCheck = 0.2; % Time after a stimbreak where if task is marked early or stim break is calculated

% ------------------------------------------------------------------------%
%% Eye Signal Sampling
p.trial.behavior.fixation.Sample    = 75;

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.task.EqualCorrect = 0; % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% ------------------------------------------------------------------------%
%% Break color
p.trial.display.breakColor = 'black';
% ------------------------------------------------------------------------%
