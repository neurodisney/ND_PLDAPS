function ND_TrialOn(p)
% show the cue that indicates the trial is active
%
% TODO: make more options available


[win,col] = ND_DrawTarget(p, 'TrialStart');
Screen('FrameRect', win, col, p.trial.(task).FrameRect, p.trial.(task).FramwWidth);
