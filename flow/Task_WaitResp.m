function p = Task_WaitResp(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

if(p.trial.CurTime > p.trial.Timer.Wait)
    p.trial.task.Good = 0;
    Response_Miss(p);  % Go directly to TaskEnd, do not continue task, do not collect reward
elseif(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
    Response_JoyRelease(p);
    p.trial.EV.RespRT = p.trial.EV.JoyRelease - p.trial.EV.GoCue;

    if(p.trial.EV.RespRT <  p.trial.task.Timing.minRT)
    % premature response - too early to be a true response
         Response_Early(p); % Go directly to TaskEnd, do not continue task, do not collect reward
         p.trial.task.Good = 0;
    else
    % correct response
        Task_Correct(p);
    end
end
