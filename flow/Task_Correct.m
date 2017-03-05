function p = Task_Correct(p)
% default actions when a tasks ends correctly
%
%
% wolf zinke, March 2017

%ND_CtrlMsg(p, 'Correct Response');
pds.tdt.strobe(p.trial.event.RESP_CORR);
p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;

p.trial.task.Timing.WaitTimer = p.trial.CurTime + p.trial.reward.Lag;

p.trial.CurrEpoch = p.trial.epoch.WaitReward;
