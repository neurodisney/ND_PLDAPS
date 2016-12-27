function p = ND_checkTrialState(p)
% based on an inline function provided in: https://github.com/HukLab/PLDAPSDemos


        if p.trial.state == p.trial.stimulus.states.TRIALCOMPLETE
            p.trial.pldaps.goodtrial = 1;
            
            pds.behavior.reward.give(p);
              
            if p.trial.datapixx.use
                pds.datapixx.flipBit(p.trial.event.TRIALEND,p.trial.pldaps.iTrial);
            end
            p.trial.flagNextTrial = true;
        end
        
        if p.trial.state == p.trial.stimulus.states.BREAKFIX
            % turn off stimulus
            p.trial.stimulus.colorFixDot        = p.trial.display.clut.bg;            % fixation point 1 color
            p.trial.stimulus.colorFixWindow     = p.trial.display.clut.bg;           % fixation window color
            p.trial.pldaps.goodtrial = 0;
            p.trial.targOn = 2;
            if p.trial.sound.use && ~isnan( p.trial.stimulus.timeFpEntered) 
                PsychPortAudio('Start', p.trial.sound.breakfix, 1, [], [], GetSecs + .1);
            end
            p.trial.flagNextTrial = true;
        end