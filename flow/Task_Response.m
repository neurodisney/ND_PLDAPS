function p = Task_Response(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

p.trial.EV.RespRT = p.trial.EV.JoyRelease - p.trial.EV.GoCue;
