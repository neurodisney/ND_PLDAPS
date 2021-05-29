function p = PercEqui_init(p)
% Initialisation for the PercEqui task
%
% Define the format of the ASCII table and all variables that will be kept constant
% throughout the experiment.
%
% wolf zinke, Nov. 2017

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

p = ND_AddAsciiEntry(p, 'Hemi',        'p.trial.stim.Hemi',                     '%s');
p = ND_AddAsciiEntry(p, 'RefSpFreq',   'p.trial.stim.Ref.sFreq',              '%.4f');
p = ND_AddAsciiEntry(p, 'RefOri',      'p.trial.stim.Ref.sFreq',              '%.4f');
p = ND_AddAsciiEntry(p, 'RefContr',    'p.trial.stim.Ref.Contrast',           '%.4f');
p = ND_AddAsciiEntry(p, 'TargetSpFreq','p.trial.stim.Trgt.sFreq',             '%.4f');
p = ND_AddAsciiEntry(p, 'TargetOri',   'p.trial.stim.Trgt.sFreq',             '%.4f');
p = ND_AddAsciiEntry(p, 'TargetContr', 'p.trial.stim.Trgt.Contrast',          '%.4f');
p = ND_AddAsciiEntry(p, 'RefX',        'p.trial.stim.Ref.Pos(1)',             '%.2f');
p = ND_AddAsciiEntry(p, 'RefY',        'p.trial.stim.Ref.Pos(2)',             '%.2f');
p = ND_AddAsciiEntry(p, 'TargetX',     'p.trial.stim.Trgt.Pos(1)',            '%.2f');
p = ND_AddAsciiEntry(p, 'TargetY',     'p.trial.stim.Trgt.Pos(2)',            '%.2f');

p = ND_AddAsciiEntry(p, 'StimSize',    '2*p.trial.stim.GRATING.radius',       '%.1f');

p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%.5f');
p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');
p = ND_AddAsciiEntry(p, 'StimOn',      'p.trial.EV.StimOn',                   '%.5f');
p = ND_AddAsciiEntry(p, 'StimOff',     'p.trial.EV.StimOff',                  '%.5f');
p = ND_AddAsciiEntry(p, 'FixStart',    'p.trial.EV.FixSpotStart',             '%.5f');
p = ND_AddAsciiEntry(p, 'FixBreak',    'p.trial.EV.FixSpotStop',              '%.5f');
p = ND_AddAsciiEntry(p, 'StimFix',     'p.trial.EV.FixStimStart',             '%.5f');
p = ND_AddAsciiEntry(p, 'StimBreak',   'p.trial.EV.FixStimStop',              '%.5f');
p = ND_AddAsciiEntry(p, 'TaskEnd',     'p.trial.EV.TaskEnd',                  '%.5f');
p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');
p = ND_AddAsciiEntry(p, 'StimLatency', 'p.trial.task.stimLatency',            '%.5f');
p = ND_AddAsciiEntry(p, 'SRT_FixStart','p.trial.task.SRT_FixStart',           '%.5f');
p = ND_AddAsciiEntry(p, 'SRT_StimOn',  'p.trial.task.SRT_StimOn',             '%.5f');
p = ND_AddAsciiEntry(p, 'EV_FixBreak', 'p.trial.stim.fix.EV.FixBreak',        '%.5f');
p = ND_AddAsciiEntry(p, 'EV_FixLeave', 'p.trial.EV.FixLeave',                 '%.5f');
p = ND_AddAsciiEntry(p, 'EV_FixStart', 'p.trial.stim.fix.EV.FixStart;',       '%.5f');

p = ND_AddAsciiEntry(p, 'TargetSel',   'p.trial.task.TargetSel',                '%d');

p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.stim.FIXSPOT.fixWin',         '%.5f');
p = ND_AddAsciiEntry(p, 'Reward',      'p.trial.EV.Reward',                   '%.5f');
p = ND_AddAsciiEntry(p, 'RewardDur',   'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)', '%.5f');

% call this after ND_InitSession to be sure that output directory exists!
ND_Trial2Ascii(p, 'init');


%% initialize target parameters
p.defaultParameters.stim.FIXSPOT.fixWin = 2;

p.defaultParameters.task.RandomHemi = 1; % if 1, randomly pick left or right hemifield
p.defaultParameters.task.RandomPar  = 1; % if 1, randomly change orientation and spatial frequency of the grating each trial

p.defaultParameters.task.EqualStim  = 1; % both gratings have the same spatial frequency and orientation

% define random grating parameters for each session
p.defaultParameters.stim.sFreqLst   = [2 3 4]; % spatial frequency as cycles per degree
p.defaultParameters.stim.OriLst     = 0:15:179;  % orientation of grating

p.defaultParameters.stim.Hemi       = datasample(['l', 'r'], 1);
p.defaultParameters.stim.Ref.sFreq  = datasample(p.defaultParameters.stim.sFreqLst,1); % spatial frequency as cycles per degree
p.defaultParameters.stim.Ref.ori    = datasample(p.defaultParameters.stim.OriLst,  1); % orientation of grating

p.defaultParameters.task.SRT          = NaN;
p.defaultParameters.task.SRT_FixStart = NaN;
p.defaultParameters.task.SRT_StimOn   = NaN;
p.defaultParameters.task.Response     = NaN;

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.
p.defaultParameters.pldaps.maxTrialLength = 15;

