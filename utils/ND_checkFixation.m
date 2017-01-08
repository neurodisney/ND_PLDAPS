% !!! right now just a placeholder !!!
function p = ND_checkFixation(p, task)
% based on an inline function provided in: https://github.com/HukLab/PLDAPSDemos
%
% TODO: get this working !


        % WAITING FOR SUBJECT FIXATION (fp1)
        fixating=fixationHeld(p);
        if  p.trial.state == p.trial.(task).states.START
            if fixating && p.trial.ttime  < (p.trial.(task).preTrial+p.trial.(task).fixWait)
                p.trial.(task).colorFixDot = p.trial.display.clut.targetnull;
                p.trial.(task).colorFixWindow = p.trial.display.clut.window;
                p.trial.(task).timeFpEntered = p.trial.ttime;%GetSecs - p.trial.trstart;
                p.trial.(task).frameFpEntered = p.trial.iFrame;
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial)
                end
                p.trial.state = p.trial.(task).states.FPHOLD;
%             elseif p.trial.ttime  > (p.trial.(task).preTrial+p.trial.(task).fixWait) 
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial)
                end
                p.trial.(task).timeBreakFix = p.trial.ttime;%GetSecs - p.trial.trstart;
                p.trial.state = p.trial.(task).states.BREAKFIX;
            end
        end
        
        % check if fixation is held
        
        %%p.trial.ttime is set by the pldaps.runTrial function before each
        %%frame state
        if p.trial.state == p.trial.(task).states.FPHOLD
            if fixating && (p.trial.ttime > p.trial.(task).timeFpEntered + p.trial.(task).fpOffset || p.trial.iFrame==p.trial.pldaps.maxFrames)
                p.trial.(task).colorFixDot    = p.trial.display.clut.bg;
                p.trial.(task).colorFixWindow = p.trial.display.clut.bg;
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial)
                end
                p.trial.ttime      = GetSecs - p.trial.trstart;
                p.trial.(task).timeFpOff  = p.trial.ttime;
                p.trial.(task).frameFpOff = p.trial.iFrame;
                p.trial.(task).timeComplete = p.trial.ttime;
                p.trial.state      = p.trial.(task).states.TRIALCOMPLETE;
            elseif ~fixating && p.trial.ttime < p.trial.(task).timeFpEntered + p.trial.(task).fpOffset
                p.trial.(task).colorFixDot    = p.trial.display.clut.bg;
                p.trial.(task).colorFixWindow = p.trial.display.clut.bg;
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial)
                end
                p.trial.(task).timeBreakFix = GetSecs - p.trial.trstart;
                p.trial.state = p.trial.(task).states.BREAKFIX;
           
            end
        end
        
% TODO: Think about an option to store eye traces for later recall        
%         %store the eye position that was used during each frame, good
%        %for replay of the stimulus
%        p.trial.(task).eyeXYs(1:2,p.trial.iFrame)= [p.trial.eyeX-p.trial.display.pWidth/2; p.trial.eyeY-p.trial.display.pHeight/2];





% ####################################################################### %        
% Below is example code from https://github.com/jcbyts/pds-stimuli
% also check out there this function for creating fixation spots: pds-stimuli/+stimuli/fixation.m
function fixation(p, state, sn)
% fixation state management

switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        checkFixation(p, sn)
        
    case p.trial.pldaps.trialStates.trialSetup
        
        p.trial.(sn).hFix=stimuli.fixation(p.trial.display.overlayptr, ...
            'centreSize', p.trial.(sn).fixDotW/2, ...
            'surroundSize', p.trial.(sn).fixDotW, ...
            'position', p.trial.display.ctr(1:2)+pds.deg2px(p.trial.(sn).fixDotXY(:), p.trial.display.viewdist, p.trial.display.w2px, true)', ...
            'fixType', 2, ...
            'winType', 2, ...
            'centreColour', p.trial.display.clut.bg, ...
            'surroundColour', p.trial.display.clut.bg, ...
            'winColour', p.trial.display.clut.bg);
        
        p.trial.(sn).state=p.trial.(sn).states.START;
        
    case p.trial.pldaps.trialStates.frameDraw
        p.trial.(sn).hFix.drawFixation
        
end


end

function checkFixation(p, sn)
currentEye=[p.trial.eyeX p.trial.eyeY]; %p.trial.(sn).eyeXYs(1:2,p.trial.iFrame);
%     fprintf('checking: state ')
% check if fixation should be shown
switch p.trial.(sn).state
    case p.trial.(sn).states.START
        %             fprintf('START\n')
        
        % time to turn on fixation
        if p.trial.ttime > p.trial.(sn).preTrial
            fixOn(p,sn) % fixation point on
        end
        
    case p.trial.(sn).states.FPON
        %             fprintf('FPON\n')
        % is fixation held
        isheld=p.trial.(sn).hFix.isheld(currentEye);
        if isheld && p.trial.ttime < p.trial.(sn).fixWait + p.trial.(sn).timeFpOn
            fixHold(p,sn)
        elseif p.trial.ttime > p.trial.(sn).fixWait + p.trial.(sn).timeFpOn
            breakFix(p,sn)
        end
        
    case p.trial.(sn).states.FPHOLD
        %             fprintf('FPHOLD\n')
        % fixation controls motion
        if ~p.trial.(sn).showMotion && p.trial.iFrame > p.trial.(sn).frameFpEntered + p.trial.(sn).preStim
            motionOn(p,sn)
        end
        
        % is fixation held
        isheld=p.trial.(sn).hFix.isheld(currentEye);
        if isheld && p.trial.ttime < p.trial.(sn).maxFixHold + p.trial.(sn).timeFpEntered
            % do nothing
        elseif ~isheld && p.trial.ttime > p.trial.(sn).minFixHold + p.trial.(sn).timeFpEntered
            fixOff(p,sn)
            motionOff(p,sn)
        else % break fixation
            breakFix(p,sn)
        end
        
        
end

end

function breakFix(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.sColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.winColour=p.trial.display.clut.bg;
% PsychPortAudio('Start', p.trial.sound.breakfix)

p.trial.(sn).timeFpOff = p.trial.ttime;
p.trial.(sn).frameFpOff = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.BREAKFIX;
end

function fixOn(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.white;
p.trial.(sn).hFix.sColour = p.trial.display.clut.black;
p.trial.(sn).hFix.winColour=p.trial.display.clut.window;

p.trial.(sn).timeFpOn = p.trial.ttime;
p.trial.(sn).frameFpOn = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.FPON;
end

function fixHold(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.white;
p.trial.(sn).hFix.sColour = p.trial.display.clut.black;
p.trial.(sn).hFix.winColour=p.trial.display.clut.greenbg;

p.trial.(sn).timeFpEntered = p.trial.ttime;
p.trial.(sn).frameFpEntered = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.FPHOLD;
end

function fixOff(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.sColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.winColour=p.trial.display.clut.bg;

p.trial.(sn).timeFpOff = p.trial.ttime;
p.trial.(sn).frameFpOff = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.CHOOSETARG;
end

function motionOn(p,sn)
if ~p.trial.(sn).showMotion
    p.trial.(sn).showMotion=true;
    p.trial.(sn).timeStimOn=p.trial.ttime;
    p.trial.(sn).frameStimOn=p.trial.iFrame;
end
end

function motionOff(p,sn)
if p.trial.(sn).showMotion
    p.trial.(sn).showMotion=false;
    p.trial.(sn).timeStimOff=p.trial.ttime;
    p.trial.(sn).frameStimOff=p.trial.iFrame;
end
end


