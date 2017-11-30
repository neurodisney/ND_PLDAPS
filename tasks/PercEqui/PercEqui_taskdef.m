function p = PercEqui_taskdef(p)
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
p.trial.reward.IncrementTrial = [  50, 200,  300,  400,  500,  600, 700 ]; % increase number of pulses with this trial number
p.trial.reward.IncrementDur   = [0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4]; % increase number of pulses with this trial number

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = 0.1; % minimum time to wait for robust fixation

p.trial.task.Timing.WaitFix = 2;    % Time to fixate before NoStart

% Main trial timings
p.trial.task.stimLatency      = ND_GetITI(0.75, 1.5); % Time from fixation onset to stim appearing

p.trial.task.saccadeTimeout   = 0.5;   % Time allowed to make the saccade to the stim before error
p.trial.task.minSaccReactTime = 0.025; % If saccade to target occurs before this, it was just a lucky precocious saccade, mark trial Early.
p.trial.task.minTargetFixTime = 0.75;  % Must fixate on target for at least this time before it counts
p.trial.task.Timing.WaitEnd   = 0.25;  % ad short delay after correct response before turning stimuli off
p.trial.task.Timing.TimeOut   =  4;    % Time-out[s]  for incorrect responses
p.trial.task.Timing.ITI       = ND_GetITI(1.25,  1.75,  [], [], 1, 0.10);

% ----------------------------------- -------------------------------------%
%% Grating stimuli parameters
p.trial.stim.GRATING.fixWin = 2.5;
p.trial.stim.GRATING.radius = 0.75;  % radius of grating patch
p.trial.stim.GRATING.tFreq  = 0;  % temporal frequency of grating; drift speed, 0 is stationary
p.trial.stim.GRATING.res    = 300;

% grating contrast
p.trial.stim.Ref.Contrast = 0.5;

ctrng = ((logspace(0,1,9)-1)*0.04);
p.trial.stim.trgtconts = [fliplr(0.5 - ctrng(2:end)), 0.5 + ctrng(2:end)];

% p.trial.stim.trgtconts = [fliplr(0.5 - ctrng(4:end)), 0.5 + ctrng(4:end)];

% p.trial.stim.GRATING.TargetContrast = datasample(p.trial.stim.trgtconts, 1);

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.Block.maxBlocks    = -1;  % if negative blocks continue until experimenter stops, otherwise task stops after completion of all blocks

% target contrast defines a condition
p.trial.Block.Conditions = {};
for(i=1:length(p.trial.stim.trgtconts))
    c.Nr = i;
    p.trial.Block.Conditions = [p.trial.Block.Conditions, c];
end

p.trial.Block.maxBlockTrials =  10;

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos    = [0,0];
p.trial.stim.FIXSPOT.type   = 'disc';   % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color  = 'cyan';   % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size   = 0.125;    % size of the fixation spot

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.05;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.10;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Task parameters
p.trial.task.breakFixCheck = 0.2; % Time after a stimbreak where if task is marked early or stim break is calculated

