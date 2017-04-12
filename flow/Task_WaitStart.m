function p = Task_WaitStart(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

if(p.trial.CurTime > p.trial.Timer.Wait)
% no trial initiated in the given time window
    Task_NoStart(p);   % Go directly to TaskEnd, do not start task, do not collect reward
elseif(p.trial.JoyState.Current == p.trial.JoyState.JoyHold)
    Task_InitPress(p);

    if(p.trial.EV.StartRT <  p.trial.task.Timing.minRT)
    % too quick to be a true response
        Task_PrematStart(p);
    else
    % we just got a press in time
        Task_ON(p);
    end
end