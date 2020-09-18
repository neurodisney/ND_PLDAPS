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
p.trial.reward.ManDur         = 0.05;  % reward duration [s] for reward given by keyboard presses
p.trial.reward.IncrementTrial = [10,  150, 250,  300, 350, 400]; % increase number of pulses with this trial number
p.trial.reward.IncrementDur   = [0.05, 0.08, 0.1, 0.2, 0.25, 0.3]; % increase number of pulses with this trial number

p.trial.reward.GiveInitial  = 0; % If set to 1 reward animal when starting to fixate
p.trial.reward.InitialRew   = 0.05; % duration of the initial reward

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = ND_GetFixDur(.25, 1.5, [], [], 1, .25); % minimum time to wait for robust fixation

p.trial.task.Timing.WaitFix = 2;    % Time to fixate before NoStart

% Main trial timings
p.trial.task.stimLatency      = ND_GetITI(0.5, 1.5, [], [], 1, 0.10); %  SOA: Time from fixation onset to stim appearing
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
p.trial.stim.GRATING.fixWin = 2;  
%p.trial.stim.GRATING.radius = datasample([0.5, 0.75, 1], 1);  % alternative radius of grating patch
p.trial.stim.GRATING.radius = .75;  % radius of grating patch

p.trial.stim.EccLst = [ 2, 3,   3]; % If p.defaultParameters.task.RandomEcc = 1, these are the  eccentriticies (see DetectGrat_init) 
p.trial.stim.AngLst = [45, 0, -45]; % If p.defaultParameters.task.RandomAng = 1, these are the angles (see DetectGrat_init)

% grating contrast
p.trial.stim.trgtconts = round(logspace(log10(0.035),log10(0.31), 10), 4)-0.01;
p.trial.stim.RespThr = 0.040; % contrast where it can be assumed the grating is seen

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
p.trial.stim.FIXSPOT.type   = 'disc';          % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color  = 'FixDetection';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size   = 0.125;           % size of the fixation spot

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.05;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.10;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Task parameters
p.trial.task.breakFixCheck = 0.2; % Time after a stimbreak where if task is marked early or stim break is calculated

