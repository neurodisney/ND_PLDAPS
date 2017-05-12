function p = Response_JoyRelease(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

p.trial.EV.JoyRelease = p.trial.CurTime;

pds.datapixx.strobe(p.trial.event.JOY_RELEASE);

