function p = Task_Response(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

p.trial.EV.JoyPress = p.trial.CurTime;

pds.tdt.strobe(p.trial.event.JOY_PRESS);

p.trial.EV.StartRT = p.trial.CurTime - p.trial.EV.TaskStart;
