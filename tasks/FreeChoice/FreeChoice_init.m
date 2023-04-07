% John Amodeo, 2023


% Function to initialize task parameters
function p = FreeChoice_init(p)


    % Building ascii tables in pldaps object
    p = ND_AddAsciiEntry(p, 'Date',             'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',             'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Subject',          'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',       'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',             'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'block_number',     'p.trial.Block.blockCount',            '%d');
    p = ND_AddAsciiEntry(p, 'trials/block',     'p.trial.Block.maxBlockTrials',        '%d');
    
    p = ND_AddAsciiEntry(p, 'Cond',             'p.trial.task.condition',              '%d');
    p = ND_AddAsciiEntry(p, 'Result',           'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',          'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'Good',             'p.trial.task.Good',                   '%d');
    p = ND_AddAsciiEntry(p, 'stim1_rewDur',     'p.trial.stim.recParameters.stim1.rewardDur', '%d');
    p = ND_AddAsciiEntry(p, 'stim2_rewDur',     'p.trial.stim.recParameters.stim2.rewardDur', '%d');
    p = ND_AddAsciiEntry(p, 'stim1_prob',       'p.trial.stim.recParameters.probabilities(1)','%d');
    p = ND_AddAsciiEntry(p, 'stim2_prob',       'p.trial.stim.recParameters.probabilities(2)','%d');
    p = ND_AddAsciiEntry(p, 'prob_switch',      'p.trial.task.probSwitch',             '%d');
    p = ND_AddAsciiEntry(p, 'stim1_rewarded',   'p.trial.stim.stim1.reward',           '%d');
    p = ND_AddAsciiEntry(p, 'stim2_rewarded',   'p.trial.stim.stim2.reward',           '%d');
    p = ND_AddAsciiEntry(p, 'StimChoice',       'p.trial.task.TargetSel',              '%s');
     
    p = ND_AddAsciiEntry(p, 'stim1_color',      'p.trial.stim.recParameters.stim1.color',    '%s');
    p = ND_AddAsciiEntry(p, 'stim2_color',      'p.trial.stim.recParameters.stim2.color',    '%s');
    p = ND_AddAsciiEntry(p, 'color_switch',     'p.trial.task.colorSwitch',            '%d');
    
    % Ensuring output directory above exists
    ND_Trial2Ascii(p, 'init');
