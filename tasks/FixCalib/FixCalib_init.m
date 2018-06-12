function p = FixCalib_init(p, state)
% Initialize fixation calibration task.
%
%
%
% wolf zinke, Mar. 2018

% ####################################################################### %
%% Initial call of this function. Use this to define general settings of the experiment/session.
% Here, default parameters of the pldaps class could be adjusted if needed.
% This part corresponds to the experimental setup file and could be a separate
% file. In this case p.defaultParameters.pldaps.trialFunction needs to be 
% defined here to refer to the file with the actual t    %% define ascii output file
% call this after ND_InitSession to be sure that output directory exists!

p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%s');
p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');

p = ND_AddAsciiEntry(p, 'TrialStart',  'p.trial.EV.TrialStart',               '%.5f');
p = ND_AddAsciiEntry(p, 'TrialEnd',    'p.trial.EV.TrialEnd',                 '%.5f');


p = ND_AddAsciiEntry(p, 'Taskstart',   'p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart', '%.5f');
p = ND_AddAsciiEntry(p, 'TaskDur',     'p.trial.EV.TaskEnd   - p.trial.EV.TaskStart',                '%.5f');
p = ND_AddAsciiEntry(p, 'FixRT',       'p.trial.EV.FixStart  - p.trial.EV.FixOn',                    '%.5f');
p = ND_AddAsciiEntry(p, 'FirstReward', 'p.trial.task.CurRewDelay',            '%.5f');
p = ND_AddAsciiEntry(p, 'RewCnt',      'p.trial.reward.count',                '%d');

p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');

p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');

p = ND_AddAsciiEntry(p, 'FixPeriod',   'p.trial.task.FixPeriod', '%.5f');
p = ND_AddAsciiEntry(p, 'FixColor',    'p.trial.stim.FIXSPOT.color',          '%s');
p = ND_AddAsciiEntry(p, 'intITI',      'p.trial.task.Timing.ITI',             '%.5f');

p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.stim.fix.fixWin',             '%.5f');
p = ND_AddAsciiEntry(p, 'fixPos_X',    'p.trial.stim.fix.pos(1)',             '%.5f');
p = ND_AddAsciiEntry(p, 'fixPos_Y',    'p.trial.stim.fix.pos(2)',             '%.5f');

% call this after ND_InitSession to be sure that output directory exists!
ND_Trial2Ascii(p, 'init');

% basic fixation spot parameters
p.defaultParameters.behavior.fixation.FixGridStp = [4, 4]; % x,y coordinates in a 9pt grid
p.defaultParameters.behavior.fixation.FixWinStp  = 1;      % change of the size of the fixation window upon key press
p.defaultParameters.behavior.fixation.FixSPotStp = 0.25;
p.defaultParameters.stim.FIXSPOT.fixWin          = 4;      



% just initialize here, will be overwritten by conditions
p.defaultParameters.reward.MinWaitInitial  = 0.05;
p.defaultParameters.reward.MaxWaitInitial  = 0.1; 

%-------------------------------------------------------------------------%
%% eye calibration
if(~p.defaultParameters.behavior.fixation.useCalibration)    
    p = pds.eyecalib.setup(p);
end

p.defaultParameters.task.RandomPos = 0;
