function p = Task_WaitFix(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
% early bar release before fixation obtained
    Response_JoyRelease(p);
    Response_Early(p);  % Go directly to TaskEnd, do not continue task, do not collect reward
elseif(p.trial.FixState.Current == p.trial.FixState.FixIn)
% got fixation
    pds.datapixx.strobe(p.trial.event.FIXATION);
    p.trial.Timer.Wait  = p.trial.CurTime + p.trial.task.Timing.HoldTime;
    p.trial.EV.FixStart = p.trial.CurTime;
    p.trial.CurrEpoch   = p.trial.epoch.Fixating;
    p.trial.behavior.fixation.GotFix = 1;

elseif(p.trial.CurTime  > p.trial.Timer.Wait)
% trial offering ended
    if(p.trial.behavior.fixation.on)
        Task_NoStart(p);   % Go directly to TaskEnd, do not start task, do not collect reward
    end
end
