function ND_FrameDraw(p)
% Prepare an update of the the displays. Draw basic elements to the screen,
% update information shown on the experimenter screen
%
% Taken from pldapsDefaultTrialFunction, modified according to our needs.
%
%
%
% wolf zinke, Jan. 2017

% ------------------------------------------------------------------------%
%% Set base background color
% datapixx needs a monochrome fill of the main display (p.trial.display.ptr)
% which is the base coat the overlayptr draws on. In datapixx mode this first
% color can only be gray scale which also makes it possible to change it at
% any time (colors, in contrast, need to be defined before initializing datapixx
% and can not be changed during the experiment at the moment.
if( any(p.trial.pldaps.lastBgColor ~= p.trial.display.bgColor) )
    Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor);
    Screen('FillRect', p.trial.display.overlayptr, p.trial.display.bgColor);
    p.trial.pldaps.lastBgColor = p.trial.display.bgColor;
end

% ------------------------------------------------------------------------%
%% grid lines
if(p.trial.pldaps.draw.grid.use)
    Screen('DrawLines',p.trial.display.overlayptr,  p.trial.pldaps.draw.grid.tick_line_matrix ,1, ...
                       p.trial.display.clut.window, p.trial.display.ctr(1:2));
end

% ------------------------------------------------------------------------%
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
                                   ones(1,5)*2*p.trial.display.ifi,  p.trial.display.clut.blackbg, '.');
                               
        % 0 ifi reference is 5 black dots
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), ...
                                   zeros(1,5), p.trial.display.clut.blackbg, '.');
                               
        % data are red dots
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf,  1:p.trial.pldaps.draw.framerate.nFrames, ...
                                   p.trial.pldaps.draw.framerate.data', p.trial.display.clut.redbg, '.');
    end
end

% ------------------------------------------------------------------------%
%% draw eye position
% show eye position
if(p.trial.pldaps.draw.eyepos.use)
% TODO: keep history of several frames, use alpha blending to fade out old locations
    Screen('Drawdots',  p.trial.display.overlayptr, [p.trial.eyeX, p.trial.eyeY]', ...
                        p.trial.stimulus.eyeW, p.trial.display.clut.eyepos, [0 0],0);
end

% ------------------------------------------------------------------------%
%% draw joystick state
% show a representation of the joystick elevation level
if(p.trial.pldaps.draw.joystick.use && p.trial.datapixx.useJoystick)
% TODO: keep history of several frames, use alpha blending to fade out old locations
    Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.joythr , ...
                       p.trial.pldaps.draw.joystick.rect);      % draw joystick area above threshold (i.e. pressed)
    Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.joybox , ...
                       p.trial.pldaps.draw.joystick.threct);    % draw joystick area below threshold
    Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.joypos , ...
                       p.trial.pldaps.draw.joystick.levelrect); % draw current joystick level
end

% % ------------------------------------------------------------------------%
% %% draw mouse state
% if(p.trial.mouse.use && p.trial.pldaps.draw.cursor.use)
%     Screen('Drawdots',  p.trial.display.overlayptr,  p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples), ...
%                         p.trial.stimulus.eyeW, p.trial.display.clut.cursor, [0 0],0);
% end

% ------------------------------------------------------------------------%
%% draw photodiode
% this is displayed as mono-chromatic (white) element on p.trial.display.ptr
if(p.trial.pldaps.draw.photodiode.use && ...
   mod(p.trial.iFrame, p.trial.pldaps.draw.photodiode.everyXFrames) == 0 )

    p.trial.timing.photodiodeTimes(:, p.trial.pldaps.draw.photodiode.dataEnd) = [p.trial.ttime, p.trial.iFrame];
    p.trial.pldaps.draw.photodiode.dataEnd = p.trial.pldaps.draw.photodiode.dataEnd + 1;
    
    Screen('FillRect',  p.trial.display.ptr, [1 1 1], p.trial.pldaps.draw.photodiode.rect');
end

