function p = ND_CheckKey(p)
%% read in keyboard presses
% code based on pldap's default trial function.
% check for key presses and act accordingly.
%
% wolf zinke & Nate Faber

[p.trial.keyboard.pressedQ, p.trial.keyboard.firstPressQ, firstRelease, lastPress, lastRelease] = KbQueueCheck(); % fast

if(p.trial.pldaps.pause ~= 0)
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
end

if(any(p.trial.keyboard.firstPressQ))  % this only checks the first pressed key in the buffer, might be worth to modify it in a way that the full buffer is used.

    p.trial.LastKeyPress = find(p.trial.keyboard.firstPressQ); % identify which key was pressed

    % If the keyboard is freed, don't interpret key presses. Just discard the input
    if(p.trial.pldaps.keyboardFree)
        % Unfree the keyboard if the stopFreeKeyboard key is pressed
        if(any(p.trial.LastKeyPress == p.trial.key.stopFreeKeyboard))
            p.trial.pldaps.keyboardFree = 0;            
            ND_CtrlMsg(p, 'Standard PLDAPS mode engaged');
            ListenChar(2);
            HideCursor;
        end

        % Discard input queue so as not to interpret it
        p.trial.LastKeyPress = [];
    end
    
    for(i=1:length(p.trial.LastKeyPress))
        switch p.trial.LastKeyPress(i)

            % ----------------------------------------------------------------%
            case p.trial.key.reward
            %% reward
            % check for manual reward delivery via keyboard
                if(p.trial.datapixx.useForReward)
                    pds.reward.give(p, p.trial.reward.ManDur);  % per default, output will be channel three.
                    ND_CtrlMsg(p, 'Click... Reward delivered.');
                end
                
            % ----------------------------------------------------------------%
            case p.trial.key.FixInc
            %% Fixspot window increase
                if(p.trial.behavior.fixation.use)
                    % Increase the fixation window for all existing fixspots
                    for(j = 1:length(p.trial.stim.allStims))
                        stim = p.trial.stim.allStims{j};
                        if(isa(stim,'pds.stim.FixSpot'))
                            stim.fixWin = stim.fixWin + p.trial.behavior.fixation.FixWinStp;
                        end
                    end
                    % Increase the fixation window for fixspots created later
                    p.trial.stim.FIXSPOT.fixWin = p.trial.stim.FIXSPOT.fixWin + p.trial.behavior.fixation.FixWinStp;
                    
                    ND_CtrlMsg(p, sprintf('Changed fixation window to %.2f dva.', p.trial.stim.FIXSPOT.fixWin));
                end

            % ----------------------------------------------------------------%
            case p.trial.key.FixDec
            %% Fixspot window decrease
                if(p.trial.behavior.fixation.use)
                    % Decrease the fixation window for all existing fixspots
                    for(j = 1:length(p.trial.stim.allStims))
                        stim = p.trial.stim.allStims{j};
                        if(isa(stim,'pds.stim.FixSpot'))
                            stim.fixWin = stim.fixWin - p.trial.behavior.fixation.FixWinStp;
                        end
                    end
                    % Decrease the fixation window for fixspots created later
                    p.trial.stim.FIXSPOT.fixWin = p.trial.stim.FIXSPOT.fixWin - p.trial.behavior.fixation.FixWinStp;
                    
                    ND_CtrlMsg(p, sprintf('Changed fixation window to %.2f dva.', p.trial.stim.FIXSPOT.fixWin));
                end

            % ----------------------------------------------------------------%
            case p.trial.key.CtrJoy
            %% Center joystick
                % set current eye position as expected fixation position
                if(p.trial.datapixx.useJoystick)
                    p.trial.behavior.joystick.Zero = p.trial.behavior.joystick.Zero + [p.trial.joyX, p.trial.joyY];
                end

            % ----------------------------------------------------------------%
            case p.trial.key.viewEyeCalib
            %% Toggle viewing eye calibration
                if(p.trial.behavior.fixation.useCalibration)
                    p.trial.behavior.fixation.enableCalib = not(p.trial.behavior.fixation.enableCalib);
                end

            % ----------------------------------------------------------------%
            case p.trial.key.BlockAdvance
            %% advance to new block
                ND_BlockAdvance(p);

            % ----------------------------------------------------------------%
            case p.trial.key.BlockEqualCorrect
            %% Switch balancing correct trials or all trials
                if(p.trial.Block.EqualCorrect == 1)
                    p.trial.Block.EqualCorrect = 0;
                    ND_CtrlMsg(p, 'Accept all trials');

                else
                    p.trial.Block.EqualCorrect = 1;
                    ND_CtrlMsg(p, 'Accept only correct trials');
                end
                
            % ----------------------------------------------------------------%
            case p.trial.key.spritz
            %% Send a TTL pulse to the picospritzer to trigger drug release
                ND_PulseSeries(p.trial.datapixx.TTL_spritzerChan,    p.trial.datapixx.TTL_spritzerDur,       ...
                               p.trial.datapixx.TTL_spritzerNpulse,  p.trial.datapixx.TTL_spritzerPulseGap,  ...
                               p.trial.datapixx.TTL_spritzerNseries, p.trial.datapixx.TTL_spritzerSeriesGap, ...
                               p.trial.event.INJECT);
                ND_CtrlMsg(p, 'Trigger for drug delivery issued!');

            % ----------------------------------------------------------------%
            case p.trial.key.pause
            %% pause experiment
%                 p.trial.pldaps.pause = ~p.trial.pldaps.pause;
                if(~p.trial.pldaps.pause)
                    p.trial.pldaps.pause = 1;
                    ND_CtrlMsg(p,'Pausing after current trial...');
                else
                    p.trial.pldaps.pause = 0;
                    ND_CtrlMsg(p,'Pause cancelled.');
                    pds.datapixx.strobe(p.trial.event.UNPAUSE);
                end

            % ----------------------------------------------------------------%
            case p.trial.key.break
            %% break experiment
                if(~p.trial.pldaps.pause)
                    p.trial.pldaps.pause = 2;
                    ND_CtrlMsg(p,'Starting break...');

                    % Finish up the trial
                    p.trial.outcome.CurrOutcome = p.trial.outcome.Break;
                    tms = pds.datapixx.strobe(p.trial.event.TASK_OFF);
                    p.trial.EV.DPX_TaskOff = tms(1);
                    p.trial.EV.TDT_TaskOff = tms(2);

                    p.trial.EV.TaskEnd  = p.trial.CurTime;
                    p.trial.EV.TrialEnd = p.trial.CurTime;
                    
                    if(p.trial.datapixx.TTL_trialOn)
                        pds.datapixx.TTL(p.trial.datapixx.TTL_trialOnChan, 0);
                    end

                    % End the trial
                    p.trial.flagNextTrial = 1;
                else
                    p.trial.pldaps.pause = 0;
                    ND_CtrlMsg(p,'Break cancelled.');
                    pds.datapixx.strobe(p.trial.event.UNBREAK);
                end

            % ----------------------------------------------------------------%
            case p.trial.key.quit
            %% quit experiment
                p.trial.pldaps.quit = 2;
                ShowCursor;

            % ----------------------------------------------------------------%
            case(p.trial.key.freeKeyboard)
             %% Free the keyboard to be used in other programs
                p.trial.pldaps.keyboardFree = 1;

                disableKey = KbName(p.trial.key.stopFreeKeyboard);
                ND_CtrlMsg(p,['Keyboard freed for normal functioning. When done, hit ', disableKey]);

                ShowCursor;
                ListenChar(0);

        end  %  switch p.trial.LastKeyPress(i)
    end  %  for(i=1:length(p.trial.LastKeyPress))
else
    p.trial.LastKeyPress = [];
end %/ if(any(p.trial.keyboard.firstPressQ))


