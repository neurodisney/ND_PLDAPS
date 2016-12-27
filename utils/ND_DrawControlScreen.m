function ND_DrawControlScreen(p)
% right now taken from the pldapsDefaultTrialFunction, modify it according
% to our needs.
%
% TODO: Draw joystick state.


if p.trial.pldaps.draw.eyepos.use
    Screen('Drawdots',  p.trial.display.overlayptr, [p.trial.eyeX p.trial.eyeY]', ...
    p.trial.stimulus.eyeW, p.trial.display.clut.eyepos, [0 0],0);
end
if p.trial.mouse.use && p.trial.pldaps.draw.cursor.use
    Screen('Drawdots',  p.trial.display.overlayptr,  p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples), ...
    p.trial.stimulus.eyeW, p.trial.display.clut.cursor, [0 0],0);
end

if p.trial.pldaps.draw.photodiode.use && mod(p.trial.iFrame, p.trial.pldaps.draw.photodiode.everyXFrames) == 0
    photodiodecolor = [1 1 1];
    p.trial.timing.photodiodeTimes(:,p.trial.pldaps.draw.photodiode.dataEnd) = [p.trial.ttime p.trial.iFrame];
    p.trial.pldaps.draw.photodiode.dataEnd=p.trial.pldaps.draw.photodiode.dataEnd+1;
    Screen('FillRect',  p.trial.display.ptr,photodiodecolor, p.trial.pldaps.draw.photodiode.rect');
end
