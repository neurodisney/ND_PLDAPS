function p = att_PercEqui_taskdef(p)
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
p.trial.reward.ManDur         = 0.1;  % reward duration [s] for reward given by keyboard presses
p.trial.reward.IncrementTrial = [50, 150, 300,  400, 500,  600, 650]; % increase number of pulses with this trial number
p.trial.reward.IncrementDur   = [.75, .75, .75, .75, .75, .75, .75]; % increase number of pulses with this trial number
p.trial.reward.DiscourageProp = 1.0;  % proportion of reward given if previous trial was an error

%p.trial.reward.IncrementTrial = [150,  250,   350, 450,   550,  650, 750]; % increase number of pulses with this trial number
%p.trial.reward.IncrementDur   = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]; % increase number of pulses with this trial number

% ------------------------------------------------------------------------%
%% Timing
p.trial.behavior.fixation.MinFixStart = 0.1; % minimum time to wait for robust fixation

p.trial.task.Timing.WaitFix = 2;    % Time to fixate before NoStart

% Main trial timings
p.trial.task.stimLatency      = ND_GetITI(0.75, 1.5); % Time from fixation onset to stim appearing

p.trial.task.saccadeTimeout   = 0.75;   % Time allowed to make the saccade to the stim before error
p.trial.task.minSaccReactTime = 0.025; % If saccade to target occurs before this, it was just a lucky precocious saccade, mark trial Early.
p.trial.task.minTargetFixTime = .1;  % Must fixate on target for at least this time before it counts
p.trial.task.Timing.WaitEnd   = 0.25;  % ad short delay after correct response before turning stimuli off
p.trial.task.Timing.TimeOut   =  1;  % Time-out[s]  for incorrect responses
p.trial.task.Timing.ITI       = ND_GetITI(1.25,  1.75,  [], [], 1, 0.10);

% ----------------------------------- -------------------------------------%
%% Grating stimuli parameters
%p.trial.stim.GRATING.radius = 0.75;  % radius of grating patch
p.trial.stim.GRATING.tFreq  = 0;  % temporal frequency of grating; drift speed, 0 is stationary
p.trial.stim.GRATING.res    = 600;
p.trial.stim.GRATING.fixWin = 2;  %*p.trial.stim.GRATING.radius;

p.trial.stim.GRATING.radius = 1;  % radius of grating patch

% p.trial.stim.EccLst = [ 2, 3,   4];
% p.trial.stim.AngLst = [45, 0, -45];
% 
% p.trial.stim.EccLst =  3;
% p.trial.stim.AngLst = [45, 0, -45];

coordinate_array = zeros(6,2);
coordinate_array(:,1) = [1 , 2, 3, 3, 2, 1]; % x coordinates
coordinate_array(:,2) = [3, 2, 1, -1, -2, -3]; % y coordinates
n = randsample([1 2 3 4 5 6], 1);

p.trial.stim.PosX = coordinate_array(n,1);
p.trial.stim.PosY = coordinate_array(n,2);

% grating contrast

%cCtr = datasample([0.2, 0.3, 0.5, 0.75], 1);
cCtr =  0.3;
ScaleCtr = round(cCtr*100);

% ctrng = ND_HalfSpace(0, 5, 8);
ctrng = ND_HalfSpace(0, ScaleCtr, 5);

%ctrng = unique(cCtr * [0, fliplr(1 - ctrng(2:end)), 1 + ctrng]);
ctrng = unique(cat(2,(cCtr+ctrng./100),(cCtr-ctrng./100)));

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
p.trial.stim.FIXSPOT.color  = 'cyan';   % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size   = 0.125;    % size of the fixation spot

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.05;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.10;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Task parameters
p.trial.task.breakFixCheck = 0.2; % Time after a stimbreak where if task is marked early or stim break is calculated

