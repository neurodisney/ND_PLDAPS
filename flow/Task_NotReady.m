function p = Task_NotReady(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

% Go directly to TaskEnd, do not start task, do not collect reward
p.trial.CurrEpoch = p.trial.epoch.TaskEnd;

p.trial.task.Good = 0;
