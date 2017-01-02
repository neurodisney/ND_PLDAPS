function [sesstm, timestamp] = ND_CtrlMsg(p, msgstr)
% Write a formated message with time stamp to the matlab command window
%
%
% wolf zinke, Jan. 2017

timestamp = now;

sesstm = GetSecs - p.trial.timing.datapixxSessionStart;

msg = sprintf('%.13s \t-- trial %0.6d [%.5] \n\t %s', ...
              datestr(now,'HH:MM:SS:FFF'), p.trial.pldaps.iTrial, sesstm, msgstr);

disp(msg);

