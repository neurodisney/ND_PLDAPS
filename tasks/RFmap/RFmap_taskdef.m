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
p.trial.stim.LocCtr = [-2, -3];

p.trial.stim.RFmeth = 'coarse';
%p.trial.stim.RFmeth = 'fine';

% define grating parameters depending on mapping approach.
switch p.trial.stim.RFmeth
    case 'coarse'
        p.trial.stim.ori      = [0, 90];   % orient of grating
        p.trial.stim.radius   = 0.75;      % size of grating 
        p.trial.stim.contrast = 1;         % intensity contrast
        p.trial.stim.sFreq    = 1.5;       % spatial frequency 
        p.trial.stim.tFreq    = 0;         % temporal frequency (0 means static grating) 
        p.trial.stim.grdStp   = 0.25;      % spacing of grating centers 
        
        p.trial.stim.xRange   = [-9, -1];
        p.trial.stim.yRange   = [-9, -1];

        % do not change below
        p.trial.stim.LocCtr   = [mean(p.trial.stim.xRange),    ...
                                 mean(p.trial.stim.yRange)];  
        p.trial.stim.extent   = [range(p.trial.stim.xRange),   ...
                                 range(p.trial.stim.yRange)];  

    case 'fine'
        p.trial.stim.ori      = [0:7] * 22.5;
        p.trial.stim.radius   = 0.75;
        p.trial.stim.contrast = 1;
        p.trial.stim.sFreq    = 1.5;
        p.trial.stim.grdStp   = 0.1;
        
        p.trial.stim.extent   = [2, 2];
        
        % do not change below
        p.trial.stim.xRange   =  [-1, 1] * p.trial.stim.extent(1) + p.trial.stim.LocCtr(1);
        p.trial.stim.yRange   =  [-1, 1] * p.trial.stim.extent(2) + p.trial.stim.LocCtr(2);
end

p.trial.stim.GRATING.res    = 300;
p.trial.stim.GRATING.fixWin = 0;

p.trial.stim.OnTime  = 0.1;   % How long each stimulus is presented
p.trial.stim.OffTime = 0.1;   % Gaps between succesive stimuli
p.trial.stim.Period  = p.trial.stim.OnTime + p.trial.stim.OffTime;

% ------------------------------------------------------------------------%
%% Drug delivery parameters
% TTL pulse series for pico spritzer
p.trial.datapixx.TTL_spritzerChan      = 5;    % DIO channel
p.trial.datapixx.TTL_spritzerDur       = 0.01; % duration of TTL pulse
p.trial.datapixx.TTL_spritzerNpulse    = 1;    % number of pulses in a series
p.trial.datapixx.TTL_spritzerPulseGap  = 0.01; % gap between subsequent pulses

p.trial.datapixx.TTL_spritzerNseries   = 1;    % number of pulse series
p.trial.datapixx.TTL_spritzerSeriesGap = 30 ;  % gap between subsequent series

% ------------------------------------------------------------------------%
%% Reward
% manual reward from experimenter
p.trial.reward.ManDur = 0.05;         % reward duration [s] for reward given by keyboard presses

p.trial.reward.Dur    = 0.05;         % Reward given after each complete stim presentation
p.trial.reward.Period = 0.25;

p.trial.reward.jackpotDur      = 0.12; % Reward for holding fixation until jackpotTime
p.trial.reward.IncrConsecutive = 1;  % use rewarding scheme that gives more rewards with subsequent correct trials
p.trial.reward.nPulse          = 1;  % number of reward pulses
p.trial.reward.PulseStep       = [2,5]; % increase number of pulses with this trial number

% ------------------------------------------------------------------------%
%% Timing
p.trial.task.Timing.WaitFix = 4;    % Time to wait for fixation before NoStart

% Main trial timings
p.trial.task.fixLatency     = 0.15;  % Time to hold fixation before mapping begins

p.trial.task.jackpotTime    = 6;   % How long stimuli are presented before trial ends and jackpot is given

% inter-trial interval
p.trial.task.Timing.MinITI  = 1.0;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 2.5;  % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos   = [0,0];
p.trial.stim.FIXSPOT.type  = 'rect';   % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color = 'white';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size  = 0.15;     % size of the fixation spot

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
