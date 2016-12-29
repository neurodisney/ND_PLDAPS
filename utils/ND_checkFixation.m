function p = ND_checkFixation(p)
% based on an inline function provided in: https://github.com/HukLab/PLDAPSDemos
% right now just a placeholder
%
% TODO: get this working !


        % WAITING FOR SUBJECT FIXATION (fp1)
        fixating=fixationHeld(p);
        if  p.trial.state == p.trial.stimulus.states.START
            if fixating && p.trial.ttime  < (p.trial.stimulus.preTrial+p.trial.stimulus.fixWait)
                p.trial.stimulus.colorFixDot = p.trial.display.clut.targetnull;
                p.trial.stimulus.colorFixWindow = p.trial.display.clut.window;
                p.trial.stimulus.timeFpEntered = p.trial.ttime;%GetSecs - p.trial.trstart;
                p.trial.stimulus.frameFpEntered = p.trial.iFrame;
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial)
                end
                p.trial.state = p.trial.stimulus.states.FPHOLD;
            elseif p.trial.ttime  > (p.trial.stimulus.preTrial+p.trial.stimulus.fixWait) 
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial)
                end
                p.trial.stimulus.timeBreakFix = p.trial.ttime;%GetSecs - p.trial.trstart;
                p.trial.state = p.trial.stimulus.states.BREAKFIX;
            end
        end
        
        % check if fixation is held
        
        %%p.trial.ttime is set by the pldaps.runTrial function before each
        %%frame state
        if p.trial.state == p.trial.stimulus.states.FPHOLD
            if fixating && (p.trial.ttime > p.trial.stimulus.timeFpEntered + p.trial.stimulus.fpOffset || p.trial.iFrame==p.trial.pldaps.maxFrames)
                p.trial.stimulus.colorFixDot    = p.trial.display.clut.bg;
                p.trial.stimulus.colorFixWindow = p.trial.display.clut.bg;
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial)
                end
                p.trial.ttime      = GetSecs - p.trial.trstart;
                p.trial.stimulus.timeFpOff  = p.trial.ttime;
                p.trial.stimulus.frameFpOff = p.trial.iFrame;
                p.trial.stimulus.timeComplete = p.trial.ttime;
                p.trial.state      = p.trial.stimulus.states.TRIALCOMPLETE;
            elseif ~fixating && p.trial.ttime < p.trial.stimulus.timeFpEntered + p.trial.stimulus.fpOffset
                p.trial.stimulus.colorFixDot    = p.trial.display.clut.bg;
                p.trial.stimulus.colorFixWindow = p.trial.display.clut.bg;
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial)
                end
                p.trial.stimulus.timeBreakFix = GetSecs - p.trial.trstart;
                p.trial.state = p.trial.stimulus.states.BREAKFIX;
           
            end
        end
        
% TODO: Think about an option to store eye traces for later recall        
%         %store the eye position that was used during each frame, good
%        %for replay of the stimulus
%        p.trial.stimulus.eyeXYs(1:2,p.trial.iFrame)= [p.trial.eyeX-p.trial.display.pWidth/2; p.trial.eyeY-p.trial.display.pHeight/2];

