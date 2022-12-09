function p = RFmap_taskdef(p)
% define task parameters for the joystick training task.
% This function will be executed at every trial start, hence it is possible
% to edit it while the experiment is in progress in order to apply online
% modifications of the task.
%
% TODO: - Make sure that changed parameters are kept in the data file, i.e.
%         that there is some log when changes happened
%       - read in only changes in order to allow quicker manipulations via the
%         keyboard without overwriting it every time by calling this routine
%
%
% Nate Faber & wolf zinke, 2017

% ------------------------------------------------------------------------%
%% Grating stimuli parameters

% stimuli could be used in two ways, first using a 'coarse' mapping approach where a wider area 
% will be covered quickly, and second a 'fine' mapping approach that characterizes a smaller
% region with much more detail. Define here what mode to use. 
%

% !!! MAKE SURE TO ADJUST LOCATION FOR 'FINE' MAPPING !!!
p.trial.stim.LocCtr = [-6 -1];

p.trial.stim.RFmeth = 'coarse';
%p.trial.stim.RFmeth = 'fine';

% define grating parameters depending on mapping approach.
switch p.trial.stim.RFmeth
    case 'coarse'
        p.trial.stim.coarse.ori      = [0, 45, 90, 135, 180];   % orient of grating
        %p.trial.stim.coarse.ori      = 90;   % orient of grating
        p.trial.stim.coarse.radius   = 0.75;      % size of grating 
        %p.trial.stim.coarse.contrast = [0, 0.014, 0.023, 0.034, 0.081, 0.187, 0.285, 0.658, 0.9600];         % intensity contrast
        p.trial.stim.coarse.contrast = 0.15;         % intensity contrast
        p.trial.stim.coarse.sFreq    = 1.5;       % spatial frequency  
        p.trial.stim.coarse.tFreq    = 0;         % temporal frequency (0 means static grating) 
        p.trial.stim.coarse.grdStp   = 0.1;      % spacing of grating centers       
        
        p.trial.stim.coarse.xRange   = [-9 -2];
        p.trial.stim.coarse.yRange   = [-9 -2];

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
        p.trial.stim.fine.grdStp   = 0.5;
        
        p.trial.stim.fine.extent   = [-2, 2; -2, 2];
        
        % do not change below
        p.trial.stim.fine.xRange   =  [-1, 1] * p.trial.stim.extent(1) + p.trial.stim.LocCtr(1);
        p.trial.stim.fine.yRange   =  [-1, 1] * p.trial.stim.extent(2) + p.trial.stim.LocCtr(2);
end

p.trial.stim.GRATING.res    = 300;
p.trial.stim.GRATING.fixWin = 0;

p.trial.stim.OnTime  = 0.1;   % How long each stimulus is presented
p.trial.stim.OffTime = 0.1;   % Gaps between succesive stimuli
p.trial.stim.Period  = p.trial.stim.OnTime + p.trial.stim.OffTime;

% ------------------------------------------------------------------------%
%% Drug delivery parameters
% TTL pulse series for pico spritzer
%p.trial.datapixx.TTL_spritzerChan      = 5;    % DIO channel
%p.trial.datapixx.TTL_spritzerDur       = 0.025; % duration of TTL pulse
%p.trial.datapixx.TTL_spritzerNpulse    = 1;    % number of pulses in a series
%p.trial.datapixx.TTL_spritzerPulseGap  = .1; % gap between subsequent pulses

%p.trial.datapixx.TTL_spritzerNseries   = 1;    % number of pulse series
%p.trial.datapixx.TTL_spritzerSeriesGap = 30 ;  % gap between subsequent series

% Behaviorally integrated drug parameters -CR
p.trial.datapixx.TTL_ON = 1;
p.trial.datapixx.TTL_chan = 5;
p.trial.datapixx.TTL_PulseDur = .025; 
p.trial.datapixx.TTL_Npulse = 1;
p.trial.datapixx.TTL_GapDur = .10; 
p.trial.datapixx.TTL_Nseries = 1;
p.trial.datapixx.TTL_SeriesPause = 0;
p.trial.datapixx.TTL_InjStrobe = 6110; 

% ------------------------------------------------------------------------%
%% Reward

% manual reward from experimenter
p.trial.reward.GiveInitial  = 1; % If set to 1 reward animal when starting to fixate
p.trial.reward.InitialRew   = 0.125; % duration of the initial reward
p.trial.reward.GiveSeries   = 0; % If set to 1 give a continous series of rewards until end of fixation period
p.trial.reward.Dur          = 0.225; % reward duration for pulse in reward series while keeping fixation
p.trial.reward.Step         = [0, 6, 12, 18 24];     % define the number of subsequent rewards after that the next delay period should be used.
p.trial.reward.Period       = [0.5 1 1.5 2 2.5]; % the period between one reward and the next NEEDS TO BE GREATER THAN Dur
p.trial.reward.ManDur       = 0.05; % reward duration [s] for reward given by keyboard presses
p.trial.reward.jackpotDur   = 0.125;  % final reward after keeping fixation for the complete time
p.trial.reward.jackpotnPulse = 1;

% ------------------------------------------------------------------------%
%% Timing
p.trial.task.Timing.WaitFix = 1.4;    % Time to wait for fixation before NoStart

% Main trial timings
p.trial.task.CurRewDelay    = 0.27;  % Time to first reward
p.trial.task.fixLatency     = 0.17;  % Time to hold fixation before mapping begins
p.trial.task.jackpotTime    = 0.65;   % How long stimuli are presented before trial ends and jackpot is given
p.trial.task.stimOnTime     = 0.1;   % How long each stimulus is presented
p.trial.task.stimOffTime    = 0.1;   % Gaps between succesive stimuli

% inter-trial interval
p.trial.task.Timing.MinITI  = 1.0;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 2.5;  % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos   = [0,0];
p.trial.stim.FIXSPOT.type  = 'rect';   % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color = 'dRed';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size  = 0.25;     % size of the fixation spot

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
