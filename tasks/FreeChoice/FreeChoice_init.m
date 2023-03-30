% John Amodeo, 2023


% Function to initialize task parameters
function p = FreeChoice_init(p)


    % Building ascii tables in pldaps object
    p = ND_AddAsciiEntry(p, 'Date',             'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',             'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Subject',          'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',       'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',             'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',             'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Result',           'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',          'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'Good',             'p.trial.task.Good',                   '%d');
    p = ND_AddAsciiEntry(p, 'stim1_rewDur',     'p.trial.stim.recParameters.stim1.rewardDur', '%d');
    p = ND_AddAsciiEntry(p, 'stim2_rewDur',     'p.trial.stim.recParameters.stim2.rewardDur', '%d');
    p = ND_AddAsciiEntry(p, 'stim1_rewarded',   'p.trial.stim.stim1.reward',           '%d');
    p = ND_AddAsciiEntry(p, 'stim2_rewarded',   'p.trial.stim.stim2.reward',           '%d');
    p = ND_AddAsciiEntry(p, 'StimChoice',       'p.trial.task.TargetSel',              '%s');


    % Ensuring output directory above exists
    ND_Trial2Ascii(p, 'init');
