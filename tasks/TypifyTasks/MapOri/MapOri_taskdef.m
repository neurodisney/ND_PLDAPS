% John Amodeo, July 2024
function p = MapOri_taskdef(p)

% Setting time window for fixation before trial marked as 'NoStart'
p.trial.task.Timing.WaitFix = 2;

% Storing expected latency of stim presentation to use for trial timing calculations
p.trial.task.stimLatency = ND_GetITI(0.75, 1.5);

% Setting time stimuli are left on screen after correct trial before task ends
p.trial.task.Timing.WaitEnd = 0.25;

% Selecting inter-trial interval (ITI)
p.trial.task.Timing.ITI = ND_GetITI(1.25, 1.75, [], [], 1, 0.10);

% Setting time-out(s) for incorrect response
p.trial.task.Timing.TimeOut = 1;   

% Creating duration for stimulus presentation
p.trial.task.presDur = 1;

% Reward parameters
p.trial.reward.Continuous = 1;
p.trial.reward.duration = 0.015;
p.trial.reward.Period = 0.5;
p.trial.reward.jackpotnPulse = 1;

% Fixation spot parameters
p.trial.stim.FIXSPOT.pos   = [0,0];
p.trial.stim.FIXSPOT.type  = 'rect';  % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color = 'dRed';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size  = 0.25;    % size of the fixation spot

% Gabor parameters
p.trial.task.oriRange = [0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 320, 340];
p.trial.task.pos = [8.5, -7];
p.trial.task.radius = 1;
