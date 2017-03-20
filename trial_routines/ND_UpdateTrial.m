function p = ND_UpdateTrial(p)
% pass on specific parameters to next trial 
%
% wolf zinke, March 2017
%
% Todo: - Maybe create a trial update function for easier control
%       - define 'editables', either as 2D cell array (variable
%         name and value) or text file for task parameters that
%         have to be updated between trials.


%% The old trial struct is still in memory
if(p.trial.outcome.CurrOutcome == p.trial.outcome.Correct)
    p.defaultParameters.LastHits = p.defaultParameters.LastHits + 1; % how many correct trials since last error
    p.defaultParameters.NHits    = p.defaultParameters.NHits    + 1; % how many correct trials in total
else
    p.defaultParameters.LastHits = 0;     % how many correct trials since last error

    if(p.trial.outcome.CurrOutcome ~= p.trial.outcome.NoStart && ...
        p.trial.outcome.CurrOutcome ~= p.trial.outcome.PrematStart)
        p.defaultParameters.NCompleted = p.defaultParameters.NCompleted + 1; % number of started trials (excluding not started trials)
    end
end

p.defaultParameters.blocks = p.trial.blocks;

% Define a set of variables that should be editable, i.e. pass on information by default

%%  keep joystick center position
if(p.trial.datapixx.useJoystick)
    p.defaultParameters.behavior.joystick.Zero = p.trial.behavior.joystick.Zero;
end

%% keep offset correction for eye position
if(p.trial.datapixx.useAsEyepos)
    p.defaultParameters.behavior.fixation.Offset = p.trial.behavior.fixation.Offset;
end

%% keep fixation requirements
if(p.trial.behavior.fixation.use)
    p.defaultParameters.behavior.fixation.required = p.trial.behavior.fixation.required;
end


%% editable variables
if(isfield(p.trial, 'editable') && ~ isempty(p.trial.editable))
    for(i=1:length(p.trial.editable))
        eval(['p.defaultParameters.',p.trial.editable{i},' = p.trial.',p.trial.editable{i},';']);
    end
end


