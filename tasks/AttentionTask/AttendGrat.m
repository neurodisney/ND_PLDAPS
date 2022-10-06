% Look for: tfh(p, p.trial.pldaps.trialStates.trialSetup);
% Look for: p = feval(p.trial.pldaps.trialMasterFunction,  p);
% TaskSetUp(p); and in TaskSetUp function: p.trial.stim.Trgt.Contrast = datasample(p.trial.stim.trgtconts,1)

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
    
    
    
    
end