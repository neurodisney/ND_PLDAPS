% Function to run task for experiment
function p = ReportChange(p, state)

    % Checking for task name and filling if empty
    if(~exist('state','var'))
        state = [];
    end
    
     % Initializing task
    if(isempty(state))
        % Populating pldaps structure with elements needed to begin task if empty
        p = ReportChange_init(p);

    else
        % If pldaps structure is populated, standard trial routines run
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
                TaskCleanAndSave(p);
                
        end
    end
    
    
% Function to gather materials to start trial
function TaskSetUp(p)

        % Adding trial to running trial count for block
        p.trial.Block.trialCount = p.trial.Block.trialCount + 1;

        % Flagging next block if max trial count reached
        if p.trial.Block.trialCount == p.trial.Block.maxBlockTrials
            p.trial.Block.flagNextBlock = 1;
            p.trial.Block.trialCount = 0;
            p.trial.Block.blockCount = p.trial.Block.blockCount + 1;
        end

        % Trial marked as incorrect(0) until it is done successfully(1)
        p.trial.task.Good = 0;
        % Creating spot to store selection of target stimulus
        p.trial.task.TargetSel = NaN;
        % Fixation has not yet been achieved(1), till then it is marked as absent(0)
        p.trial.task.fixFix = 0;
        % Tracking whether monkey is look at stim(1) or away from stim(0)
        p.trial.task.stimFix = 0;
        % Tracking whether stimuli are on(1) or off(0)
        p.trial.task.stimState = 0;
        % Creating place to save time when fixation started
        p.trial.task.SRT_FixStart = NaN;
        % Creating place to save time when stimuli came on screen
        p.trial.task.SRT_StimOn = NaN;

        % Generating fixation spot stimulus
        p.trial.stim.fix = pds.stim.FixSpot(p);

        % Shuffling positions in positions list
        p.trial.stim.posList = p.trial.task.posList(randperm(length(p.trial.task.posList)));

        % Assigning orientation change magnitude according to block
        if p.trial.Block.flagNextBlock == 1 || p.trial.NCompleted == 0 
            p.trial.Block.changeMag = datasample(p.trial.Block.changeMagList, 1);
            p.trial.Block.flagNextBlock = 0;
        end

        % Gathering random orientation for grating
        p.trial.stim.gratingParameters.ori = datasample(p.trial.task.oriList, 1);

        % Manipulating specific trial parameters for training purposes
        %p.trial.stim.gratingParameters.contrast(1) = datasample([0.85, 0.87, 0.90, 0.93, 0.95],1);
        %p.trial.task.sequence = datasample([0,1,1,1], 1);
        
        % Creating target grating pre-orientation change by assigning
        % values to grating properties in pldaps struct
        pos = cell2mat(p.trial.stim.posList(1));
%         p.trial.stim.GRATING.pos = pos([1 2]);
%         p.trial.stim.GRATING.contrast = p.trial.stim.gratingParameters.contrast(1);
%         p.trial.stim.GRATING.sFreq = p.trial.stim.gratingParameters.sFreq;
%         p.trial.stim.GRATING.ori = p.trial.stim.gratingParameters.ori;

        p.trial.stim.DRIFTGRAT.pos = pos([1 2]);
        p.trial.stim.DRIFTGRAT.size = 400;
        p.trial.stim.DRIFTGRAT.cycles_per_sec = 1;
        p.trial.stim.DRIFTGRAT.temp_f = 0.05;
        p.trial.stim.DRIFTGRAT.angle = 30;
        p.trial.stim.DRIFTGRAT.draw_mask = 0;

        % Compiling properties into pldaps struct to present grating on screen
%         p.trial.stim.gratings.preTarget = pds.stim.Grating(p);
        p.trial.stim.gratings.preTarget = pds.stim.DriftGrat(p);

        % Creating target grating post-orientation change by assigning
        % values to grating properties in pldaps struct
%         p.trial.stim.GRATING.pos = pos([1 2]);
%         p.trial.stim.GRATING.contrast = p.trial.stim.gratingParameters.contrast(2);
%         p.trial.stim.GRATING.ori = p.trial.stim.gratingParameters.ori + p.trial.Block.changeMag;
%         % Compiling properties into pldaps struct to present grating on screen
%         p.trial.stim.gratings.postTarget = pds.stim.Grating(p);

        % Setting wait before presenting fix point if trial presentation sequence is grat first and fix point second
        p.trial.task.StartWait.duration = 1;
        p.trial.task.StartWait.counter = 0;
        
        % Selecting time of wait before traget stimulus change from flat hazard function
        wait_period = datasample(p.trial.task.flatHazard, 1);
        p.trial.task.GratWait.duration = round(wait_period * 200);
        p.trial.task.GratWait.counter = 0;

        % Taking control of activation of grating fix windows
        p.trial.stim.gratingParameters.targetAutoFixWin = 0;

        % Increasing reward after specific number of correct trials
        reward_duration = find(p.trial.reward.IncrementTrial > p.trial.NHits + 1, 1, 'first');
        p.trial.reward.Dur = p.trial.reward.IncrementDur(reward_duration);

        % Reducing current reward if previous trial was incorrect
        if(p.trial.LastHits == 0)
            p.trial.reward.Dur = p.trial.reward.Dur * p.trial.reward.DiscourageProp;
        end

        % Moving task from set-up stage to wait period before launching
        ND_SwitchEpoch(p, 'ITI');
    
        
        
% Function to execute trial
function TaskDesign(p)

        % Command moving trial from epoch to epoch over course of trial
        switch p.trial.CurrEpoch

            % Implementing wait period between trials (inter-trial
            % interval)
            case p.trial.epoch.ITI
                Task_WaitITI(p);

            % Starting trial by presenting fix point
            case p.trial.epoch.TrialStart

                % Turning task on
                %Task_ON(p);

                % Lauching task sequence 1 (fix point then grat)
                if p.trial.task.sequence == 1

                    % Presenting fix spot
                    ND_FixSpot(p, 1);

                    % Recording start time of task
                    p.trial.EV.TaskStart = p.trial.CurTime;
                    p.trial.EV.TaskStartTime = datestr(now, 'HH:MM:SS:FFF');
                    
                    % Switching task to epoch checking for fixation
                    ND_SwitchEpoch(p,'WaitFix');

                % Launching task sequence 0 (grat then fix point)
                elseif p.trial.task.sequence == 0

                    % Presenting grating
                    stimPreGratOriChange(p, 2);

                    % Checking if wait period before fix point presentation
                    % is complete
                    if p.trial.task.StartWait.counter == p.trial.task.StartWait.duration

                        % Presenting fix spot
                        ND_FixSpot(p, 1);
                        p.trial.task.stimState = 0;

                        % Recording start time of task
                        p.trial.EV.TaskStart = p.trial.CurTime;
                        p.trial.EV.TaskStartTime = datestr(now, 'HH:MM:SS:FFF');

                        % Switching task to epoch requiring fixation
                        ND_SwitchEpoch(p,'WaitFix');

                    % Adding unit to counter tracking wait period before 
                    % fix point presentation   
                    else
                        p.trial.task.StartWait.counter = p.trial.task.StartWait.counter + 1; 
                    end

                end

            % Starting task epoch checking if fixation has been achieved 
            % within pre-set abount time 
            case p.trial.epoch.WaitFix
                Task_WaitFixStart(p);

            % Starting task epoch checking fix duration if fixation has 
            % been achieved 
            case p.trial.epoch.Fixating
                % Checking if monkey is contining to fixate
                if(p.trial.stim.fix.fixating)
                    % Setting stimulus state, which governs task flow, to 
                    % reflect fix point is being presented and monkey is 
                    % fixating
                    if(p.trial.task.stimState == 0)
                        % Checking if current time is after point at which 
                        % fixation started
                        if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)
                            % Presenting grating if task sequence 1 (fix
                            % point then grat)
                            if p.trial.task.sequence == 1
                                stimPreGratOriChange(p, 2);
                                % Marking time stimulus was presented
                                p.trial.Timer.stimOn = p.trial.CurTime;
                            % If task squence 0, stimulus state is updated
                            % to allow task to advance to next epoch
                            elseif p.trial.task.sequence == 0
                                p.trial.task.stimState = 2;
                            end
                            % Switching task to epoch in which stimulus
                            % changes in orientation after variable amount
                            % of time
                            ND_SwitchEpoch(p, 'WaitChange') 
                        end
                    end
                end
                
                % Checking if monkey has broken fixation
                if(~p.trial.stim.fix.fixating)         
                    % If fix broken, play noise signaling fix break
                    pds.audio.playDP(p, 'breakfix', 'left'); 
                    % Calculating and storing time from fix start to fix leave
                    p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                    % Calculating and storing time from presenting fix point to fix leave
                    p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - (p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency);
                    % Switching task epoch to address fix break before 
                    % ending trial
                    ND_SwitchEpoch(p, 'BreakFixCheck');
                end
                
            % Starting task epoch employing wait period before stimulus 
            % change if all stimuli presented and fixation is maintained
            case p.trial.epoch.WaitChange
                % Confirming monkey is still fixating
                if(p.trial.stim.fix.fixating)
                    % Checking fixation time against value selected from flat
                    % hazard function
                    if p.trial.task.GratWait.counter == p.trial.task.GratWait.duration
                        % Presenting stimulus change
                        stimPostGratOriChange(p, 3);
                        % Marking time of stimulus change
                        p.trial.Timer.stimChange = p.trial.CurTime;
                        % Switching task epoch to wait for response
                        ND_SwitchEpoch(p, 'WaitSaccade')
                    % Adding unit to counter tracking wait period before 
                    % stimulus change is presented
                    else
                        p.trial.task.GratWait.counter = p.trial.task.GratWait.counter + 1; 
                    end
                   
                % Checking if fixation has been broken    
                elseif(~p.trial.stim.fix.fixating)        
                        % If fix broken, play noise signaling fix break
                        pds.audio.playDP(p, 'breakfix', 'left'); 
                        % Calculating and storing time from fix start to fix leave
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Calculating and storing time from presenting fix point to fix leave
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - (p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency);
                        % Switching task epoch to address fix break before 
                        % ending trial
                        ND_SwitchEpoch(p, 'BreakFixCheck');
                end
               
            % Starting task epoch in which saccade to target must be performed
            case p.trial.epoch.WaitSaccade
                if(p.trial.CurTime > p.trial.EV.StimOn + p.trial.task.Timing.saccadeStart)
                    % Checking if gaze has left fix point
                    if(~p.trial.stim.fix.looking)

                        p.trial.Timing.flightTime.start = p.trial.CurTime;

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
                elseif (~p.trial.stim.fix.looking)
                    % If fix broken, play noise signaling fix break
                    pds.audio.playDP(p, 'breakfix', 'left'); 
                    % Calculating and storing time from fix start to fix leave
                    p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                    % Calculating and storing time from presenting fix point to fix leave
                    p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - (p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency);
                    % Switching task epoch to address fix break before 
                    % ending trial
                    ND_SwitchEpoch(p, 'BreakFixCheck');
                end
               
            % Starting task epoch checking respone if saacade was made    
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

                        p.trial.Timing.flightTime.total = p.trial.CurTime - p.trial.Timing.flightTime.start;
                        
                    % Verifying if gaze shifted from fix spot but no grating selected    
                    elseif(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + p.trial.task.breakFixCheck)
                        % Marking trail as 'No Fix' on Target
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
                        % Switch back to task epoch checking for response
                        ND_SwitchEpoch(p, 'WaitSaccade');
                    end
                    
                else
                    % Checking if fix on target held for pre-set amount of time 
                    if(p.trial.CurTime > p.trial.stim.gratings.postTarget.EV.FixStart + p.trial.task.minTargetFixTime)
                        % If so, marking trial as correct and dispensing
                        % reward
                        Task_CorrectReward(p);
                    
                    % Checking if gaze leaves target grating fix window
                    elseif(~p.trial.stim.gratings.postTarget.fixating)
                        % Marking trial as 'Target Break'
                        p.trial.outcome.CurrOutcome = p.trial.outcome.TargetBreak;
                        % Playing noise signaling breaking fix from target
                        pds.audio.playDP(p, 'incorrect', 'left');
                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                    end
                end
                     
            % Starting task epoch checking fix breaks 
            case p.trial.epoch.BreakFixCheck
                delay = p.trial.task.breakFixCheck;
                % Checking if fix break was committed before stimuli (grat)
                % presented
                if(p.trial.task.stimState < 1)
                    % If so, marking trial as fix break
                    p.trial.outcpme.CurrOutcome = p.trial.outcome.FixBreak;
                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');
                    
                % Checking if fix break committed after stimuli presented, 
                % and if saccade was pre-mature response (i.e., before grat 
                % change)     
                elseif(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + delay)
                    % Collecting screen frames from fix break to check median eye position
                    frames = ceil(p.trial.display.frate * delay);
                    % Calculating median position of eyes across frames
                    medPos = prctile([p.trial.eyeX_hist(1:frames)', p.trial.eyeY_hist(1:frames)'], 50);
                    
                    % Checking if median eye position is in fixation window of target 
                    if(inFixWin(p.trial.stim.gratings.postTarget, medPos))
                        % Marking trial as "hit" but early if eye position is in target fix window
                        p.trial.outcome.CurrOutcome = p.trial.outcome.Early;
                        % Flagging trial if early response made, which in turn
                        % increases inter-trial interval
                        p.defaultParameters.earlyFlag = 1;
                    else
                        % Marking trial as fix break without relevance to task
                        p.trial.outcome.CurrOutcome = p.trial.outcome.StimBreak;
                        % Flagging trial if break response made, which in turn
                        % increases inter-trial interval
                        p.defaultParameters.breakFlag = 1;
                        
                    end 
                    
                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');
                
                end
                
            % Starting task epoch consisting of wait period before turning 
            % off all stimuli 
            case p.trial.epoch.WaitEnd
                % Checking if current time greater than pre-set delay
                % before task end
                if(p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.Timing.WaitEnd)
                    % Storing actual wait period time
                    p.trial.Timer.Wait = p.trial.Timer.stimChange - p.trial.Timer.stimOn;

                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');
                end

            % Starting task epoch that ends task
            case p.trial.epoch.TaskEnd
                
                % Turning gratings off
                stimPreGratOriChange(p, 0);
                stimPostGratOriChange(p, 0);
                
                % Turning fix point off
                ND_FixSpot(p, 0);
                
                % Running clean-up and storage routine before concluding trial
                Task_OFF(p);
                
                % Updating target fix start and target fix break times if 
                % they are empty
                if(~isnan(p.trial.stim.gratings.postTarget.EV.FixStart))
                    p.trial.EV.FixStimStart = p.trial.stim.gratings.postTarget.EV.FixStart;
                    p.trial.EV.FixStimStop = p.trial.stim.gratings.postTarget.EV.FixBreak;
                end 
                
                % Flagging completion of current trial so ITI is run before next trial
                p.trial.flagNextTrial = 1;
        end
       
        
% Function to present stimuli on screen
function stimPreGratOriChange(p, val)
        
        % Checking if stimulus status, which reflects stage of stimulus
        % presentation (i.e., what is on the screen and what is not), is 
        % different from previous trial
        if(val ~= p.trial.task.stimState)
            % Updating stimulus status if so
            p.trial.task.stimState = val;
            
            % Turning stimulus presentation on/off based on stimulus presentation status
            switch val
                
                % Implementing no stimulus (grat) presentation
                case 0
                    p.trial.stim.gratings.preTarget.on = 0;
                
                % Implementing stimulus (grat) presentation, both object on
                % screen and fixation window around it
                case 2
                    p.trial.stim.gratings.preTarget.on = 1;                  
                    p.trial.stim.gratings.preTarget.fixActive = 1;
                
                % Error thrown if neither case designated
                otherwise
                    error('unusable stim value')
      
            end
            
            % Recording start time of present/absent stimulus presentation
            if(val == 0)
                ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');    
            elseif(val == 2)
                ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');
            end 

        end
        
        
% Function to present stimulus change on screen
function stimPostGratOriChange(p, val)
        
        % Checking if stimulus status, which reflects stage of stimulus
        % presentation (i.e., what is on the screen and what is not), is 
        % different from previous trial
        if(val ~= p.trial.task.stimState)
            % Updating stimulus status if so
            p.trial.task.stimState = val;

            % Turning stimulus presentation on/off based on stimulus presentation status
            switch val
                % Implementing no stimulus (grat) change presentation
                case 0
                    p.trial.stim.gratings.postTarget.on = 0;
                
                % Implementing stimulus (grat) change presentation, both 
                % object on screen and fixation window around it
                case 3
                    % Turning pre-change version off
                    p.trial.stim.gratings.preTarget.on = 0;
    
                    % Turning post-change verion on
                    p.trial.stim.gratings.postTarget.on = 1;
                    p.trial.stim.gratings.postTarget.fixActive = 1;

                % Error thrown if neither case designated
                otherwise
                    error('unusable stim value')     
            end
            
            % Recording start time of present/absent stimulus change 
            % presentation
            if(val == 0)
                ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');   
            elseif(val == 3)
                ND_AddScreenEvent(p, p.trial.event.STIM_CHNG, 'StimChange'); 
            end 

        end
         
        
% Function to mark trial correct and dispense reward        
function p = Task_CorrectReward(p)
    % Marking trial outcome as correct
    p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
    p.trial.task.Good = 1;

    % Dispensing reward
    pds.reward.give(p, p.trial.reward.Dur);

    % Playing audio signaling correct trial
    pds.audio.playDP(p, 'reward', 'left');

    % Record time at which reward given
    p.trial.EV.Reward = p.trial.CurTime;

    % Switching epoch to end task
    ND_SwitchEpoch(p, 'WaitEnd');
             
         
% Function to clean up screen textures and variables, and to save data to 
% ascii table (ReportChange_init.m)
function TaskCleanAndSave(p)
            
            % Saving key variables
            Task_Finish(p);
            
            % Trial outcome saved as event code and converted to str for
            % ascii table loading
            p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};
            
            % Loading data into ascii table for export and analysis
            ND_Trial2Ascii(p, 'save');
