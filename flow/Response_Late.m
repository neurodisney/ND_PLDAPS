function p = Response_Late(p)
% default actions for early responses
%
%
% wolf zinke, March 2017

pds.tdt.strobe(p.trial.event.RESP_LATE);     

p.trial.CurrEpoch = p.trial.epoch.TaskEnd;


