function [sesstm, timestamp] = ND_CtrlMsg(p, msgstr)
% Write a formated message with time stamp to the matlab command window
%
%
% wolf zinke, Jan. 2017

timestamp = now;

sesstm = (GetSecs - p.trial.timing.datapixxSessionStart) / 60;

fprintf('%.13s \t-- trial %0.6d [%.5f] \n>>\t %s\n', ...
              datestr(now,'HH:MM:SS:FFF'), p.trial.pldaps.iTrial, sesstm, msgstr);


