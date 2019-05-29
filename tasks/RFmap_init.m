function p = RFmap_init(p)
% ####################################################################### %
%% Initial call of this function. Use this to define general settings of the experiment/session.
% Here, default parameters of the pldaps class could be adjusted if needed.
% This part corresponds to the experimental setup file and could be a separate
% file. In this case p.defaultParameters.pldaps.trialFunction needs to be
% defined here to refer to the file with the actual trial.
% At this stage, p.trial is not yet defined. All assignments need
% to go to p.defaultparameters
    
% --------------------------------------------------------------------%
%% define ascii output file
p = ND_AddAsciiEntry(p, 'Date',       'p.trial.DateStr',                     '%s');
p = ND_AddAsciiEntry(p, 'Time',       'p.trial.EV.TaskStartTime',            '%s');
p = ND_AddAsciiEntry(p, 'Subject',    'p.trial.session.subject',             '%s');
p = ND_AddAsciiEntry(p, 'Experiment', 'p.trial.session.experimentSetupFile', '%s');
p = ND_AddAsciiEntry(p, 'Tcnt',       'p.trial.pldaps.iTrial',               '%d');
p = ND_AddAsciiEntry(p, 'Cond',       'p.trial.Nr',                          '%d');
p = ND_AddAsciiEntry(p, 'Result',     'p.trial.outcome.CurrOutcome',         '%d');
p = ND_AddAsciiEntry(p, 'Outcome',    'p.trial.outcome.CurrOutcomeStr',      '%s');
p = ND_AddAsciiEntry(p, 'Good',       'p.trial.task.Good',                   '%d');

p = ND_AddAsciiEntry(p, 'Secs',       'p.trial.EV.DPX_TaskOn',               '%.5f');
p = ND_AddAsciiEntry(p, 'FixSpotOn',  'p.trial.EV.FixOn',                    '%.5f');
p = ND_AddAsciiEntry(p, 'FixSpotOff', 'p.trial.EV.FixOff',                   '%.5f');
p = ND_AddAsciiEntry(p, 'FixStart',   'p.trial.EV.FixSpotStart',             '%.5f');
p = ND_AddAsciiEntry(p, 'FixBreak',   'p.trial.EV.FixSpotStop',              '%.5f');
p = ND_AddAsciiEntry(p, 'FixPeriod',  'p.trial.task.FixPeriod',              '%.5f');
p = ND_AddAsciiEntry(p, 'TaskEnd',    'p.trial.EV.TaskEnd',                  '%.5f');
p = ND_AddAsciiEntry(p, 'ITI',        'p.trial.task.Timing.ITI',             '%.5f');

p = ND_AddAsciiEntry(p, 'FixWin',     'p.trial.behavior.fixation.FixWin',    '%.5f');
p = ND_AddAsciiEntry(p, 'InitRwd',    'p.trial.EV.FirstReward',              '%.5f');
p = ND_AddAsciiEntry(p, 'Reward',     'p.trial.EV.Reward',                   '%.5f');
p = ND_AddAsciiEntry(p, 'RewardDur',  'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)', '%.5f');
p = ND_AddAsciiEntry(p, 'TotalRwd',   'sum(p.trial.reward.timeReward(:,2))', '%.5f');

% call this after ND_InitSession to be sure that output directory exists!
ND_Trial2Ascii(p, 'init');

% --------------------------------------------------------------------%
%% Create stimulus log file
% initialize a simple ascii file that logs the information of the gratings shown for the RF mapping

p.trial.stimtbl.file = fullfile(p.defaultParameters.session.dir, ...
                               [p.defaultParameters.session.filestem,'_Stimuli.csv']);

StimLstPtr = fopen(p.trial.stimtbl.file, 'w');
fprintf(StimLstPtr, 'Trial,  GratingNr,  Onset,  TrialTime,  Xpos,  Ypos,  Radius,  Ori,  SpatFreq,  TempFreq,  Contrast\n');
fclose(StimLstPtr);

% --------------------------------------------------------------------%
%% Set fixed grating parameters
p.trial.stim.GRATING.res    = 300;
p.trial.stim.GRATING.fixWin = 0;

