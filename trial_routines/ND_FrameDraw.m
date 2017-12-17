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
    Screen('DrawLines',p.trial.display.overlayptr,  p.trial.pldaps.draw.grid.tick_line_matrix, 1,  ...
                       p.trial.display.clut.grid, [0,0]);
end

% ------------------------------------------------------------------------%
%% draw current eye calibration
if(p.trial.behavior.fixation.enableCalib)
    pds.eyecalib.draw(p);
end
% ------------------------------------------------------------------------%
%% draw eye position
% show history of recent eye position
if(p.trial.pldaps.draw.eyepos.use)
% TODO: use alpha blending to fade out old locations
    Screen('Drawdots',  p.trial.display.overlayptr, [p.trial.eyeX_hist; p.trial.eyeY_hist], ...
                        p.trial.pldaps.draw.eyepos.sz/2, p.trial.display.clut.eyeold, [0 0], 0);

    Screen('Drawdots',  p.trial.display.overlayptr, p.trial.eyeXY_draw, ...
                        p.trial.pldaps.draw.eyepos.sz, p.trial.display.clut.eyepos, [0 0], 0);
end

% ------------------------------------------------------------------------%
%% Draw all the stimuli to the screen with their fixation windows
for(i=1:length(p.trial.stim.allStims))
    stim = p.trial.stim.allStims{i};
    draw(stim,p);
    
    if(p.defaultParameters.behavior.fixation.use)
        drawFixWin(stim,p);
    end
end

% ------------------------------------------------------------------------%
%% draw joystick state
% show a representation of the joystick elevation level
if(p.trial.pldaps.draw.joystick.use && p.trial.datapixx.useJoystick)
    % draw joystick area above threshold (i.e. pressed)
    Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.joythr , ...
                       p.trial.pldaps.draw.joystick.rect);
    % draw joystick area below threshold
    Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.joybox , ...
                       p.trial.pldaps.draw.joystick.threct);
    % draw current joystick level
    Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.joypos , ...
                       p.trial.pldaps.draw.joystick.levelrect);
end



% % ------------------------------------------------------------------------%
% %% draw mouse state
% TODO: Fix to match current mouse implementation
% if(p.trial.mouse.use && p.trial.pldaps.draw.cursor.use)
%     Screen('Drawdots',  p.trial.display.overlayptr,  p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples), ...
%                         p.trial.pldaps.draw.cursor.sz, p.trial.display.clut.cursor, [0 0],0);
% end


% ------------------------------------------------------------------------%
%% Write trial information to control screen
% TODO: Check why this is not working

% Screen('DrawText', p.trial.display.overlayptr, p.trial.SmryStr , 20, 1040, ...
%                    p.trial.display.clut.text, p.trial.display.clut.bg);
%


