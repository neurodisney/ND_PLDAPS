function p = Task_Fixating(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest) % early release
    Response_JoyRelease(p);
    Response_Early(p);  % Go directly to TaskEnd, do not continue task, do not collect reward
elseif(p.trial.FixState.Current == p.trial.FixState.FixOut) % fixation break
    if(p.trial.behavior.fixation.required)
        if(p.trial.behavior.fixation.GotFix == 1)
        % first time break detected
            p.trial.behavior.fixation.GotFix = 0;
            p.trial.Timer.FixBreak = p.trial.CurTime + p.trial.behavior.fixation.BreakTime;
        elseif(p.trial.FixState.Current == p.trial.FixState.FixIn)
        % gaze returned in time to be not a fixation break
            p.trial.behavior.fixation.GotFix = 1;

        elseif(p.trial.CurTime > p.trial.Timer.FixBreak)
        % out too long, it's a break
            pds.datapixx.strobe(p.trial.event.FIX_BREAK);
            p.trial.EV.FixBreak = p.trial.CurTime - p.trial.behavior.fixation.BreakTime;
            p.trial.task.Good   = 0;
            p.trial.CurrEpoch   = p.trial.epoch.TaskEnd; % Go directly to TaskEnd, do not continue task, do not collect reward
        end
    end
end