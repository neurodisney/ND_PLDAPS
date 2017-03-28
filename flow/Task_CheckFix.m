function p = Task_CheckFix(p)
% check current fixation state
%
%
% wolf zinke, March 2017

if(p.trial.behavior.fixation.required)

    if(p.trial.FixState.Current == p.trial.FixState.FixOut) % fixation break
        if(p.trial.behavior.fixation.GotFix == 1)
        % first time break detected
            p.trial.behavior.fixation.GotFix = 0;
            p.trial.Timer.FixBreak = p.trial.CurTime + p.trial.behavior.fixation.BreakTime;
            
        elseif(p.trial.CurTime > p.trial.Timer.FixBreak)
        % out too long, it's a break
            pds.tdt.strobe(p.trial.event.FIX_BREAK);
            p.trial.EV.FixBreak = p.trial.CurTime - p.trial.behavior.fixation.BreakTime;
            p.trial.task.Good   = 0;
            p.trial.FixState.Current = p.trial.FixState.FixBreak; 
        end
        
    elseif(p.trial.behavior.fixation.GotFix == 0 && p.trial.FixState.Current == p.trial.FixState.FixIn)
    % gaze returned in time to be not a fixation break
            p.trial.behavior.fixation.GotFix = 1;
    end
end
