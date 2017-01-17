function ND_DrawControlScreen(p, task)
% Prepare an update of the control screen
%
% right now taken from the pldapsDefaultTrialFunction, modify it according
% to our needs.
%
% TODO: Draw joystick state.
%
%
% wolf zinke, Jan. 2017

% --------------------------------------------------------------------%
% %% 
% % did the background color change? Usually already applied after
% % frameFlip, but make sure we're not missing anything
% if( any(p.trial.pldaps.lastBgColor~=p.trial.display.bgColor) )
%     Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor);
%     p.trial.pldaps.lastBgColor = p.trial.display.bgColor;
% end

% --------------------------------------------------------------------%
%% 
if(p.trial.pldaps.draw.grid.use)
    Screen('DrawLines',p.trial.display.overlayptr, p.trial.pldaps.draw.grid.tick_line_matrix ,1, ...
                       p.trial.display.clut.window, p.trial.display.ctr(1:2));
end

% --------------------------------------------------------------------%
%% draw a history of fast inter frame intervals
if(p.trial.pldaps.draw.framerate.use && p.trial.iFrame > 2)
    % update data
    p.trial.pldaps.draw.framerate.data      = circshift(p.trial.pldaps.draw.framerate.data,-1);
    p.trial.pldaps.draw.framerate.data(end) = p.trial.timing.flipTimes(1, p.trial.iFrame - 1) - ...
                                              p.trial.timing.flipTimes(1, p.trial.iFrame - 2);
    % plot
    if(p.trial.pldaps.draw.framerate.show) 
        % adjust y limit
        p.trial.pldaps.draw.framerate.sf.ylims = [0 max(max(p.trial.pldaps.draw.framerate.data), 2*p.trial.display.ifi)];
        
        % current ifi is solid black
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims, ...
                                  [p.trial.display.ifi, p.trial.display.ifi], p.trial.display.clut.blackbg, '-');
                              
        % 2 ifi reference is 5 black dots
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), ...
                                   ones(1,5)*2*p.trial.display.ifi, p.trial.display.clut.blackbg, '.');
                               
        % 0 ifi reference is 5 black dots
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), ...
                                   zeros(1,5), p.trial.display.clut.blackbg, '.');
                               
        % data are red dots
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, 1:p.trial.pldaps.draw.framerate.nFrames, ...
                                   p.trial.pldaps.draw.framerate.data', p.trial.display.clut.redbg, '.');
    end
end

% --------------------------------------------------------------------%
%% draw eye position
if(p.trial.pldaps.draw.eyepos.use)
    Screen('Drawdots',  p.trial.display.overlayptr, [p.trial.eyeX, p.trial.eyeY]', ...
                        p.trial.(task).eyeW, p.trial.display.clut.eyepos, [0 0],0);
end

% --------------------------------------------------------------------%
%% draw joystick state
% WZ: This is clearly a ToDo!
if(p.trial.pldaps.draw.joystick.use && p.trial.datapixx.useJoystick
% Todo: define location and size of joystick representation
% Todo: draw threshold circles depending on current state

    Screen('Drawdots',  p.trial.display.overlayptr, [p.trial.eyeX, p.trial.eyeY]', ...
                        p.trial.(task).eyeW, p.trial.display.clut.eyepos, [0 0],0);  % ToDo add joystick colors

end

% --------------------------------------------------------------------%
%% draw mouse state
if(p.trial.mouse.use && p.trial.pldaps.draw.cursor.use)
    Screen('Drawdots',  p.trial.display.overlayptr,  p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples), ...
                        p.trial.(task).eyeW, p.trial.display.clut.cursor, [0 0],0);
end

% --------------------------------------------------------------------%
%% draw photodiode
if(p.trial.pldaps.draw.photodiode.use && ...
   mod(p.trial.iFrame, p.trial.pldaps.draw.photodiode.everyXFrames) == 0 )

    photodiodecolor = [1 1 1];
    p.trial.timing.photodiodeTimes(:, p.trial.pldaps.draw.photodiode.dataEnd) = [p.trial.ttime, p.trial.iFrame];
    p.trial.pldaps.draw.photodiode.dataEnd = p.trial.pldaps.draw.photodiode.dataEnd + 1;
    
    Screen('FillRect',  p.trial.display.ptr,photodiodecolor, p.trial.pldaps.draw.photodiode.rect');
end

