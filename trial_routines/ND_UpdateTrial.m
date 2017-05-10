function p = ND_UpdateTrial(p)
% pass on specific parameters to next trial 
%
% wolf zinke, March 2017



%% The old trial struct is still in memory
if p.trial.task.Good
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

% --------------------------------------------------------------------%
%%  keep joystick center position
if(p.trial.datapixx.useJoystick)
    p.defaultParameters.behavior.joystick.Zero = p.trial.behavior.joystick.Zero;
end

% --------------------------------------------------------------------%
%% keep offset correction for eye position
if(p.trial.datapixx.useAsEyepos)
    p.defaultParameters.eyeCalib.offset     = p.trial.eyeCalib.offset;
    p.defaultParameters.behavior.fixation.PrevOffset = p.trial.behavior.fixation.PrevOffset;
    p.defaultParameters.eyeCalib.gain       = p.trial.eyeCalib.gain;
end

% --------------------------------------------------------------------%
%% keep fixation requirements
if(p.trial.behavior.fixation.use)
    p.defaultParameters.behavior.fixation.required   = p.trial.behavior.fixation.required;
    p.defaultParameters.behavior.fixation.fixPos     = p.trial.behavior.fixation.fixPos;
    p.defaultParameters.behavior.fixation.FixWin     = p.trial.behavior.fixation.FixWin;
    p.defaultParameters.behavior.fixation.FixSz      = p.trial.behavior.fixation.FixSz;
    %p.defaultParameters.behavior.fixation.FixRect    = p.trial.behavior.fixation.FixRect;
    p.defaultParameters.behavior.fixation.FixWinRect = p.trial.behavior.fixation.FixWinRect;
end

% --------------------------------------------------------------------%
%% keep calibration information for eye position
if(p.trial.behavior.fixation.useCalibration)
    p.defaultParameters.behavior.fixation.GridPos     = p.trial.behavior.fixation.GridPos;
    p.defaultParameters.eyeCalib.rawEye                  = p.trial.eyeCalib.rawEye;
    p.defaultParameters.eyeCalib.fixPos                  = p.trial.eyeCalib.fixPos;
    p.defaultParameters.eyeCalib.medRawEye               = p.trial.eyeCalib.medRawEye;
    p.defaultParameters.eyeCalib.medFixPos              = p.trial.eyeCalib.medFixPos;
    p.defaultParameters.behavior.fixation.enableCalib = p.trial.behavior.fixation.enableCalib;
    p.defaultParameters.eyeCalib.name                   = p.trial.eyeCalib.name;
    p.defaultParameters.eyeCalib.file                   = p.trial.eyeCalib.file;
    
    p.defaultParameters.pldaps.draw.eyeCalib            = p.trial.pldaps.draw.eyeCalib;
end

% --------------------------------------------------------------------%
%% figure handle for online plots
if(p.trial.plot.do_online)
    p.defaultParameters.plot.fig = p.trial.plot.fig;
%     if(isfield(p.defaultParameters.plot, 'data'))
%         p.defaultParameters.plot.data = p.trial.plot.data;
%     end
end

% --------------------------------------------------------------------%
%% editable variables
if(isfield(p.trial, 'editable') && ~ isempty(p.trial.editable))
    for(i=1:length(p.trial.editable))
        eval(['p.defaultParameters.',p.trial.editable{i},' = p.trial.',p.trial.editable{i},';']);
    end
end


