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
p.trial.reward.ManDur         = 0.22;  % reward duration [s] for reward given by keyboard presses
p.trial.reward.IncrementTrial = [50, 150, 300,  400, 500,  600, 650]; % increase number of pulses with this trial number
p.trial.reward.IncrementDur   = [0.35, 0.35, 0.35, 0.35, 0.35, 0.35, 0.35]; % increase number of pulses with this trial number
p.trial.reward.DiscourageProp = 1.0;  % proportion of reward given if previous trial was an error
p.trial.reward.Dur            = 0.22; %initial reward duration
p.trial.reward.boost          = 0.0;
p.trial.stim.tardiffthresh    = 0.01; %if target and reference within 3% contrast of each other, use random reward probability
p.trial.reward.useProb        = 0;
p.trial.reward.probabilities  = [0.25, 0.75]; %probability for will NOT or WILL be rewarded

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = 0.2; % minimum time to wait for robust fixation

p.trial.task.Timing.WaitFix = 1.5;    % Time to fixate before NoStart

% Main trial timings
p.trial.task.stimLatency      = ND_GetITI(0.25,  1.5,  [], [], 1, 0.20); % Time from fixation onset to stim appearing

p.trial.task.saccadeTimeout   = 1.5;   % Time allowed to make the saccade to the stim before error
p.trial.task.minSaccReactTime = 0.05; % If saccade to target occurs before this, it was just a lucky precocious saccade, mark trial Early.
p.trial.task.minTargetFixTime = .1;  % Must fixate on target for at least this time before it counts
p.trial.task.Timing.WaitEnd   = 0.25;  % ad short delay after correct response before turning stimuli off
p.trial.task.Timing.TimeOut   =  1.5;  % Time-out[s]  for incorrect responses
p.trial.task.Timing.ITI       = ND_GetITI(0.5,  1.0,  [], [], 1, 0.10);
p.trial.task.Timing.TimeOut   = 3.5; %additional time added to ITI if trial response was incorrect

% ----------------------------------- -------------------------------------%
%% Grating stimuli parameters
p.trial.stim.GRATING.tFreq  = 0;  % temporal frequency of grating; drift speed, 0 is stationary
p.trial.stim.GRATING.res    = 600;
p.trial.stim.GRATING.fixWin = 2.8;  %*p.trial.stim.GRATING.radius;

p.trial.stim.GRATING.radius = 0.75;  % radius of grating patch

% p.trial.stim.EccLst = [ 2, 3,   4];
%p.trial.stim.AngLst = [45, 0, -45];
% 
p.trial.stim.EccLst =  [2];
p.trial.stim.AngLst = [0];
% 

p.trial.stim.PosX = 2.0;
%p.trial.stim.PosY = datasample([-1.5, 1.5], 1);
%p.trial.stim.PosX = datasample([-1.5, 1.5], 1);
p.trial.stim.PosY = 0.0;

% grating contrast
cCtr = datasample([0.2, 0.4], 1);
%cCtr =  0.25;
ScaleCtr = round(cCtr*100);
%Ctrdiff = 100-ScaleCtr;

% ctrng = ND_HalfSpace(0, 5, 8);
ctrng = ND_HalfSpace(0, ScaleCtr, 4);

ctrng = unique(cat(2,(cCtr+ctrng./100),(cCtr-ctrng./100)));
%ctrng = abs(ctrng);

%ctrng = [0.0 0.15 0.65 0.75 1.0];

% ctrngP = ctrng * 0.5;
% plot(ctrngP, (1:length(ctrngP))./length(ctrngP), '.-')
% hold on
% xlim([0,]);
% ctrngP = ctrng * 0.2;
% plot(ctrngP, (1:length(ctrngP))./length(ctrngP), '.-')
% ctrngP = ctrng * 0.75;
% plot(ctrngP, (1:length(ctrngP))./length(ctrngP), '.-')
% ctrngP = ctrng * 0.1;
% plot(ctrngP, (1:length(ctrngP))./length(ctrngP), '.-')
% ctrngP = ctrng * 0.3;
% plot(ctrngP, (1:length(ctrngP))./length(ctrngP), '.-')

ctrng(ctrng<0 | ctrng>1)  = [];
p.trial.stim.Ref.Contrast = cCtr;
p.trial.stim.trgtconts    = ctrng;

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos    = [0,0];
p.trial.stim.FIXSPOT.type   = 'disc';   % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color  = 'dGreen';   % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size   = 0.15;    % size of the fixation spot

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.05;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.10;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Task parameters
p.trial.task.breakFixCheck = 0.2; % Time after a stimbreak where if task is marked early or stim break is calculated

