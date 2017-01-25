function ND_TrialOn(p)
% show the cue that indicates the trial is active
%
% TODO: make more options available

% fwdth   = 50; % hard-coded for now, make it more flexible
% Screen('FrameRect', p.trial.display.overlayptr, p.trial.display.clut.TrialStart, [], fwdth);

fwdth   = 5; % hard-coded for now, make it more flexible
actrect = ND_GetRect(p.trial.display.ctr(1:2), [15 15]);
Screen('FrameRect', p.trial.display.overlayptr, p.trial.display.clut.TrialStart, p.trial.(task).FrameRect , p.trial.(task).FrameWdth);
