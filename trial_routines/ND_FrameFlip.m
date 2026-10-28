function ND_FrameFlip(p)
% Flip the graphic buffer and show next frame
%
% in part taken from frameFlip in the PLDAPS pldapsDefaultTrialFunction
%
%
% wolf zinke, Jan. 2017

%-------------------------------------------------------------------------%
%% check if photo diode signal needs to be shown or remains on
PDoff = 0;

if(p.trial.pldaps.draw.photodiode.use)    
    if(p.trial.pldaps.draw.photodiode.state == 1)
        if(GetSecs < p.trial.Timer.PhD)
            Screen('FillRect',  p.trial.display.ptr, [1 1 1], p.trial.pldaps.draw.photodiode.rect);
        else
            PDoff = 1;
        end
    elseif(p.trial.pldaps.draw.ScreenEvent > 0)
        Screen('FillRect',  p.trial.display.ptr, [1 1 1], p.trial.pldaps.draw.photodiode.rect);
    end
end

if (p.trial.display.useOverlay == 3)
    Screen('CopyWindow', p.trial.display.ptr, p.trial.display.mirrortex);
    %ND_MirrorDebug(p, 'copy');
end
%-------------------------------------------------------------------------%
%% Flip the screen and keep track of frame timings
if(p.trial.pldaps.GetScreenFlipTimes) % debug mode, keep all times
    ft = cell(5,1);
    
    [ft{:}] = Screen('Flip', p.trial.display.ptr, 0);
    p.trial.timing.flipTimes(:,p.trial.iFrame) = [ft{:}];
    
    ft = ft{1};
    
elseif(~isempty(p.trial.pldaps.draw.ScreenEvent)) % screen event intended
    ft = Screen('Flip', p.trial.display.ptr, 0);
    
else % do not wait for next screen refresh
    Screen('Flip', p.trial.display.ptr, 0, 0, 1);  
end

if(~isempty(p.trial.pldaps.draw.ScreenEvent)) % there is an intended change of the animal display

    for(i=1:length(p.trial.pldaps.draw.ScreenEvent))
        pds.datapixx.strobe(p.trial.pldaps.draw.ScreenEvent(i));
        
        if(~isempty(p.trial.pldaps.draw.ScreenEventName{i}))
            p.trial.EV.(p.trial.pldaps.draw.ScreenEventName{i}) = ft;
        end
    end
    
    % reset
    p.trial.pldaps.draw.ScreenEvent     = [];       
    p.trial.pldaps.draw.ScreenEventName = {};  
end

if(p.trial.pldaps.draw.photodiode.use) 
% update photo diode state    
    if(p.trial.pldaps.draw.photodiode.state == 0)
        pds.datapixx.strobe(p.trial.event.PD_ON);    

        p.trial.Timer.PhD = ft + (p.trial.pldaps.draw.photodiode.XFrames * p.trial.display.ifi) - p.trial.display.ifi/2; % subtract half a frame rate to make sure to catch the correct one

        p.trial.pldaps.draw.photodiode.cnt = p.trial.pldaps.draw.photodiode.cnt + 1;
        p.trial.timing.photodiodeTimes(1, p.trial.pldaps.draw.photodiode.cnt) = ft;

        p.trial.pldaps.draw.photodiode.state = 1;
    end

    % turn photo diode signal off
    if(p.trial.pldaps.draw.photodiode.use && PDoff == 1) 
        pds.datapixx.strobe(p.trial.event.PD_OFF);    

        p.trial.timing.photodiodeTimes(2, p.trial.pldaps.draw.photodiode.cnt) = ft;

        p.trial.pldaps.draw.photodiode.state = 0;
    end
end

%-------------------------------------------------------------------------%
%% Draw background
% WZ: Is this needed to make sure that each screen is initiated with the same background color?
% TODO: WZ - check what this is actually doing and if this is needed here.

% did the background color change?
% we're doing it here to make sure we don't overwrite anything but this typically causes a one frame delay
% until it's applied, i.e. when it's set in frame n, it changes when frame n+1  flips otherwise
% we could trust users not to draw before frameDraw, but we'll check again at frameDraw to be sure

if(any(p.trial.pldaps.lastBgColor ~= p.trial.display.bgColor))
    Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor, p.trial.display.winRect);
    p.trial.pldaps.lastBgColor = p.trial.display.bgColor;
end

if (p.trial.display.useOverlay == 3 && mod(p.trial.iFrame, p.trial.display.expEveryNFrames) == 0);
    %compose the experimenter view (mirror image, overlay on top) in the
    %subject window's context, then copy it over to the experimenter window
    sm = p.trial.display.expSmall;
    Screen('glPushMatrix', sm);
    Screen('glLoadIdentity', sm); % ignore the defree-unit transform for this copy
    Screen('FillRect', sm, [0 0 0 1]);
    Screen('BlendFunction', sm, 'GL_ONE', 'GL_ZERO');
    Screen('DrawTexture', sm, p.trial.display.mirrortex, [], p.trial.display.expRect);
    %ND_MirrorDebug(p, 'compose', sm);
    Screen('BlendFunction', sm, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    Screen('DrawTexture', sm, p.trial.display.overlayptr, [], p.trial.display.expRect);
    Screen('glPopMatrix', sm);
    
    img = Screen('GetImage', sm);
    tex = Screen('MakeTexture', p.trial.display.expptr, img);
    Screen('DrawTexture', p.trial.display.expptr, tex);
    Screen('Close', tex);
    
    %dontsync = 2; no waiting for vsync, so the subject display is not
    %slowed
    Screen('Flip', p.trial.display.expptr, 0, 0, 2);
end

if(p.trial.display.overlayptr ~= p.trial.display.ptr)
    if(p.trial.display.useOverlay==3)
        % Reset the overlay to fully transparent. On offscreen windows FillRect
        % draws a blended rectangle, so blending must be off or alpha stays put.
        ov = p.trial.display.overlayptr;
        Screen('BlendFunction', ov, 'GL_ONE', 'GL_ZERO');
        Screen('glPushMatrix', ov);
        Screen('glLoadIdentity', ov); % cover the whole window, not a degree-scaled rect
        Screen('FillRect', ov, [0 0 0 0]);
        Screen('glPopMatrix', ov);
        Screen('BlendFunction', ov, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    end
end

%-------------------------------------------------------------------------%


