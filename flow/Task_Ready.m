function p = Task_Ready(p)
% default actions when the task starts

p.trial.EV.TaskStart     = p.trial.CurTime;

p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');

p.trial.Timer.Wait       = p.trial.EV.TaskStart + p.trial.task.Timing.WaitStart;

p.trial.CurrEpoch        = p.trial.epoch.WaitStart;

p.trial.outcome.CurrOutcome = p.trial.outcome.TaskStart;
