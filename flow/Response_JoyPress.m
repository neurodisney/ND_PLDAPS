function p = Response_JoyPress(p)
% default actions when the joystick is pressed
%
%
% wolf zinke, March 2017

p.trial.EV.JoyPress = p.trial.CurTime - p.trial.EV.TaskStart;
pds.tdt.strobe(p.trial.event.JOY_PRESS);
