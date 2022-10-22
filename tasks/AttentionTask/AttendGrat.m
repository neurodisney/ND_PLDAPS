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
        end
    end



    % Function to gather materials to start trial
    function TaskSetUp(p)

        % Setting trial outcome to 'no start'
        % This will be true if fixation is not achieved 
        p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

        % Trial has not proven to be successful(1), till then it is incorrect(0)
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
        p.trial.stim.RING.contrast = p.trial.stim.ringParameters.cueContrast;
        %p.trial.stim.rings.cue = pds.stim.Ring(p);

        % Creating distractor ring 1 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        p.trial.stim.RING.pos = cell2mat(p.trial.stim.posList(2));
        p.trial.stim.RING.contrast = p.trial.stim.ringParameters.distractContrast;
        %p.trial.stim.rings.distractor1 = pds.stim.Ring(p);

        % Creating distractor ring 2 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        p.trial.stim.RING.pos = cell2mat(p.trial.stim.posList(3));
        p.trial.stim.RING.contrast = p.trial.stim.ringParameters.distractContrast;
        %p.trial.stim.rings.distractor2 = pds.stim.Ring(p);

        % Creating distractor ring 3 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        p.trial.stim.RING.pos = cell2mat(p.trial.stim.posList(4));
        p.trial.stim.RING.contrast = p.trial.stim.ringParameters.distractContrast;
        %p.trial.stim.rings.distractor3 = pds.stim.Ring(p);

        % Gathing random orientations for gratings
        p.trial.stim.gratingParameters.oriList = datasample(p.trial.task.gratingOriList, 5);

        % Create target grating pre-orientation change by assigning values to grating properties in p object
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
        
        % Selecting time of wait before stim change from flat hazard function
        p.trial.task.stimChangeWait = datasample(p.trial.task.flatHazard, 1); 

        % Taking control of activation of grating fix windows
        p.trial.stim.gratingParameters.targetAutoFixWin = 0;
        p.trial.stim.gratingParameters.distractorAutoFixWin =0;

        % Increasing Reward after specific number of correct trials
        reward_duration = find(p.trial.reward.IncrementTrial > p.trial.NHits + 1, 1, 'first');
        p.trial.reward.duration = p.trial.reward.IncrementDur(reward_duration);

        % Reducing current reward if previous trial was incorrect
        if(p.trial.LastHits == 0)
            p.trial.reward.duration = p.trial.reward.duration * p.trial.reward.DiscourageProp;
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

            % Starting trial
            case p.trial.epoch.TrialStart

                % Turning task on
                Task_ON(p);

                % Presenting fixation point
                ND_FixSpot(p, 1);

                % Recording start time of task
                p.trial.EV.TaskStart = p.trial.CurTime;
                p.trial.EV.TaskStartTime = datestr(now, 'HH:MM:SS:FFF');

                % Switching task to wait-for-fixation epoch
                ND_SwitchEpoch(p,'WaitFix');

            % Checking if fixation has been achieved within specific time window 
            case p.trial.epoch.WaitFix
                Task_WaitFixStart(p);

            % Checking that fixation held before presenting stimuli pre-orientation change    
            case p.trial.epoch.Fixating
                % Is monkey fixating at this point in task?
                if(p.trial.stim.fix.fixating)
                    % Are rings and gratings not on screen?
                    if(p.trial.task.stimState == 0)
                        % Is current time after presentation of fixation point?
                        if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)
                            % Presenting stimuli 
                            preChangeStim(p, 1)
                            ND_SwitchEpoch(p, 'WaitChange');  
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
            
            % Checking that fixation held before presenting stimuli pre-orientation change
            case p.trial.epoch.WaitChange
                % Is monkey still fixating at this point in task?
                if(p.trial.stim.fix.fixating)
                    % Are rings and gratings not on screen?
                    if(p.trial.task.stimState == 1)
                        % Is current time after presentation of fixation point?
                        if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)
                            % Presenting stimuli
                            counter = 0;
                            while counter < 30000
                                
                                Task_WaitFixStart(p);
                                disp(counter)
                                % Is monkey no longer fixating?
                                if(~p.trial.stim.fix.fixating)         
                                    break
                                elseif(p.trial.stim.fix.fixating)
                                    counter = counter + 1;  
                                end
                            end
                            
                            Task_WaitFixStart(p);
            
                            if(p.trial.stim.fix.fixating)
                                postChangeStim(p, 1);
                                ND_SwitchEpoch(p, 'WaitSaccade');
                                disp(1)
                            end
                        end 
                    end 
                end
                
                % Checking if monkey is still fixating
                %Task_WaitFixStart(p);

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
            
            % Beginning time period in which saccade to target must be performed
            case p.trial.epoch.WaitSaccade
               
                
                
        end


        
    % Function to present stimuli on screen before orientation change
    function preChangeStim(p, val)
        
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
                case 1
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
                
            elseif(val == 1)
                ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');
                
            end 
        end
        
        
        
    % Function to present stimuli on screen after orientation change
    function postChangeStim(p, val)
        
        % Checking if status of stimulus presentation is different from previous trial
        if(val == p.trial.task.stimState)
            % Updating status of stimulus presentation if different from previous trial 
            p.trial.task.stimState = val;
            % Turning stimulus presentation on/off based on stimulus presentation status
            switch val
                
                % Implementing no stimulus presentation
                case 0
                    p.trial.stim.gratings.postTarget.on = 0;
                
                % Implementing stimulus presentation
                case 1
                    p.trial.stim.gratings.postTarget.on = 1;
                    p.trial.stim.gratings.distractor1.on = 0;
                    p.trial.stim.gratings.postTarget.fixActive = 1;

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
             
                    
             










