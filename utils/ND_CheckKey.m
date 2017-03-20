function p = ND_CheckKey(p)
%% read in keyboard presses
% code based on pldap's default trial function.
% check for key presses and act accordingly.
%
% Be careful, in the pldaps run function is also a routine (pauseLoop) to read out key
% presses with hard coded keys (noticed too late), we need to ensure that our key layout
% matches the one defined in there.

[p.trial.keyboard.pressedQ, p.trial.keyboard.firstPressQ, firstRelease, lastPress, lastRelease] = KbQueueCheck(); % fast

if(p.trial.keyboard.pressedQ || any(firstRelease) )
    p.trial.keyboard.samples =             p.trial.keyboard.samples+1;
    p.trial.keyboard.samplesTimes(         p.trial.keyboard.samples) = GetSecs;
    p.trial.keyboard.samplesFrames(        p.trial.keyboard.samples) = p.trial.iFrame;
    p.trial.keyboard.pressedSamples(     :,p.trial.keyboard.samples) = p.trial.keyboard.pressedQ;
    p.trial.keyboard.firstPressSamples(  :,p.trial.keyboard.samples) = p.trial.keyboard.firstPressQ;
    p.trial.keyboard.firstReleaseSamples(:,p.trial.keyboard.samples) = firstRelease;
    p.trial.keyboard.lastPressSamples(   :,p.trial.keyboard.samples) = lastPress;
    p.trial.keyboard.lastReleaseSamples( :,p.trial.keyboard.samples) = lastRelease;
end

if(any(p.trial.keyboard.firstPressQ))  % this only checks the first pressed key in the buffer, might be worth to modify it in a way that the full buffer is used.

    p.trial.LastKeyPress = find(p.trial.keyboard.firstPressQ); % identify which key was pressed

    switch p.trial.LastKeyPress

        % ----------------------------------------------------------------%
        case KbName(p.trial.key.reward)
        %% reward
        % check for manual reward delivery via keyboard
            pds.reward.give(p, p.trial.task.Reward.ManDur);  % per default, output will be channel three.

        % ----------------------------------------------------------------%
        case KbName(p.trial.key.CtrFix)
        %% Center fixation    
        % set current eye position as expected fixation position
        if(p.trial.datapixx.useAsEyepos)
            p.trial.behavior.fixation.Offset = p.trial.behavior.fixation.Offset + p.trial.behavior.fixation.FixPos_pxl - ...
                                              [p.trial.eyeX, p.trial.eyeY];
            ND_CtrlMsg(p, ['fixation offset changed to ', num2str(p.trial.behavior.fixation.Offset)]);                              
        end
        
        % ----------------------------------------------------------------%
        case KbName(p.trial.key.FixReq)
        %% Fixation request    
        % disable/enable requirement of fixation for the task
            if(p.trial.behavior.fixation.use)
                if(p.trial.behavior.fixation.required)
                    p.trial.behavior.fixation.required = 0;
                    ND_CtrlMsg(p, 'Fixation requirement disabled!');                              
                else
                    p.trial.behavior.fixation.required = 1;
                    ND_CtrlMsg(p, 'Fixation requirement enabled!');                              
                end
            end
        
        % ----------------------------------------------------------------%
        case KbName(p.trial.key.FixInc)
        %% Fixation Window increase    
            if(p.trial.behavior.fixation.use)
                p.trial.behavior.fixation.FixWin = p.trial.behavior.fixation.FixWin + ...
                                                   p.trial.behavior.fixation.FixWinStp;
                p.trial.behavior.fixation.FixWin_pxl = ND_dva2pxl(p.trial.behavior.fixation.FixWin, p); % Stimulus diameter in dva
                p.trial.task.fixrect = ND_GetRect(p.trial.task.FixWinPos_pxl, ...
                                                  p.trial.behavior.fixation.FixWin_pxl);  % make sure that this will be defined in a variable way in the future
            end
        % ----------------------------------------------------------------%
        case KbName(p.trial.key.FixDec)
        %% Fixation Window increase    
            if(p.trial.behavior.fixation.use)
                p.trial.behavior.fixation.FixWin = p.trial.behavior.fixation.FixWin - ...
                                                   p.trial.behavior.fixation.FixWinStp;
                p.trial.behavior.fixation.FixWin_pxl = ND_dva2pxl(p.trial.behavior.fixation.FixWin, p); % Stimulus diameter in dva
                p.trial.task.fixrect = ND_GetRect(p.trial.task.FixWinPos_pxl, ...
                                                  p.trial.behavior.fixation.FixWin_pxl);  % make sure that this will be defined in a variable way in the future
            end
           
        % ----------------------------------------------------------------%
        case KbName(p.trial.key.CtrJoy)
        %% Center joystick    
        % set current eye position as expected fixation position
        if(p.trial.datapixx.useJoystick)
            p.trial.behavior.joystick.Zero = p.trial.behavior.joystick.Zero + [p.trial.joyX, p.trial.joyY];
        end

        % ----------------------------------------------------------------%
        case KbName(p.trial.key.pause)  
        %% pause trial
            p.trial.pldaps.quit = 1;
            ShowCursor;

        % ----------------------------------------------------------------%
        case KbName(p.trial.key.quit)
        %% quit experiment
            p.trial.pldaps.quit = 2;
            ShowCursor;

        % ----------------------------------------------------------------%
        case KbName(p.trial.key.quit)
        %%  go into debug mode
            disp('stepped into debugger. Type return to start first trial...')
            keyboard %#ok<MCKBD>
            
    end  %/ switch Kact
else
    p.trial.LastKeyPress = [];
end %/ if(any(p.trial.keyboard.firstPressQ))
