function p = DetectGrat_taskdef(p)
% define task parameters for the point of subjective equality task.
% This function will be executed at every trial start, hence it is possible
% to edit it while the experiment is in progress in order to apply online
% modifications of the task.
%
%
%
% wolf zinke, Dec. 2017

% ------------------------------------------------------------------------%
%% Reward

% manual reward from experimenter
p.trial.reward.ManDur         = 0.2;  % reward duration [s] for reward given by keyboard presses
p.trial.reward.IncrementTrial = [10,  150, 250,  400, 450, 500]; % increase number of pulses with this trial number
p.trial.reward.IncrementDur   = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1]; % increase number of pulses with this trial number
p.trial.reward.GiveInitial  = 1; % If set to 1 reward animal when starting to fixate
p.trial.reward.InitialRew   = 0.125; % duration of the initial reward

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = ND_GetFixDur(.15, 0.25, [], [], 1, .05); % minimum time to wait for robust fixation

p.trial.task.Timing.WaitFix = 1;    % Time to fixate before NoStart

% Main trial timings
p.trial.task.stimLatency      = ND_GetITI(0.15, 0.25, [], [], 1, 0.10); %  SOA: Time from fixation onset to stim appearing
p.trial.task.saccadeTimeout   = 0.75;   % Time allowed to make the saccade to the stim before error
p.trial.task.minSaccReactTime = 0.025; % If saccade to target occurs before this, it was just a lucky precocious saccade, mark trial Early.
p.trial.task.minTargetFixTime = 0.1;   % Must fixate on target for at least this time before it counts
p.trial.task.Timing.WaitEnd   = 0.25;  % ad short delay after correct response before turning stimuli off
p.trial.task.Timing.TimeOut   =  1.5;  % Time-out[s]  for incorrect responses
p.trial.task.Timing.ITI       = ND_GetITI(1.5, 2.25, [], [], 1, 0.10);

% ----------------------------------- -------------------------------------%
%% Grating stimuli parameters
p.trial.stim.GRATING.tFreq  = 0;  % temporal frequency of grating; drift speed, 0 is stationary
p.trial.stim.GRATING.res    = 300;
p.trial.stim.GRATING.fixWin = 3.5;  
%p.trial.stim.GRATING.radius = datasample([0.5, 0.75, 1], 1);  % alternative radius of grating patch
p.trial.stim.GRATING.radius = 1.0;  % radius of grating patch

p.trial.stim.EccLst = [4, 5, 6]; % If p.defaultParameters.task.RandomEcc = 1, these are the  eccentriticies (see DetectGrat_init) 
p.trial.stim.AngLst = [0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180]; % If p.defaultParameters.task.RandomAng = 1, these are the angles (see DetectGrat_init)

% grating contrast
p.trial.stim.trgtconts = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
%p.trial.stim.trgtconts = [0, 0, 0.014, 0.023, 0.034, 0.081, 0.187, 0.285, 0.658, 0.9600]; %%changed on 20210223 
%p.trial.stim.trgtconts = [0, 0.015, 0.023, 0.035, 0.081, 0.187, 0.285, 0.658, 0.9600]; %%Anita suggested on 20210222 
%p.trial.stim.trgtconts = [0, 0, 0.01, 0.0152, 0.0217, 0.0248, 0.0504, 0.0951, 0.1727, 0.9500]; %%% used for behavior to make stationary data, 
%p.trial.stim.trgtconts = round(logspace(log10(0.035),log10(0.31), 10), 4)-0.01; %%croc
p.trial.stim.RespThr = 0.001; % contrast where it can be assumed the grating is seen

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.Block.maxBlocks = -1;  % if negative blocks continue until experimenter stops, otherwise task stops after completion of all blocks

% target contrast defines a condition
p.trial.Block.Conditions = {};
for(i=1:length(p.trial.stim.trgtconts))
    c.Nr = i;
    p.trial.Block.Conditions = [p.trial.Block.Conditions, c];
end

p.trial.Block.maxBlockTrials = 10;

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos    = [0,0];
p.trial.stim.FIXSPOT.type   = 'rect';          % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color  = 'white';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size   = 0.30;           % size of the fixation spot

% ------------------------------------------------------------------------%
%% Drug delivery parameters (added by Corey)

% Behaviorally integrated drug parameters -CR
p.trial.datapixx.TTL_ON = 0;
p.trial.datapixx.TTL_chan = 5;
p.trial.datapixx.TTL_PulseDur = .05; 
p.trial.datapixx.TTL_Npulse = 1;
p.trial.datapixx.TTL_GapDur = .10; 
p.trial.datapixx.TTL_Nseries = 1;
p.trial.datapixx.TTL_SeriesPause = 0;
p.trial.datapixx.TTL_InjStrobe = 667; 

%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.05;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.10;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Task parameters
p.trial.task.breakFixCheck = 0.2; % Time after a stimbreak where if task is marked early or stim break is calculated

%% Drug delivery parameters
% TTL pulse series for pico spritzer
p.trial.datapixx.TTL_spritzerChan      = 5;    % DIO channel
p.trial.datapixx.TTL_spritzerDur       = 0.01; % duration of TTL pulse
p.trial.datapixx.TTL_spritzerNpulse    = 2;    % number of pulses in a series
p.trial.datapixx.TTL_spritzerPulseGap  = .1; % gap between subsequent pulses

p.trial.datapixx.TTL_spritzerNseries   = 1;    % number of pulse series
p.trial.datapixx.TTL_spritzerSeriesGap = 1 ;  % gap between subsequent series

