function p = ND_UpdateTrial(p)
% pass on specific parameters to next trial 
%
% wolf zinke, March 2017

% --------------------------------------------------------------------%
%% update condition/block list
p.defaultParameters.Block = p.trial.Block;

% --------------------------------------------------------------------%
%% update trial statistics based on current outcome
if(p.trial.task.Good)
    p.defaultParameters.LastHits   = p.trial.LastHits   + 1; % how many correct trials since last error
    p.defaultParameters.NHits      = p.trial.NHits      + 1; % how many correct trials in total
    p.defaultParameters.NCompleted = p.trial.NCompleted + 1; % number of started trials (excluding not started trials)
else
    p.defaultParameters.NHits      = p.trial.NHits;
    p.defaultParameters.LastHits   = 0;     % how many correct trials since last error
end

if(p.trial.outcome.CurrOutcome ~= p.trial.outcome.NoStart && p.trial.outcome.CurrOutcome ~= p.trial.outcome.PrematStart)
    p.defaultParameters.NCompleted = p.trial.NCompleted + 1; % number of started trials (excluding not started trials)
else
    p.defaultParameters.NCompleted = p.trial.NCompleted;
end

% Store the current outcome in the Map of all outcomes
allOutcomes = p.defaultParameters.outcome.allOutcomes;
outcomeStr  = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

if(isKey(allOutcomes,outcomeStr))
    allOutcomes(outcomeStr) = allOutcomes(outcomeStr) + 1;
else
    allOutcomes(outcomeStr) = 1;
end

p.defaultParameters.outcome.allOutcomes = allOutcomes;

% Pass on the ITI timer
p.defaultParameters.EV.PlanStart = p.trial.EV.NextTrialStart;
% --------------------------------------------------------------------%
%%  Keep TDT use
% If TDT times out, disable it until manually reneabled
p.defaultParameters.tdt.use = p.trial.tdt.use;

% --------------------------------------------------------------------%
%%  keep joystick center position
if(p.trial.datapixx.useJoystick)
    p.defaultParameters.behavior.joystick.Zero = p.trial.behavior.joystick.Zero;
end

% --------------------------------------------------------------------%
%% keep offset correction for eye position
if(p.trial.datapixx.useAsEyepos)
    p.defaultParameters.eyeCalib.offset     = p.trial.eyeCalib.offset;
    p.defaultParameters.eyeCalib.gain       = p.trial.eyeCalib.gain;
end

% --------------------------------------------------------------------%
%% keep calibration information for eye position
if(p.trial.behavior.fixation.useCalibration)
    p.defaultParameters.behavior.fixation.GridPos        = p.trial.behavior.fixation.GridPos;
    p.defaultParameters.behavior.fixation.enableCalib    = p.trial.behavior.fixation.enableCalib;
    p.defaultParameters.behavior.fixation.calibTweakMode = p.trial.behavior.fixation.calibTweakMode;
    p.defaultParameters.eyeCalib                         = p.trial.eyeCalib;
end

% --------------------------------------------------------------------%
%% keep fixation spot window size
if(p.trial.behavior.fixation.use)
    p.defaultParameters.stim.FIXSPOT.fixWin = p.trial.stim.FIXSPOT.fixWin;
end

% --------------------------------------------------------------------%
%% Block control
p.defaultParameters.Block.EqualCorrect   = p.trial.Block.EqualCorrect;
p.defaultParameters.Block.GenBlock       = p.trial.Block.GenBlock;
p.defaultParameters.Block.BlockList      = p.trial.Block.BlockList;
% p.defaultParameters.Block.Conditions     = p.trial.Block.Conditions;
% p.defaultParameters.Block.maxBlockTrials = p.trial.Block.maxBlockTrials; 

% --------------------------------------------------------------------%
%% format string for ascii table
p.defaultParameters.asciitbl  =  p.trial.asciitbl;

% --------------------------------------------------------------------%
%% Keep keyboard freedom state
p.defaultParameters.pldaps.keyboardFree = p.trial.pldaps.keyboardFree;

% --------------------------------------------------------------------%
%% editable variables
if(isfield(p.trial, 'editable') && ~ isempty(p.trial.editable))
    for(i=1:length(p.trial.editable))
        eval(['p.defaultParameters.',p.trial.editable{i},' = p.trial.',p.trial.editable{i},';'])
    end
end


