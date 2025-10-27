% Function to initialize task parameters
function p = AttendGrat_init(p)

    % Building ascii tables in pldaps object
    p = ND_AddAsciiEntry(p, 'Date',              'p.trial.DateStr',                          '%s');
    p = ND_AddAsciiEntry(p, 'Time',              'p.trial.EV.TaskStartTime',                 '%s');
    p = ND_AddAsciiEntry(p, 'Subject',           'p.trial.session.subject',                  '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',        'p.trial.session.experimentSetupFile',      '%s');
    
    p = ND_AddAsciiEntry(p, 'Tcnt',              'p.trial.pldaps.iTrial',                    '%d');
    p = ND_AddAsciiEntry(p, 'Cued',              'p.trial.task.cued',                        '%d');
    p = ND_AddAsciiEntry(p, 'FlightTm',          'p.trial.task.FlightTime',                  '%d');
    p = ND_AddAsciiEntry(p, 'ResponseTm',        'p.trial.task.SRT_StimOn',                  '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',           'p.trial.outcome.CurrOutcomeStr',           '%s');
 
    p = ND_AddAsciiEntry(p, 'RfPosX',            'p.trial.task.RfPos(1)',                    '%d');
    p = ND_AddAsciiEntry(p, 'RfPosY',            'p.trial.task.RfPos(2)',                    '%d');
    p = ND_AddAsciiEntry(p, 'RfPrefOri',         'p.trial.task.RfOri',                       '%d');
    p = ND_AddAsciiEntry(p, 'RfSize',            'p.trial.task.RfSize',                      '%d');

    p = ND_AddAsciiEntry(p, 'FixSpotShape',      'p.trial.stim.FIXSPOT.type',                '%s');
    p = ND_AddAsciiEntry(p, 'FixSpotColor',      'p.trial.stim.FIXSPOT.color',               '%s');
    p = ND_AddAsciiEntry(p, 'FixSpotSize',       'p.trial.stim.FIXSPOT.size',                '%d');
    p = ND_AddAsciiEntry(p, 'FixSpotFixWin',     'p.trial.stim.FIXSPOT.fixWin',              '%d');
    p = ND_AddAsciiEntry(p, 'FixSpotWaitTm',     'p.trial.task.stimLatency',                 '%d');

    p = ND_AddAsciiEntry(p, 'RingSize',          'p.trial.task.ringSize',                    '%d');
    p = ND_AddAsciiEntry(p, 'RingWeight',        'p.trial.stim.RING.lineWeight(1)',          '%d');
    p = ND_AddAsciiEntry(p, 'CueRingDelta',      'p.trial.task.cueRingDelta',                '%d');
    p = ND_AddAsciiEntry(p, 'BaseRingDelta',     'p.trial.task.baseRingDelta',               '%d');
    p = ND_AddAsciiEntry(p, 'RingFlashTm',       'p.trial.task.ringFlash',                   '%d');
    p = ND_AddAsciiEntry(p, 'RingWaitTm',        'p.trial.task.CueWait',                     '%d');

    p = ND_AddAsciiEntry(p, 'GaborOffset',       'p.trial.task.stimOffset',                  '%d');
    p = ND_AddAsciiEntry(p, 'GaborTF',           'p.trial.stim.gabors.preTarget.speed',      '%d');
    p = ND_AddAsciiEntry(p, 'GaborSF',           'p.trial.stim.gabors.preTarget.frequency',  '%d');
    p = ND_AddAsciiEntry(p, 'GaborContrast',     'p.trial.stim.gabors.preTarget.contrast',   '%d');
    p = ND_AddAsciiEntry(p, 'GaborSize',         'p.trial.stim.gabors.preTarget.radius',     '%d');
    p = ND_AddAsciiEntry(p, 'GaborOri',          'p.trial.stim.gabors.preTarget.angle',      '%d');
    p = ND_AddAsciiEntry(p, 'GaborFixWinSize',   'p.trial.stim.DRIFTGABOR.fixWin',           '%d');
    p = ND_AddAsciiEntry(p, 'GaborWaitTm',       'p.trial.task.GratWait',                    '%d');
    p = ND_AddAsciiEntry(p, 'GaborConfig',       'p.trial.task.gaborConfig',                 '%d');

    p = ND_AddAsciiEntry(p, 'TargPosX',          'p.trial.stim.gabors.preTarget.pos(1)',     '%d');
    p = ND_AddAsciiEntry(p, 'TargPosY',          'p.trial.stim.gabors.preTarget.pos(2)',     '%d');
    p = ND_AddAsciiEntry(p, 'TargQuad',          'p.trial.task.targQuad',                    '%d');
    p = ND_AddAsciiEntry(p, 'TargChange',        'p.trial.task.changeMag',                   '%d');
    p = ND_AddAsciiEntry(p, 'TargNewOri',        'p.trial.stim.gabors.postTarget.angle',     '%d');

    p = ND_AddAsciiEntry(p, 'Dis1PosX',          'p.trial.stim.gabors.distractor1.pos(1)',   '%d');
    p = ND_AddAsciiEntry(p, 'Dis1PosY',          'p.trial.stim.gabors.distractor1.pos(2)',   '%d');

    p = ND_AddAsciiEntry(p, 'Dis2PosX',          'p.trial.stim.gabors.distractor2.pos(1)',   '%d');
    p = ND_AddAsciiEntry(p, 'Dis2PosY',          'p.trial.stim.gabors.distractor2.pos(2)',   '%d');

    p = ND_AddAsciiEntry(p, 'Dis3PosX',          'p.trial.stim.gabors.distractor3.pos(1)',   '%d');
    p = ND_AddAsciiEntry(p, 'Dis3PosY',          'p.trial.stim.gabors.distractor3.pos(2)',   '%d');

    p = ND_AddAsciiEntry(p, 'ResponseWin',       'p.trial.task.saccadeTimeout',              '%d');
    p = ND_AddAsciiEntry(p, 'RewardDur',         'p.trial.reward.Dur',                       '%d');
    
    p = ND_AddAsciiEntry(p, 'VPixx2ScreenDis',   'p.trial.task.VPixx2ScreenDis',             '%d');
    p = ND_AddAsciiEntry(p, 'Screen2MonkeyDis',  'p.trial.task.Screen2MonkeyDis',            '%d');
    p = ND_AddAsciiEntry(p, 'EyeCam2MonkeyDis',  'p.trial.task.EyeCam2MonkeyDis',            '%d');


    % Ensuring output directory above exists
    ND_Trial2Ascii(p, 'init');

    %p = ND_AddAsciiEntry(p, 'ChoicePosX',   'p.trial.task.StimSel(1)',                  '%d');
    %p = ND_AddAsciiEntry(p, 'ChoicePosY',   'p.trial.task.StimSel(2)',                  '%d');