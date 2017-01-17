function p = JoyColorDef(p)


% ------------------------------------------------------------------------%
%% Stimulus parameters
p.trial.display.bgColor      = [0, 0, 0] ./ 255;        % background color.
p.trial.(task).TrialStartCol = [121, 121, 121] ./ 255;  % change background color to indicate active trial

p.trial.(task).TargetOnCol   = [255, 255, 255] ./ 255;  % color of target after press
p.trial.(task).TargetDimmCol = [200, 200, 200] ./ 255;  % dimmed target color associated with release






