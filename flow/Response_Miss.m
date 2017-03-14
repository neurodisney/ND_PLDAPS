function p = Response_Miss(p)
% default actions for early responses
%
%
% wolf zinke, March 2017

%ND_CtrlMsg(p, 'No Response');
p.trial.outcome.CurrOutcome = p.trial.outcome.Miss;

% Go directly to TaskEnd, do not continue task, do not collect reward
p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
