% Function to initialize task parameters
function p = AttendGrat_init(p)

    % Building ascii tables in pldaps object
    p = ND_AddAsciiEntry(p, 'Date',         'p.trial.DateStr',                         '%s');
    p = ND_AddAsciiEntry(p, 'Time',         'p.trial.EV.TaskStartTime',                '%s');
    p = ND_AddAsciiEntry(p, 'Subject',      'p.trial.session.subject',                 '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',   'p.trial.session.experimentSetupFile',     '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',         'p.trial.pldaps.iTrial',                   '%d');
    p = ND_AddAsciiEntry(p, 'Cued',         'p.trial.task.cued',                       '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',      'p.trial.outcome.CurrOutcomeStr',          '%s');
    p = ND_AddAsciiEntry(p, 'Wait',         'p.trial.task.GratWait',                   '%d');
    p = ND_AddAsciiEntry(p, 'FlightTm',     'p.trial.task.FlightTime',                 '%d');
    p = ND_AddAsciiEntry(p, 'ResponseTm',   'p.trial.task.SRT_StimOn',                 '%d');

    p = ND_AddAsciiEntry(p, 'RFposX',       'p.trial.task.RFpos(1)',                    '%d');
    p = ND_AddAsciiEntry(p, 'RFposY',       'p.trial.task.RFpos(2)',                    '%d');

    p = ND_AddAsciiEntry(p, 'CueRingPosX',  'p.trial.stim.rings.cue.pos(1)',           '%d');
    p = ND_AddAsciiEntry(p, 'CueRingPosY',  'p.trial.stim.rings.cue.pos(2)',           '%d');
    p = ND_AddAsciiEntry(p, 'CueRingSize',  'p.trial.stim.rings.cue.radius',           '%d');
    p = ND_AddAsciiEntry(p, 'CueRingCon',   'p.trial.stim.rings.cue.contrast',         '%d');

    p = ND_AddAsciiEntry(p, 'DisRing1PosX',  'p.trial.stim.rings.distractor1.pos(1)',   '%d');
    p = ND_AddAsciiEntry(p, 'DisRing1PosY',  'p.trial.stim.rings.distractor1.pos(2)',   '%d');
    p = ND_AddAsciiEntry(p, 'DisRing1Size',  'p.trial.stim.rings.distractor1.radius',   '%d');
    p = ND_AddAsciiEntry(p, 'DisRing1Con',   'p.trial.stim.rings.distractor1.contrast', '%d');

    p = ND_AddAsciiEntry(p, 'DisRing2PosX',  'p.trial.stim.rings.distractor2.pos(1)',   '%d');
    p = ND_AddAsciiEntry(p, 'DisRing2PosY',  'p.trial.stim.rings.distractor2.pos(2)',   '%d');
    p = ND_AddAsciiEntry(p, 'DisRing2Size',  'p.trial.stim.rings.distractor2.radius',   '%d');
    p = ND_AddAsciiEntry(p, 'DisRing2Con',   'p.trial.stim.rings.distractor2.contrast', '%d');

    p = ND_AddAsciiEntry(p, 'DisRing3PosX',  'p.trial.stim.rings.distractor3.pos(1)',   '%d');
    p = ND_AddAsciiEntry(p, 'DisRing3PosY',  'p.trial.stim.rings.distractor3.pos(2)',   '%d');
    p = ND_AddAsciiEntry(p, 'DisRing3Size',  'p.trial.stim.rings.distractor3.radius',   '%d');
    p = ND_AddAsciiEntry(p, 'DisRing3Con',   'p.trial.stim.rings.distractor3.contrast', '%d');

    p = ND_AddAsciiEntry(p, 'TargPosX',     'p.trial.stim.gabors.preTarget.pos(1)',     '%d');
    p = ND_AddAsciiEntry(p, 'TargPosY',     'p.trial.stim.gabors.preTarget.pos(2)',     '%d');
    p = ND_AddAsciiEntry(p, 'TargSize',     'p.trial.stim.gabors.preTarget.radius',     '%d');
    p = ND_AddAsciiEntry(p, 'TargOri',      'p.trial.stim.gabors.preTarget.angle',      '%d');
    p = ND_AddAsciiEntry(p, 'TargTf',       'p.trial.stim.gabors.preTarget.speed',      '%d');
    p = ND_AddAsciiEntry(p, 'TargSf',       'p.trial.stim.gabors.preTarget.frequency',  '%d');
    p = ND_AddAsciiEntry(p, 'TargCon',      'p.trial.stim.gabors.preTarget.contrast',   '%d');
    p = ND_AddAsciiEntry(p, 'TargChange',   'p.trial.task.changeMag',                   '%d');
    p = ND_AddAsciiEntry(p, 'TargNewOri',   'p.trial.stim.gabors.postTarget.angle',     '%d');

    p = ND_AddAsciiEntry(p, 'Dis1PosX',    'p.trial.stim.gabors.distractor1.pos(1)',    '%d');
    p = ND_AddAsciiEntry(p, 'Dis1PosY',    'p.trial.stim.gabors.distractor1.pos(2)',    '%d');
    p = ND_AddAsciiEntry(p, 'Dis1Size',    'p.trial.stim.gabors.distractor1.radius',    '%d');
    p = ND_AddAsciiEntry(p, 'Dis1Ori',     'p.trial.stim.gabors.distractor1.angle',     '%d');
    p = ND_AddAsciiEntry(p, 'Dis1Tf',      'p.trial.stim.gabors.distractor1.speed',     '%d');
    p = ND_AddAsciiEntry(p, 'Dis1Sf',      'p.trial.stim.gabors.distractor1.frequency', '%d');
    p = ND_AddAsciiEntry(p, 'Dis1Con',     'p.trial.stim.gabors.distractor1.contrast',  '%d');

    p = ND_AddAsciiEntry(p, 'Dis2PosX',    'p.trial.stim.gabors.distractor2.pos(1)',    '%d');
    p = ND_AddAsciiEntry(p, 'Dis2PosY',    'p.trial.stim.gabors.distractor2.pos(2)',    '%d');
    p = ND_AddAsciiEntry(p, 'Dis2Size',    'p.trial.stim.gabors.distractor2.radius',    '%d');
    p = ND_AddAsciiEntry(p, 'Dis2Ori',     'p.trial.stim.gabors.distractor2.angle',     '%d');
    p = ND_AddAsciiEntry(p, 'Dis2Tf',      'p.trial.stim.gabors.distractor2.speed',     '%d');
    p = ND_AddAsciiEntry(p, 'Dis2Sf',      'p.trial.stim.gabors.distractor2.frequency', '%d');
    p = ND_AddAsciiEntry(p, 'Dis2Con',     'p.trial.stim.gabors.distractor2.contrast',  '%d');

    p = ND_AddAsciiEntry(p, 'Dis3PosX',    'p.trial.stim.gabors.distractor3.pos(1)',    '%d');
    p = ND_AddAsciiEntry(p, 'Dis3PosY',    'p.trial.stim.gabors.distractor3.pos(2)',    '%d');
    p = ND_AddAsciiEntry(p, 'Dis3Size',    'p.trial.stim.gabors.distractor3.radius',    '%d');
    p = ND_AddAsciiEntry(p, 'Dis3Ori',     'p.trial.stim.gabors.distractor3.angle',     '%d');
    p = ND_AddAsciiEntry(p, 'Dis3Tf',      'p.trial.stim.gabors.distractor3.speed',     '%d');
    p = ND_AddAsciiEntry(p, 'Dis3Sf',      'p.trial.stim.gabors.distractor3.frequency', '%d');
    p = ND_AddAsciiEntry(p, 'Dis3Con',     'p.trial.stim.gabors.distractor3.contrast',  '%d');

    p = ND_AddAsciiEntry(p, 'ChoicePosX',   'p.trial.task.StimSel(1)',                  '%d');
    p = ND_AddAsciiEntry(p, 'ChoicePosY',   'p.trial.task.StimSel(2)',                  '%d');

    p = ND_AddAsciiEntry(p, 'CuedMagList',  'p.trial.Block.cuedMagListStr',             '%s');
    p = ND_AddAsciiEntry(p, 'UncuedMagList','p.trial.Block.uncuedMagListStr',           '%s');

    % Ensuring output directory above exists
    ND_Trial2Ascii(p, 'init');