function p = Task_InitPress(p) % 8/7/25 - MJH - This was incorrectly typed as TaskResponse
% default actions when the task starts
%
%
% wolf zinke, March 2017

p.trial.EV.JoyPress = p.trial.CurTime;

pds.datapixx.strobe(p.trial.event.JOY_PRESS);

p.trial.EV.StartRT = p.trial.CurTime - p.trial.EV.TaskStart;
