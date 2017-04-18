function p = draw(p)
% pds.fixation.draw(p)    draw current fixation spot
%
% wolf zinke, april 2017

%% fixation target
switch  Ftype
    case 'disc'
        Screen('FillOval',  p.trial.display.overlayptr, p.trial.display.clut.(p.trial.behavior.fixation.FixCol), p.trial.behavior.fixation.FixRect);
        
    case 'rect'
        Screen('FillRect',  p.trial.display.overlayptr, p.trial.display.clut.(p.trial.behavior.fixation.FixCol), p.trial.behavior.fixation.FixRect);
        
    case 'off'
        % no fixation spot shown, fixation window likely bound to another item
        
    otherwise
        error('Unknown type of fixation spot: %s', p.trial.behavior.fixation.FixType);
end

%% fixation window
if(p.trial.behavior.fixation.use)
    if(p.trial.FixState.Current == p.trial.FixState.FixOut && p.trial.behavior.fixation.required)
        Screen('FrameOval', p.trial.display.overlayptr, p.trial.display.clut.eyeold, p.trial.behavior.fixation.FixWinRect, ...
                            p.trial.pldaps.draw.eyepos.fixwinwdth, p.trial.pldaps.draw.eyepos.fixwinwdth);
                        
    elseif(p.trial.FixState.Current == p.trial.FixState.FixIn && p.trial.behavior.fixation.required)
        Screen('FrameOval', p.trial.display.overlayptr, p.trial.display.clut.eyepos, p.trial.behavior.fixation.FixWinRect, ...
                            p.trial.pldaps.draw.eyepos.fixwinwdth, p.trial.pldaps.draw.eyepos.fixwinwdth);
    else
        Screen('FrameOval', p.trial.display.overlayptr, p.trial.display.clut.window, p.trial.behavior.fixation.FixWinRect, ...
                            p.trial.pldaps.draw.eyepos.fixwinwdth, p.trial.pldaps.draw.eyepos.fixwinwdth);
    end
end

