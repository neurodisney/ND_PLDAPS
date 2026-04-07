% Function to initialize task parameters
function p = ViewScene_init(p)

    % Building ascii tables in pldaps object
    p = ND_AddAsciiEntry(p, 'Date',         'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',         'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Subject',      'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',   'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',         'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',      'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'Scene',        'p.trial.stim.sceneName',              '%s');
    p = ND_AddAsciiEntry(p, 'SceneDur',     'p.trial.stim.scene.duration',         '%s');
    p = ND_AddAsciiEntry(p, 'StimOn',       'p.trial.EV.StimOn',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOff',      'p.trial.EV.StimOff',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'sizeGain',     'p.trial.stim.IMAGE.sizeGain',         '%.3f');
    p = ND_AddAsciiEntry(p, 'ImageSizeX',   'p.trial.stim.scene.dispSize(1)',      '%.3f');
    p = ND_AddAsciiEntry(p, 'ImageSizeY',   'p.trial.stim.scene.dispSize(2)',      '%.3f');
    
    % Ensuring output directory above exists
    ND_Trial2Ascii(p, 'init');

