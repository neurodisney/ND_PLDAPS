function p = Task_WaitRelease(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
    % use it as optional release reward if not full task is used
    if(p.trial.task.Reward.Pull && ~p.trial.task.FullTask)
        pds.reward.give(p, p.trial.task.Reward.PullRew);
    end

    Response_JoyRelease(p);
    Response_Late(p);
end
