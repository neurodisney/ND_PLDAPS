function qp = ND_CheckKeyMouse(p, task)
%% read in keyboard and mouse information
% code based on pldap's default trial function.
% check for key presses and mouse actions and act accordingly.
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
        
        qp = find(p.trial.keyboard.firstPressQ); % identify which key was pressed
        
        switch qp
            
            case KbName(SS.key.reward)
            % check for manual reward delivery via keyboard
                pds.behavior.reward.give(p, p.trial.(task).Reward.ManDur);  % per default, output will be channel three.
                
            case KbName(SS.key.pause)    
            % pause trial    
                p.trial.pldaps.quit = 1;
                ShowCursor;
                
            case KbName(SS.key.quit)    
            % quit experiment
                p.trial.pldaps.quit = 2;
                ShowCursor;
                
            case KbName(SS.key.quit)    
            %  go into debug mode
                disp('stepped into debugger. Type return to start first trial...')
                keyboard %#ok<MCKBD>
                
        end  %/ switch Kact
    else
        qp = [];
    end %/ if(any(p.trial.keyboard.firstPressQ))
    
     % get mouse/eyetracker data
    if(p.trial.mouse.use)
        [cursorX, cursorY,isMouseButtonDown] = GetMouse();
        
        p.trial.mouse.samples =              p.trial.mouse.samples+1;
        p.trial.mouse.samplesTimes(          p.trial.mouse.samples) = GetSecs;
        p.trial.mouse.cursorSamples(     1:2,p.trial.mouse.samples) = [cursorX;cursorY];
        p.trial.mouse.buttonPressSamples( :, p.trial.mouse.samples) = isMouseButtonDown';

        if(p.trial.mouse.use && p.trial.mouse.useAsEyepos) 
            if p.trial.pldaps.eyeposMovAv==1
                p.trial.eyeX = p.trial.mouse.cursorSamples(1,p.trial.mouse.samples);
                p.trial.eyeY = p.trial.mouse.cursorSamples(2,p.trial.mouse.samples);
            else
                mInds = (p.trial.mouse.samples-p.trial.pldaps.eyeposMovAv+1):p.trial.mouse.samples;
                p.trial.eyeX = mean(p.trial.mouse.cursorSamples(1,mInds));
                p.trial.eyeY = mean(p.trial.mouse.cursorSamples(2,mInds));
            end
        end  %/ if(p.trial.mouse.use && p.trial.mouse.useAsEyepos) 
    end  %/  if(p.trial.mouse.use)
    