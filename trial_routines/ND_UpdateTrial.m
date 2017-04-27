function p = ND_UpdateTrial(p)
% pass on specific parameters to next trial 
%
% wolf zinke, March 2017



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
    p.defaultParameters.behavior.fixation.Offset     = p.trial.behavior.fixation.Offset;
    p.defaultParameters.behavior.fixation.PrevOffset = p.trial.behavior.fixation.PrevOffset;
    p.defaultParameters.behavior.fixation.FixGain    = p.trial.behavior.fixation.FixGain;
end

%% keep fixation requirements
if(p.trial.behavior.fixation.use)
    p.defaultParameters.behavior.fixation.required   = p.trial.behavior.fixation.required;
    p.defaultParameters.behavior.fixation.FixPos     = p.trial.behavior.fixation.FixPos;
    p.defaultParameters.behavior.fixation.FixWin     = p.trial.behavior.fixation.FixWin;
    p.defaultParameters.behavior.fixation.FixSz      = p.trial.behavior.fixation.FixSz;
    p.defaultParameters.behavior.fixation.FixRect    = p.trial.behavior.fixation.FixRect;
    p.defaultParameters.behavior.fixation.FixWinRect = p.trial.behavior.fixation.FixWinRect;
end

%% keep calibration information for eye position
if(p.trial.behavior.fixation.useCalibration)
    p.defaultParameters.behavior.fixation.GridPos     = p.trial.behavior.fixation.GridPos;
    p.defaultParameters.Calib.EyePos_X                = p.trial.Calib.EyePos_X;
    p.defaultParameters.Calib.EyePos_Y                = p.trial.Calib.EyePos_Y;
    p.defaultParameters.Calib.EyePos_X_raw            = p.trial.Calib.EyePos_X_raw;
    p.defaultParameters.Calib.EyePos_Y_raw            = p.trial.Calib.EyePos_Y_raw;
    p.defaultParameters.Calib.rawEye                  = p.trial.Calib.rawEye;
    p.defaultParameters.Calib.fixPos                  = p.trial.Calib.fixPos;
    p.defaultParameters.Calib.medRawEye               = p.trial.Calib.medRawEye;
    p.defaultParameters.Calib.medFixPos              = p.trial.Calib.medFixPos;
    p.defaultParameters.behavior.fixation.enableCalib = p.trial.behavior.fixation.enableCalib;
end

%% editable variables
if(isfield(p.trial, 'editable') && ~ isempty(p.trial.editable))
    for(i=1:length(p.trial.editable))
        eval(['p.defaultParameters.',p.trial.editable{i},' = p.trial.',p.trial.editable{i},';']);
    end
end


