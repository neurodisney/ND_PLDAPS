 % Function to run task for experiment
function p = AttendGrat(p, state)

    % Checking for task name and filling if empty
    if(~exist('state','var'))
        state = [];
    end

    % Initializing task
    if(isempty(state))
        % Populating pldaps object with elements needed to begin task if empty
        p = AttendGrat_init(p);

    else
        % If pldaps object is populated, standard trial routines run
        p = ND_GeneralTrialRoutines(p, state);

        % Executing events/epochs that make up trial
        switch state
            % Gathing information to start trial
            case p.trial.pldaps.trialStates.trialSetup
                TaskSetUp(p);  

            % Perparing gathered information before trial launch to ensure precise timing    
            case p.trial.pldaps.trialStates.trialPrepare
                p.trial.EV.TrialStart = p.trial.CurTime;

            % Launching trial    
            case p.trial.pldaps.trialStates.framePrepareDrawing 
                % Function for doing task-specific actions using keyboard
                % commands--not set up, look at DetectGrat for reference 
                %if(~isempty(p.trial.LastKeyPress))
                    %KeyAction(p);
                %end
                TaskDesign(p);
            
            % Cleaning up items used for trial and saving data
            case p.trial.pldaps.trialStates.trialCleanUpandSave
                %TaskCleanAndSave(p);
                
        end
    end



    % Function to gather materials to start trial
    function TaskSetUp(p)

        % Trial marked as incorrect(0) until it is done successfully(1)
        p.trial.task.Good = 0;
        % Creating spot to store selection of target stimulus
        p.trial.task.TargetSel = NaN;
        % Fixation has not yet been achieved(1), till then is marked as absent(0)
        p.trial.task.fixFix = 0;
        % Tracking whether monkey is look at stim(1) or away from stim(0)
        p.trial.task.stimFix = 0;
        % Tracking whether stimuli are on(1) or off(0)
        p.trial.task.stimState = 0;
        % Creating place to save when fixation started
        p.trial.task.SRT_FixStart = NaN;
        % Creating place to save when stimuli came on screen
        p.trial.task.SRT_StimOn = NaN;

        % Generating fixation spot stimulus
        p.trial.stim.fix = pds.stim.FixSpot(p);

        % Shuffling positions in positions list
        p.trial.stim.posList = p.trial.task.posList(randperm(length(p.trial.task.posList)));

        % Creating cue ring by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        p.trial.stim.RING.pos = cell2mat(p.trial.stim.posList(1));
        p.trial.stim.RING.contrast = p.trial.stim.ringParameters.cue.contrast;
        p.trial.stim.RING.color = p.trial.stim.ringParameters.cue.color;
        p.trial.stim.RING.isCue = 1;
        p.trial.stim.rings.cue = pds.stim.Ring(p);

        % Creating distractor ring 1 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        p.trial.stim.RING.pos = cell2mat(p.trial.stim.posList(2));
        p.trial.stim.RING.contrast = p.trial.stim.ringParameters.distractor.contrast;
        p.trial.stim.RING.color = p.trial.stim.ringParameters.distractor.color;
        p.trial.stim.RING.isCue = 0;
        p.trial.stim.rings.distractor1 = pds.stim.Ring(p);

        % Creating distractor ring 2 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        p.trial.stim.RING.pos = cell2mat(p.trial.stim.posList(3));
        p.trial.stim.RING.contrast = p.trial.stim.ringParameters.distractor.contrast;
        p.trial.stim.RING.color = p.trial.stim.ringParameters.distractor.color;
        p.trial.stim.RING.isCue = 0;
        p.trial.stim.rings.distractor2 = pds.stim.Ring(p);

        % Creating distractor ring 3 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        p.trial.stim.RING.pos = cell2mat(p.trial.stim.posList(4));
        p.trial.stim.RING.contrast = p.trial.stim.ringParameters.distractor.contrast;
        p.trial.stim.RING.color = p.trial.stim.ringParameters.distractor.color;
        p.trial.stim.RING.isCue = 0;
        p.trial.stim.rings.distractor3 = pds.stim.Ring(p);

        % Gathing random orientations for gratings
        p.trial.stim.gratingParameters.oriList = datasample(p.trial.task.gratingOriList, 5);
        
        % Creating target grating pre-orientation change by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.GRATING.pos = cell2mat(p.trial.stim.posList(1));
        p.trial.stim.GRATING.ori = p.trial.stim.gratingParameters.oriList(1);
        p.trial.stim.gratings.preTarget = pds.stim.Grating(p);

        % Creating target grating post-orientation change by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.GRATING.pos = cell2mat(p.trial.stim.posList(1));
        p.trial.stim.GRATING.ori = p.trial.stim.gratingParameters.oriList(2);
        p.trial.stim.gratings.postTarget = pds.stim.Grating(p);

        % Creating distractor grating 1 by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.GRATING.pos = cell2mat(p.trial.stim.posList(2));
        p.trial.stim.GRATING.ori = p.trial.stim.gratingParameters.oriList(3);
        p.trial.stim.gratings.distractor1 = pds.stim.Grating(p);

        % Creating distractor grating 2 by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.GRATING.pos = cell2mat(p.trial.stim.posList(3));
        p.trial.stim.GRATING.ori = p.trial.stim.gratingParameters.oriList(4);
        p.trial.stim.gratings.distractor2 = pds.stim.Grating(p);

        % Creating distractor grating 3 by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.GRATING.pos = cell2mat(p.trial.stim.posList(4));
        p.trial.stim.GRATING.ori = p.trial.stim.gratingParameters.oriList(5);
        p.trial.stim.gratings.distractor3 = pds.stim.Grating(p);
        
        % Creating counter to track wait time before grating presentation 
        p.trial.task.CueWait.duration = 300;
        p.trial.task.CueWait.counter = 0;
        
        % Selecting time of wait before target grating change from flat hazard function
        wait_period = datasample(p.trial.task.flatHazard, 1);
        p.trial.task.GratWait.duration = round(wait_period * 200);
        p.trial.task.GratWait.counter = 0;

        % Taking control of activation of grating fix windows
        p.trial.stim.gratingParameters.targetAutoFixWin = 0;
        p.trial.stim.gratingParameters.distractorAutoFixWin =0;

        % Increasing Reward after specific number of correct trials
        reward_duration = find(p.trial.reward.IncrementTrial > p.trial.NHits + 1, 1, 'first');
        p.trial.reward.Dur = p.trial.reward.IncrementDur(reward_duration);

        % Reducing current reward if previous trial was incorrect
        if(p.trial.LastHits == 0)
            p.trial.reward.Dur = p.trial.reward.Dur * p.trial.reward.DiscourageProp;
        end

        % Moving task from step-up stage to wait period before launching
        ND_SwitchEpoch(p, 'ITI');



    % Function to execute trial
    function TaskDesign(p)

        % Moving from epoch to epoch over course of trial
        switch p.trial.CurrEpoch
            % Implementing wait period to ensure enough time has passed since previous trial 
            case p.trial.epoch.ITI
                Task_WaitITI(p);

            % Starting trial by presenting fix point
            case p.trial.epoch.TrialStart

                % Turning task on
                Task_ON(p);

                % Presenting fix point
                ND_FixSpot(p, 1);

                % Recording start time of task
                p.trial.EV.TaskStart = p.trial.CurTime;
                p.trial.EV.TaskStartTime = datestr(now, 'HH:MM:SS:FFF');

                ND_SwitchEpoch(p,'WaitFix');

            % Checking if fixation has been achieved within pre-set abount time 
            case p.trial.epoch.WaitFix
                Task_WaitFixStart(p);

            % Presenting rings if fixation held
            case p.trial.epoch.Fixating
                % Is monkey fixating at this point in task?
                if(p.trial.stim.fix.fixating)
                    % Are stimuli on screen?
                    if(p.trial.task.stimState == 0)
                        % Is current time after presentation of fix point?
                        if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)
                            % Presenting rings 
                            stimRings(p, 1)
                            ND_SwitchEpoch(p, 'WaitCue');  
                        end
                    end
                end
                
                % Is monkey no longer fixating?
                if(~p.trial.stim.fix.fixating)         
                    % Play noise signaling fix break
                    pds.audio.playDP(p, 'breakfix', 'left'); 
                    % Calculating and storing time from fix start to fix leave if fix broken
                    p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                    % Calculating and storing time from presenting fix point to fix leave if fix broken
                    p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - (p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency);
                    % Checking to confirm there was fix break before ending trial
                    ND_SwitchEpoch(p, 'BreakFixCheck');
                end
            
            % Checking if fixation held for pre-set amount of time before presenting gratings pre-orientation change
            case p.trial.epoch.WaitCue
                if(p.trial.stim.fix.fixating)
                    if p.trial.task.CueWait.counter == p.trial.task.CueWait.duration
                        stimPreGratOriChange(p, 2);
                        ND_SwitchEpoch(p, 'WaitChange')
                    else
                        p.trial.task.CueWait.counter = p.trial.task.CueWait.counter + 1;   
                    end
                    
                elseif(~p.trial.stim.fix.fixating)        
                        % Play noise signaling fix break
                        pds.audio.playDP(p, 'breakfix', 'left'); 
                        % Calculating and storing time from fix start to fix leave if fix broken
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Calculating and storing time from presenting fix point to fix leave if fix broken
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - (p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency);
                        % Checking to confirm there was fix break before ending trial
                        ND_SwitchEpoch(p, 'BreakFixCheck');
                end
                
            % Checking if fixation held for time pulled from hazard function before presenting gratings post-orientation change
            case p.trial.epoch.WaitChange
                if(p.trial.stim.fix.fixating)
                    if p.trial.task.GratWait.counter == p.trial.task.GratWait.duration
                        stimPostGratOriChange(p, 3);
                        ND_SwitchEpoch(p, 'WaitSaccade')
                    else
                        p.trial.task.GratWait.counter = p.trial.task.GratWait.counter + 1; 
                    end
                    
                elseif(~p.trial.stim.fix.fixating)        
                        % Play noise signaling fix break
                        pds.audio.playDP(p, 'breakfix', 'left'); 
                        % Calculating and storing time from fix start to fix leave if fix broken
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Calculating and storing time from presenting fix point to fix leave if fix broken
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - (p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency);
                        % Checking to confirm there was fix break before ending trial
                        ND_SwitchEpoch(p, 'BreakFixCheck');
                end
               
            % Beginning time period in which saccade to target must be performed
            case p.trial.epoch.WaitSaccade
                % Checking if gaze has left fix point
                if(~p.trial.stim.fix.looking)
                    % If gaze has left fix point, checking if saccade was to target
                    ND_SwitchEpoch(p, 'CheckResponse');
                
                % If fix held, checking time against pre-set response window before ending trial due to time-out    
                elseif(p.trial.CurTime > p.trial.EV.StimOn + p.trial.task.saccadeTimeout)
                    % Marking trial outcome as 'Miss' trial
                    p.trial.outcome.CurrOutcome = p.trial.outcome.Miss;
                    % Play noise signaling response period time-out
                    pds.audio.playDP(p, 'incorrect', 'left');
                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');
                end
               
            % Checking if saacade response made was to target    
            case p.trial.epoch.CheckResponse
                % Confirming current gaze shift is first response made
                if(~p.trial.task.stimFix)
                    % Checking if gaze specifically within target grating fix window
                    if(p.trial.stim.gratings.postTarget.fixating)
                        % Logging correct selection of grating (target)
                        p.trial.task.stimFix = 1;
                        p.trial.task.TargetSel = 1;
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        
                    % Checking if gaze specifically within distractor 1 grating fix window
                    elseif(p.trial.stim.gratings.distractor1.fixating)
                        % Playing noise signaling incorrect selection
                        pds.audio.playDP(p, 'incorrect', 'left');
                        % Logging incorrect selection of grating (distractor)
                        p.trial.task.TargetSel = 0;
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        % Marking trial as false and ending trial
                        p.trial.outcome.CurrOutcome = p.trial.outcome.False;
                        ND_SwitchEpoch(p, 'TaskEnd');
                        
                    % Checking if gaze specifically within distractor 2 grating fix window   
                    elseif(p.trial.stim.gratings.distractor2.fixating)
                        % Playing noise signaling incorrect selection
                        pds.audio.playDP(p, 'incorrect', 'left');
                        % Logging incorrect selection of grating (distractor)
                        p.trial.task.TargetSel = 0;
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        % Marking trial as false and ending trial
                        p.trial.outcome.CurrOutcome = p.trial.outcome.False;
                        ND_SwitchEpoch(p, 'TaskEnd')
                        
                    % Checking if gaze specifically within distractor 3 grating fix window   
                    elseif(p.trial.stim.gratings.distractor3.fixating)
                        % Playing noise signaling incorrect selection
                        pds.audio.playDP(p, 'incorrect', 'left');
                        % Logging incorrect selection of grating (distractor)
                        p.trial.task.TargetSel = 0;
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        % Marking trial as false and ending trial
                        p.trial.outcome.CurrOutcome = p.trial.outcome.False;
                        ND_SwitchEpoch(p, 'TaskEnd')
                        
                    % Verifying if gaze shifted from fix spot but no grating selected    
                    elseif(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + p.trial.task.breakFixCheck)
                        % Marking trail as No Fix on Target
                        p.trial.outcome.CurrOutcome = p.trial.outcome.NoTargetFix;
                        % Playing noise signaling no selection made
                        pds.audio.playDP(p, 'incorrect', 'left');
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                    
                    % Checking if gaze returned to fix point in time to be considered 'no response yet'    
                    elseif(p.trial.stim.fix.looking)
                        ND_SwitchEpoch(p, 'WaitSaccade');
                    end
                    
                else
                    % Checking if fix on target held for pre-set minimum amount of time 
                    if(p.trial.CurTime > p.trial.stim.gratings.postTarget.EV.FixStart + p.trial.task.minTargetFixTime)
                        % Marking trial as correct
                        p.trial.outcomeCurrOutcome = p.trial.outcome.Correct;
                        p.trial.task.Good = 1;
                        % Dispensing reward for correct trial
                        pds.reward.give(p, p.trial.reward.Dur);
                        % Playing noise signaling correct selection
                        pds.audio.playDP(p, 'reward', 'left')
                        % Record time of reward
                        p.trial.EV.Reward = p.trial.CurTime;
                        % Switching epoch to wait period before ending trial to allow for juice flow 
                        ND_SwitchEpoch(p, 'WaitEnd');
                    
                    % Checking if gaze leaves target grating fix window
                    elseif(~p.trial.stim.gratings.postTarget.fixating)
                        % Marking trial as Target Break
                        p.trial.outcome.CurrOutcome = p.trial.outcome.TargetBreak;
                        % Playing noise signaling break of fix from target
                        pds.audio.playDP(p, 'incorrect', 'left');
                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                    end
                end
                     
            % Checking if fixation was broken pre-maturely    
            case p.trial.epoch.BreakFixCheck
                delay = p.trial.task.breakFixCheck;
                % Checking if fix break was committed before response window
                if(p.trial.task.stimState < 1)
                    % Marking trial as fix break if it occured before response window
                    p.trial.outcpme.CurrOutcome = p.trial.outcome.FixBreak;
                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');
                    
                elseif(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + delay)
                    % Collecting screen frames for trial to check median eye position
                    frames = ceil(p.trial.display.frate * delay);
                    % Calculating median position of eyes across frames
                    medPos = 1; % prctile([p.trial.eyeX_hist(1:frames)', p.trial.eyeY_hist(1:frames)'], 50);
                    
                    % Checking if median eye position is in fixation window of target 
                    if(inFixWin(p.trial.stim.gratings.postTarget, medPos))
                        % Marking trial as "hit" but early if eye position is in target fix window
                        p.trial.outcome.CurrOutcome = p.trial.outcome.Early;
                    
                    % Checking if median eye position is in fixation window of distractor 1
                    elseif(inFixWin(p.trial.stim.gratings.distractor1, medPos))
                        % Marking trial as "miss" but early if eye position is in distractor fix window
                        p.trial.outcome.CurrOutcome = p.trial.outcome.EarlyFalse;
                        
                    % Checking if median eye position is in fixation window of distractor 2
                    elseif(inFixWin(p.trial.stim.gratings.distractor2, medPos))
                        % Marking trial as "miss" but early if eye position is in distractor fix window
                        p.trial.outcome.CurrOutcome = p.trial.outcome.EarlyFalse;
                        
                    % Checking if median eye position is in fixation window of distractor 3
                    elseif(inFixWin(p.trial.stim.gratings.distractor3, medPos))
                        % Marking trial as "miss" but early if eye position is in distractor fix window
                        p.trial.outcome.CurrOutcome = p.trial.outcome.EarlyFalse;
               
                    else
                        % Marking trial as fix break without relevance to task
                        p.trial.outcome.CurrOutcome = p.trial.outcome.StimBreak;
                        
                    end 
                    
                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');
                
                end
                
            % Wait period before turning off all stimuli 
            case p.trial.epoch.WaitEnd
                if(p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.Timing.WaitEnd)
                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');
                end

            % Ending task
            case p.trial.epoch.TaskEnd
                % Turning rings off
                stimRings(p, 0);
                
                % Turning gratings off
                stimPreGratOriChange(p, 0);
                stimPostGratOriChange(p, 0);
                
                % Turning fix point off
                ND_FixSpot(p, 0);
                
                % Running clean-up and storage routine before concluding trial
                Task_OFF(p);
                
                % Checking if there is "nan" value for start of fixation on target
                if(~isnan(p.trial.stim.gratings.postTarget.EV.FixStart))
                    p.trial.EV.FixStimStart = p.trial.stim.gratings.postTarget.EV.FixStart;
                    p.trial.EV.FixStimStop = p.trial.stim.gratings.postTarget.EV.FixBreak;
                    
                % Checking if there is "nan" value for start of fixation on distractor 1    
                elseif(~isnan(p.trial.stim.gratings.distractor1.EV.FixStart))
                    p.trial.EV.FixStimStart = p.trial.stim.gratings.distractor1.EV.FixStart;
                    p.trial.EV.FixStimStop = p.trial.stim.gratings.distractor1.EV.FixBreak;
                    
                % Checking if there is "nan" value for start of fixation on distractor 2    
                elseif(~isnan(p.trial.stim.gratings.distractor2.EV.FixStart))
                    p.trial.EV.FixStimStart = p.trial.stim.gratings.distractor2.EV.FixStart;
                    p.trial.EV.FixStimStop = p.trial.stim.gratings.distractor2.EV.FixBreak;
                
                % Checking if there is "nan" value for start of fixation on distractor 3    
                elseif(~isnan(p.trial.stim.gratings.distractor3.EV.FixStart))
                    p.trial.EV.FixStimStart = p.trial.stim.gratings.distractor3.EV.FixStart;
                    p.trial.EV.FixStimStop = p.trial.stim.gratings.distractor3.EV.FixBreak;
                end 
                
                % Flagging completion of current trial so ITI is run before next trial
                p.trial.flagNextTrial = 1;
               
        end


    
    % Function to present stimuli on screen before orientation change
    function stimRings(p, val)
        
        % Checking if status of stimulus presentation is different from previous trial
        if(val ~= p.trial.task.stimState)
            % Updating status of stimulus presentation if different from previous trial 
            p.trial.task.stimState = val;
            
            % Turning stimulus presentation on/off based on stimulus presentation status
            switch val
                
                % Implementing no stimulus presentation
                case 0
                    p.trial.stim.rings.cue.on = 0;
                    p.trial.stim.rings.distractor1.on = 0;
                    p.trial.stim.rings.distractor2.on = 0;
                    p.trial.stim.rings.distractor3.on = 0;
                
                % Implementing stimulus presentation
                case 1
                    p.trial.stim.rings.cue.on = 1;
                    p.trial.stim.rings.distractor1.on = 1;
                    p.trial.stim.rings.distractor2.on = 1;
                    p.trial.stim.rings.distractor3.on = 1;
                    
                otherwise
                    error('unusable stim value')
      
            end
            
            % Recording strat time of no stimulus presentation
            if(val == 0)
                ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');
                
            elseif(val == 1)
                ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');   
            end 
        end
        
        
        
    % Function to present stimuli on screen before orientation change
    function stimPreGratOriChange(p, val)
        
        % Checking if status of stimulus presentation is different from previous trial
        if(val ~= p.trial.task.stimState)
            % Updating status of stimulus presentation if different from previous trial 
            p.trial.task.stimState = val;
            
            % Turning stimulus presentation on/off based on stimulus presentation status
            switch val
                
                % Implementing no stimulus presentation
                case 0
                    p.trial.stim.gratings.preTarget.on = 0;
                    p.trial.stim.gratings.distractor1.on = 0;
                    p.trial.stim.gratings.distractor2.on = 0;
                    p.trial.stim.gratings.distractor3.on = 0;
                
                % Implementing stimulus presentation
                case 2
                    p.trial.stim.gratings.preTarget.on = 1;
                    p.trial.stim.gratings.distractor1.on = 1;
                    p.trial.stim.gratings.distractor2.on = 1;
                    p.trial.stim.gratings.distractor3.on = 1;
                    
                    p.trial.stim.gratings.preTarget.fixActive = 1;
                    p.trial.stim.gratings.distractor1.fixActive = 1;
                    p.trial.stim.gratings.distractor2.fixActive = 1;
                    p.trial.stim.gratings.distractor3.fixActive = 1;
                    
                otherwise
                    error('unusable stim value')
      
            end
            
            % Recording strat time of no stimulus presentation
            if(val == 0)
                ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');
                
            elseif(val == 2)
                ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');   
            end 
        end
        
        
        
    % Function to present stimuli on screen after orientation change
    function stimPostGratOriChange(p, val)
        
        % Checking if status of stimulus presentation is different from previous trial
        if(val ~= p.trial.task.stimState)
            % Updating status of stimulus presentation if different from previous trial 
            p.trial.task.stimState = val;
            % Turning stimulus presentation on/off based on stimulus presentation status
            switch val
                % Implementing no stimulus presentation
                case 0
                    p.trial.stim.gratings.postTarget.on = 0;
                
                % Implementing stimulus presentation
                case 3
                    p.trial.stim.gratings.postTarget.on = 1;
                    p.trial.stim.gratings.postTarget.fixActive = 1;

                otherwise
                    error('unusable stim value')     
            end
            
            % Recording strat time of no stimulus presentation
            if(val == 0)
                ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');
                
            elseif(val == 3)
                ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');
                
            end 
        end
             
                    
             










