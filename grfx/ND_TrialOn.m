function ND_TrialOn(p)
% show the cue that indicates the trial is active
%
% TODO: make more options available

fwdth = 50; % hard-coded for now, make it more flexible

% Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.TrialStart); % fill complete screen
Screen('FrameRect', p.trial.display.overlayptr, p.trial.display.clut.TrialStart, [], fwdth);
