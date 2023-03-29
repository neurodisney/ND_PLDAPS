% Function to initialize task parameters
function p = AttendGrat_init(p)

    % Building ascii tables in pldaps object
    p = ND_AddAsciiEntry(p, 'Date',         'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',         'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Subject',      'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',   'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',         'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',         'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Result',       'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',      'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'Good',         'p.trial.task.Good',                   '%d');
    p = ND_AddAsciiEntry(p, 'TargPosX',  'p.trial.stim.gratings.preTarget.pos(1)', '%d');
    p = ND_AddAsciiEntry(p, 'TargPosY',  'p.trial.stim.gratings.preTarget.pos(2)', '%d');
    p = ND_AddAsciiEntry(p, 'Cued',         'p.trial.task.cued',                   '%d');
    p = ND_AddAsciiEntry(p, 'OriChangeMag', 'p.trial.Block.changeMag',             '%d');
    p = ND_AddAsciiEntry(p, 'FlightTime',   'p.trial.task.FlightTime',             '%d');
    p = ND_AddAsciiEntry(p, 'ResponseTime', 'p.trial.task.SRT_StimOn',             '%d');

    % Ensuring output directory above exists
    ND_Trial2Ascii(p, 'init');