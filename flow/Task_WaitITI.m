function p = Task_WaitITI(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

if(p.trial.CurTime > p.trial.Timer.ITI)
    p.trial.flagNextTrial = 1;
end

