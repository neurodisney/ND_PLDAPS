function p = CuedChangeDetect_init(p)
% --------------------------------------------------------------------%
%% define ascii output file
p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');
p = ND_AddAsciiEntry(p, 'Good',        'p.trial.task.Good',                   '%d');

p = ND_AddAsciiEntry(p, 'StimPosX',    'p.trial.stim.PosX',                   '%.3f');
p = ND_AddAsciiEntry(p, 'StimPosY',    'p.trial.stim.PosY',                   '%.3f');
p = ND_AddAsciiEntry(p, 'Hemi',        'p.trial.stim.Hemi',                   '%s');
p = ND_AddAsciiEntry(p, 'tFreq',       'p.trial.stim.GRATING.tFreq',          '%.2f');
p = ND_AddAsciiEntry(p, 'sFreq',       'p.trial.stim.GRATING.sFreq',          '%.2f');
p = ND_AddAsciiEntry(p, 'lContr',      'p.trial.stim.GRATING.lowContrast',    '%.1f');
p = ND_AddAsciiEntry(p, 'hContr',      'p.trial.stim.GRATING.highContrast',   '%.1f');
p = ND_AddAsciiEntry(p, 'StimSize',    '2*p.trial.stim.GRATING.radius',       '%.1f');

p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%.5f');
p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');
p = ND_AddAsciiEntry(p, 'StimOn',      'p.trial.EV.StimOn',                   '%.5f');
p = ND_AddAsciiEntry(p, 'StimOff',     'p.trial.EV.StimOff',                  '%.5f');
p = ND_AddAsciiEntry(p, 'StimChange',  'p.trial.EV.StimChange',               '%.5f');
p = ND_AddAsciiEntry(p, 'GoCue',       'p.trial.EV.GoCue',                    '%.5f');
p = ND_AddAsciiEntry(p, 'FixStart',    'p.trial.EV.FixSpotStart',             '%.5f');
p = ND_AddAsciiEntry(p, 'FixBreak',    'p.trial.EV.FixSpotStop',              '%.5f');
p = ND_AddAsciiEntry(p, 'StimFix',     'p.trial.EV.FixStimStart',             '%.5f');
p = ND_AddAsciiEntry(p, 'StimBreak',   'p.trial.EV.FixStimStop',              '%.5f');
p = ND_AddAsciiEntry(p, 'TaskEnd',     'p.trial.EV.TaskEnd',                  '%.5f');
p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');
p = ND_AddAsciiEntry(p, 'GoLatency',   'p.trial.task.ChangeTime',             '%.5f');
p = ND_AddAsciiEntry(p, 'StimLatency', 'p.trial.task.stimLatency',            '%.5f');
p = ND_AddAsciiEntry(p, 'SRT_FixStart','p.trial.task.SRT_FixStart',           '%.5f');
p = ND_AddAsciiEntry(p, 'SRT_StimOn',  'p.trial.task.SRT_StimOn',             '%.5f');
p = ND_AddAsciiEntry(p, 'SRT_Go',      'p.trial.task.SRT_Go',                 '%.5f');
p = ND_AddAsciiEntry(p, 'Response',    'p.trial.EV.Response',                 '%.5f');

p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.behavior.fixation.FixWin',    '%.5f');
p = ND_AddAsciiEntry(p, 'InitRwd',     'p.trial.EV.InitReward',               '%.5f');
p = ND_AddAsciiEntry(p, 'Reward',      'p.trial.EV.Reward',                   '%.5f');
p = ND_AddAsciiEntry(p, 'RewPulses',   'p.trial.reward.nPulse',               '%.5f');
p = ND_AddAsciiEntry(p, 'InitRwdDur',  'p.trial.reward.InitialRew * ~isnan(p.trial.EV.InitReward)', '%.5f');
p = ND_AddAsciiEntry(p, 'RewardDur',   'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)',            '%.5f');


% call this after ND_InitSession to be sure that output directory exists!
ND_Trial2Ascii(p, 'init');

%% initialize target parameters
p.defaultParameters.stim.FIXSPOT.fixWin = 2;

p.defaultParameters.task.RandomHemi = 1; % if 1, randomly pick left or right hemifield
p.defaultParameters.task.RandomPar  = 1; % if 1, randomly change orientation and spatial frequency of the grating each trial
p.defaultParameters.task.RandomEcc  = 1; % if 1, randomly change the grating eccentricity each trial
p.defaultParameters.task.RandomAng  = 1; % if 1, randomly change the grating angular position each trial

p.defaultParameters.task.EqualStim  = 1; % all gratings have the same spatial frequency and orientation
p.defaultParameters.task.ShowDist   = 1; % Display both, target and distractor grating

% define random grating parameters for each session
p.defaultParameters.stim.PosYlst    = -3:0.1:3;  % range of possible positions on Y axis
p.defaultParameters.stim.RandAngles = 0:15:359;  % if in random mode chose an angle from this list
p.defaultParameters.stim.RandAngles = 0:15:359;  % if in random mode chose an angle from this list
p.defaultParameters.stim.sFreqLst   = 1.5:0.2:5; % spatial frequency as cycles per degree
p.defaultParameters.stim.OriLst     = 0:15:179;  % orientation of grating

p.defaultParameters.stim.Hemi  = datasample(['l', 'r'], 1);
p.defaultParameters.stim.PosY  = datasample(p.defaultParameters.stim.PosYlst, 1);
p.defaultParameters.stim.GRATING.sFreq = datasample(p.defaultParameters.stim.sFreqLst,1); % spatial frequency as cycles per degree
p.defaultParameters.stim.GRATING.ori   = datasample(p.defaultParameters.stim.OriLst,  1); % orientation of grating


    