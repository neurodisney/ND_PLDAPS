% Function to run task for experiment
function p = AttendGrat(p, state)

% Checking for task name and filling if empty
if(~exist('state','var'))
    state = [];
end

% Initializing task
if(isempty(state))
    
    % Populating pldaps object with elements needed to begin task if empty
    p = AttendGrat_init(p);
    
else
    % If pldaps object is populated, standard trial routines run
    p = ND_GeneralTrialRoutines(p, state);
    
    % Executing events/epochs that make up trial
    switch state
        
        % Gathing materials to start trial
        case p.trial.pldaps.trialStates.trialSetup
            TaskSetUp(p);  
    end
end

% Function to gather materials to start trial
function TaskSetUp(p)

% Setting trial outcome to 'no start'
% This will be true if fixation is not achieved 
p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

% Trial has not proven to be successful(1), till then it is incorrect(0)
p.trial.task.Good = 0;
% Creating spot to store selection of target stimulus
p.trial.task.TargetSel = NaN;
% Fixation has not yet been achieved(1), till then is marked as absent(0)
p.trial.task.fixFix = 0;
% Tracking whether monkey is look at stim(1) or away from stim(0)
p.trial.task.stimFix = 0;
% Tracking whether stimuli are on(1) or off(0)
p.trial.task.stimState = 0;
% Creating place to save when fixation started
p.trial.task.SRT_FixStart = NaN;
% Creating place to save when stimuli came on screen
p.trial.task.SRT_StimOn = NaN;

% Generating fixation spot stimulus
p.trial.stim.fix = pds.stim.FixSpot(p);

% Selecting target position
p.trial.stim.targetPos = datasample(p.trial.task.posList, 1);

% Getting index of target position in position list
counter = 1;
p.trial.stim.distractPosList = {};
target = cell2mat(p.trial.stim.targetPos);
trgX = target(1);
trgY = target(2);
for i = 1:length(p.trial.task.posList)
    pos = cell2mat(p.trial.task.posList(i));
    posX = pos(1);
    posY = pos(2);
    disp(pos)
    if trgX ~= posX & trgY ~= posY
        %distractor_positions = cat(2, distractor_positions, [posX, posY]);
        disp(pos)
    end
end

% Using index of target position to make list of distractor positions



%distractor_positions = p.trial.task.posList{p.trial.stim.targetPos};





% Gathing random orientations for gratings
p.trial.stim.gratingParameters.oriList = datasample(p.trial.task.gratingOriList, 5);
