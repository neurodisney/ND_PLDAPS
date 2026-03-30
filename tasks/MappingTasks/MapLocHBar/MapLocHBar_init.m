% John Amodeo, October 2024

% Function to initialize task parameters
function p = MapLocHBar_init(p)

    % Building ascii tables in pldaps object
    p = ND_AddAsciiEntry(p, 'Date',           'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',           'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Subject',        'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',     'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',           'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'TrialID',        'p.trial.task.trialID',                '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',        'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'TargPosX',       'p.trial.stim.gabor.pos(1)',           '%d');
    p = ND_AddAsciiEntry(p, 'TargPosY',       'p.trial.stim.gabor.pos(2)',           '%d');
    p = ND_AddAsciiEntry(p, 'GaborSize',      'p.trial.stim.gabor.radius',           '%d');
    p = ND_AddAsciiEntry(p, 'GaborTf',        'p.trial.stim.gabor.speed',            '%d');
    p = ND_AddAsciiEntry(p, 'GaborSf',        'p.trial.stim.gabor.frequency',        '%d');
    p = ND_AddAsciiEntry(p, 'GaborCon',       'p.trial.stim.gabor.contrast',         '%d');
    p = ND_AddAsciiEntry(p, 'GaborOri',       'p.trial.stim.gabor.angle',            '%d');

    % Ensuring output directory above exists
    ND_Trial2Ascii(p, 'init');

