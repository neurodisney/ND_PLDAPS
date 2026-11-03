function [win, col] = ND_DrawTarget(p, colname)
% [win, col] = ND_DrawTarget (p, colname)
%
% Return the window and color to use for drawing an alement with the named
% color, so it reaches th4 right audience in every overlay mode.
%
% useOverlay 1/2 (CLUT overlays): everything goes to overlayptr; the two
% CLUTs decide what the monkey and the experimenter see.
% 
% useOverlay 3 (GPU mirror + experimenter-only overlay): colors the monkey
% should see (monkey color ~= background) are drawn on the subject window
% with the monkey color; the experimenter sees them via the mirror.
% Experimenter-only colors go on the overlay with the human color.

if p.trial.display.useOverlay == 3 && p.trial.display.mvis.(colname)
    win = p.trial.display.ptr;
    col = p.trial.display.mclut.(colname);
else
    win = p.trial.display.overlayptr;
    col = p.trial.display.clut.(colname);
end

%needed for color image and video projection for overlay