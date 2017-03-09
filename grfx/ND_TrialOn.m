function ND_TrialOn(p)
% show the cue that indicates the trial is active
%
% TODO: make more options available


Screen('FrameRect', p.trial.display.overlayptr, p.trial.display.clut.TrialStart, p.trial.(task).FrameRect , p.trial.(task).FrameWdth);
