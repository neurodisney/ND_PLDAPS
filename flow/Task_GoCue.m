function p = Task_GoCue(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

pds.tdt.strobe(p.trial.event.GOCUE);

p.trial.EV.GoCue              = p.trial.CurTime;

p.trial.task.Timing.WaitTimer = p.trial.CurTime + p.trial.task.Timing.WaitResp;

p.trial.CurrEpoch             = p.trial.epoch.WaitResponse;
