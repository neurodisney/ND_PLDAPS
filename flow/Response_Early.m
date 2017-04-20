function p = Response_Early(p)
% default actions for early responses
%
%
% wolf zinke, March 2017

pds.tdt.strobe(p.trial.event.RESP_EARLY);

p.trial.outcome.CurrOutcome = p.trial.outcome.Early;

p.trial.task.Good = 0;

p.trial.EV.JoyRelease       = p.trial.CurTime;

% Go directly to TaskEnd, do not continue task, do not collect reward
p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
