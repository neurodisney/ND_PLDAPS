% Function to initialize task parameters
function p = AttendGrat_init(p)

    % Building ascii tables in pldaps object
    p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'Good',        'p.trial.task.Good',                   '%d');
    p = ND_AddAsciiEntry(p, 'Target Pos X', ' p.trial.task.RFpos(1)',             '%d');
    p = ND_AddAsciiEntry(p, 'Target Pos Y', ' p.trial.task.RFpos(2)',             '%d');

    p = ND_AddAsciiEntry(p, 'TargetSel', 'p.trial.task.TargetSel', '%d');
    p = ND_AddAsciiEntry(p, 'Cued', 'p.trial.stim.GRATING.cued', '%d');

    % Ensuring output directory above exists
    ND_Trial2Ascii(p, 'init');