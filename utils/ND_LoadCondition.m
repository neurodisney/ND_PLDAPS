function p = ND_LoadCondition(p)
% Iterate through the condition struct for the current trial and change all
% corresponding parameters in defaultParameters

% Nate Faber, Oct 2017
iTrial = p.defaultParameters.pldaps.iTrial;
cond   = p.conditions{iTrial};

p.defaultParameters = ND_AlterSubStruct(p.defaultParameters, cond);


    