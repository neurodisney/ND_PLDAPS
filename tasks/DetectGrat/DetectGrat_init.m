function p = DetectGrat_init(p)
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

p = ND_AddAsciiEntry(p, 'RandomHemi',  'p.trial.task.RandomHemi',             '%d');
p = ND_AddAsciiEntry(p, 'RandomPar',   'p.trial.task.RandomPar',              '%d');
p = ND_AddAsciiEntry(p, 'RandomEcc',   'p.trial.task.RandomEcc',              '%d');
p = ND_AddAsciiEntry(p, 'RandomAng',   'p.trial.task.RandomAng',              '%d');

p = ND_AddAsciiEntry(p, 'Hemi',        'p.trial.stim.Hemi',                     '%s');
p = ND_AddAsciiEntry(p, 'TargetSpFreq','p.trial.stim.Trgt.sFreq',             '%.4f');
p = ND_AddAsciiEntry(p, 'TargetOri',   'p.trial.stim.Trgt.sFreq',             '%.4f');
p = ND_AddAsciiEntry(p, 'TargetContr', 'p.trial.stim.Trgt.Contrast',          '%.6f');
p = ND_AddAsciiEntry(p, 'PosX',        'p.trial.stim.GRATING.pos(1)',         '%.2f');
p = ND_AddAsciiEntry(p, 'PosY',        'p.trial.stim.GRATING.pos(2)',         '%.2f');
p = ND_AddAsciiEntry(p, 'Eccentricity','p.trial.stim.Ecc',                    '%.2f');
p = ND_AddAsciiEntry(p, 'Angle',       'p.trial.stim.Ang',                    '%.2f');

p = ND_AddAsciiEntry(p, 'StimSize',    '2*p.trial.stim.GRATING.radius',       '%.1f');

p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%.5f');
p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');
p = ND_AddAsciiEntry(p, 'StimOn',      'p.trial.EV.StimOn',                   '%.5f');
p = ND_AddAsciiEntry(p, 'StimOff',     'p.trial.EV.StimOff',                  '%.5f');
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

p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.stim.FIXSPOT.fixWin',    '%.5f');
p = ND_AddAsciiEntry(p, 'Reward',      'p.trial.EV.Reward',                   '%.5f');
%p = ND_AddAsciiEntry(p, 'RewardDur',   'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)', '%.5f');

% call this after ND_InitSession to be sure that output directory exists!
ND_Trial2Ascii(p, 'init');

%% initialize target parameters

p.defaultParameters.task.RandomHemi = 0; % if 1, randomly pick left or right hemifield
p.defaultParameters.task.RandomPar  = 1; % if 1, randomly change orientation and spatial frequency of the grating each trial
p.defaultParameters.task.RandomEcc  = 0; % if 1, randomly change the grating eccentricity each trial
p.defaultParameters.task.RandomAng  = 0; % if 1, randomly change the grating angular position each trial

% define random grating parameters for each session
%p.defaultParameters.stim.PosYlst    = -2.8;  % range of possible positions on Y axis 
%p.defaultParameters.stim.PosXlst    =  -3.4;  % range of possible positions on X axis 

% define grid locations used by key selection
%<<<<<<< HEAD
p.defaultParameters.stim.EccLst = [4, 4, 4, 4, 4, 4, 4, 4, 4]; % if p.defaultParameters.task.RandomEcc = 0; these are the eccentricities
p.defaultParameters.stim.AngLst = [0, 45, 90, 135, 180, 225, 275, 315, 360]; % if p.defaultParameters.task.RandomAng  = 0; these are the angles

[p.defaultParameters.stim.GridX, p.defaultParameters.stim.GridY] = ...
    pol2cart(p.defaultParameters.stim.AngLst, p.defaultParameters.stim.EccLst); % Corey Note: determines the target position based off EccLst and AngLst
%=======
p.defaultParameters.stim.EccLst = [2, 3, 4, 2, 3, 4, 2, 3, 4]; % if p.defaultParameters.task.RandomEcc = 0; these are the eccentricities
p.defaultParameters.stim.AngLst = [0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180]; % if p.defaultParameters.task.RandomAng  = 0; these are the angles

[p.defaultParameters.stim.GridX, p.defaultParameters.stim.GridY] = ...
    pol2cart(p.defaultParameters.stim.AngLst, p.defaultParameters.stim.EccLst); % determines the target position based off EccLst and AngLst
%>>>>>>> 0333d34f2df2261fa12f7105b68e50363d9d3c0f

% get a random location to start with
cPos = randi(length(p.defaultParameters.stim.GridX));
p.defaultParameters.stim.Ecc  = p.defaultParameters.stim.EccLst(cPos);
p.defaultParameters.stim.Ang  = p.defaultParameters.stim.AngLst(cPos);
%p.defaultParameters.stim.PosY = p.defaultParameters.stim.GridX(cPos); %use this line when you want random X positions
%p.defaultParameters.stim.PosX = p.defaultParameters.stim.GridY(cPos); %use this line when you want random Y positions 
%<<<<<<< HEAD
p.defaultParameters.stim.PosY = -1; % Corey Hack: to get hardcoded single position
p.defaultParameters.stim.PosX = -1; %Corey Hack: to get hardcoded single position
%=======
p.defaultParameters.stim.PosY = -3; %  to get hardcoded single position
p.defaultParameters.stim.PosX = -3; % to get hardcoded single position
%>>>>>>> 0333d34f2df2261fa12f7105b68e50363d9d3c0f


p.defaultParameters.stim.sFreqLst   = [2 3 4]; % spatial frequency as cycles per degree
%p.defaultParameters.stim.OriLst     = [0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180];  % orientation of grating
%p.defaultParameters.stim.OriLst     = [45, 45, 45, 45, 45, 45, 45, 45, 45];  % orientation of grating
%<<<<<<< HEAD
p.defaultParameters.stim.OriLst     = 45;  % orientation of grating


p.defaultParameters.stim.Hemi       = datasample(['l', '1'], 0);
%=======
p.defaultParameters.stim.OriLst     = [0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180];  % orientation of grating


p.defaultParameters.stim.Hemi       = datasample(['l', 'l'], 0);
%>>>>>>> 0333d34f2df2261fa12f7105b68e50363d9d3c0f
p.defaultParameters.stim.Trgt.sFreq = datasample(p.defaultParameters.stim.sFreqLst,1); % spatial frequency as cycles per degree
p.defaultParameters.stim.Trgt.ori   = datasample(p.defaultParameters.stim.OriLst,  1); % orientation of grating

p.defaultParameters.task.SRT          = NaN;
p.defaultParameters.task.SRT_FixStart = NaN;
p.defaultParameters.task.SRT_StimOn   = NaN;
p.defaultParameters.task.Response     = NaN;

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.
p.defaultParameters.pldaps.maxTrialLength = 15;


