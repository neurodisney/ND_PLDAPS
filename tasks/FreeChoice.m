% John Amodeo, 2023


% Function to run task for experiment
function p = FreeChoice(p, state)


    % Checking for task name and filling if empty
    if(~exist('state','var'))
        state = [];
    end
    

     % Initializing task
    if(isempty(state))

        % Populating pldaps object with elements needed to begin task if empty
        p = FreeChoice_init(p);

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
                TaskCleanAndSave(p);
                
        end

    end
    


    
% Function to gather materials to start trial   
function TaskSetUp(p)


        % Adding trial to running total for block
        p.trial.Block.trialCount = p.trial.Block.trialCount + 1;

        % Flagging next block if max trial count reached
        if p.trial.Block.trialCount == p.trial.Block.maxBlockTrials
            p.trial.Block.flagNextBlock = 1;
            p.trial.Block.trialCount = 0;
            p.trial.Block.blockCount = p.trial.Block.blockCount + 1;
        end
        

        % Altering task parameters if new block has started
        if p.trial.Block.flagNextBlock == 1 || p.trial.NCompleted == 0
            
            % Switching probability assignments between stimuli
            if p.trial.task.probSwitch
                p.trial.stim.recParameters.probabilities = p.trial.stim.recParameters.probabilities(randperm(length(p.trial.stim.recParameters.probabilities)));
            end

            % Changing color in which stimuli are presented
            if p.trial.task.colorSwitch
                p.defaultParameters.colorIndex = p.defaultParameters.colorIndex + 1;
                if p.defaultParameters.colorIndex > size(p.trial.stim.recParameters.colors.list)
                    p.defaultParameters.colorIndex = 1;
                end
            end
                
            p.trial.Block.flagNextBlock = 0;
            %p.trial.Block.rewardDurs = datasample(p.trial.stim.recParameters.rewardDurs, 2);
        end
        

        % Increasing reward after specific number of correct trials
        reward_duration = find(p.trial.reward.IncrementTrial > p.trial.NHits + 1, 1, 'first');
        p.trial.reward.Dur = p.trial.reward.IncrementDur(reward_duration);

        % Reducing current reward if previous trial was incorrect
%         if(p.trial.LastHits == 0)
%             p.trial.reward.Dur = p.trial.reward.Dur * p.trial.reward.DiscourageProp;
%         end
        

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
        

        % Creating stim 1 by assigning values to rec properties in p object
        % Compiling properties into pldaps struct to present rectangle on screen
        p.trial.stim.RECTANGLE.pos = [-5,0];
        p.trial.stim.RECTANGLE.color = char(p.trial.stim.recParameters.colors.list(p.defaultParameters.colorIndex));
        p.trial.stim.recParameters.stim1.color = char(p.trial.stim.recParameters.colors.list(p.defaultParameters.colorIndex));
        p.trial.stim.RECTANGLE.coordinates = p.trial.stim.recParameters.stim1.coordinates;
        if (p.trial.task.condition == 1)
            p.trial.stim.RECTANGLE.reward = randsample([1, 0], 1, true, p.trial.stim.recParameters.probabilities);
        elseif (p.trial.task.condition == 2)
            p.trial.stim.RECTANGLE.reward = 1;
        end
        p.trial.stim.recParameters.stim1.rewardDur = p.trial.stim.recParameters.rewardDurs(1);
        p.trial.stim.stim1 = pds.stim.Rectangle(p);
        

        % Creating stim 2 by assigning values to rec properties in p object
        % Compiling properties into pldaps struct to present rectangle on screen
        p.trial.stim.RECTANGLE.pos = [5,0];
        p.trial.stim.recParameters.stim2.color = char(p.trial.stim.recParameters.colors.list(p.defaultParameters.colorIndex));
        p.trial.stim.RECTANGLE.coordinates = p.trial.stim.recParameters.stim2.coordinates;
        if (p.trial.task.condition == 1)
            p.trial.stim.RECTANGLE.reward = randsample([0, 1], 1, true, p.trial.stim.recParameters.probabilities);
        elseif (p.trial.task.condition == 2)
            p.trial.stim.RECTANGLE.reward = 1;
        end
        p.trial.stim.recParameters.stim2.rewardDur = p.trial.stim.recParameters.rewardDurs(2);
        p.trial.stim.stim2 = pds.stim.Rectangle(p);


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
                
            % Presenting stimuli if fixation held
            case p.trial.epoch.Fixating

                % Is monkey fixating at this point in task?
                if(p.trial.stim.fix.fixating)

                    % Checking if stimuli have been presented
                    if(p.trial.task.stimState == 0)

                        % If stimuli have not been presented, checking if
                        % monkey has fixated for pre-set amount
                        if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)

                            % Presenting gratings
                            presentStim(p, 1);

                            % Switching epoch to wait for response
                            ND_SwitchEpoch(p, 'WaitSaccade') 

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

            % Checking if saacade response made was to stimulus    
            case p.trial.epoch.CheckResponse

                % Confirming current gaze shift is first response made
                if(~p.trial.task.stimFix)

                    % Checking if gaze specifically within stim 1 fix window
                    if(p.trial.stim.stim1.fixating)

                        % Logging selection of stimulus
                        p.trial.task.TargetSel = 'stim1';
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        
                        % Checking if fix on target held for pre-set minimum amount of time 
                        if(p.trial.CurTime > p.trial.stim.stim1.EV.FixStart + p.trial.task.minTargetFixTime)

                            % Checking if selected stimulus is rewarded
                            if (p.trial.stim.stim1.reward)

                                % If so, marking trial as correct and dispensing
                                % reward
                                Task_CorrectReward(p);

                            else
                                % Marking trial as incorrect
                                p.trial.outcome.CurrOutcome = p.trial.outcome.False;

                                % Playing noise signaling inccorect selection made
                                pds.audio.playDP(p, 'incorrect', 'left');

                                % Switching epoch to end task 
                                ND_SwitchEpoch(p, 'TaskEnd');

                            end

                        end
                        
                    % Checking if gaze specifically within stim 2 fix window
                    elseif(p.trial.stim.stim2.fixating)

                        % Logging selection of stimulus
                        p.trial.task.TargetSel = 'stim2';
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        
                        % Checking if fix on target held for pre-set minimum amount of time 
                        if(p.trial.CurTime > p.trial.stim.stim2.EV.FixStart + p.trial.task.minTargetFixTime)
                            
                            % Checking if selected stimulus is rewarded
                            if (p.trial.stim.stim2.reward)

                                % If so, marking trial as correct and dispensing
                                % reward
                                Task_CorrectReward(p);

                            else

                                % Marking trial as incorrect
                                p.trial.outcome.CurrOutcome = p.trial.outcome.False;

                                % Playing noise signaling inccorect selection made
                                pds.audio.playDP(p, 'incorrect', 'left');

                                % Switching epoch to end task 
                                ND_SwitchEpoch(p, 'TaskEnd');

                            end

                        end
                        
                    % Checking if fixation on target broken before amount 
                    % required for target fix
                    elseif(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + p.trial.task.breakFixCheck)

                        % If so, marking trail as No Fix on Target
                        p.trial.outcome.CurrOutcome = p.trial.outcome.NoTargetFix;

                        % Playing noise signaling no selection made
                        pds.audio.playDP(p, 'incorrect', 'left');

                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;

                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                    
                    % Checking if gaze returned to fix point after fix 
                    % break in time to be considered 'no response yet'    
                    elseif(p.trial.stim.fix.looking)

                        % Switching epoch to continue waiting for response
                        ND_SwitchEpoch(p, 'WaitSaccade');

                    end 

                end
                             
            % Checking if fixation was broken pre-maturely    
            case p.trial.epoch.BreakFixCheck

                % Storing time window estimated for flight time to 
                % determine if early sacccade to target made
                delay = p.trial.task.breakFixCheck;

                % Checking if current time exceeds estimated flight time
                if(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + delay)

                    % Collecting screen frames for trial to check median 
                    % eye position
                    frames = ceil(p.trial.display.frate * delay);
                    % Calculating median position of eyes across frames
                    medPos = prctile([p.trial.eyeX_hist(1:frames)', p.trial.eyeY_hist(1:frames)'], 50);
                    
                    % Checking if median eye position is in fixation 
                    % window of stim 1
                    if(inFixWin(p.trial.stim.stim1, medPos))

                        % Checking if selected stimulus rewarded
                        if (p.trial.stim.rewardedStim == 1)

                            % Marking trial as "hit" but early if eye 
                            % position is in stim fix window
                            p.trial.outcome.CurrOutcome = p.trial.outcome.Early;

                        else

                            % Marking trial as early and false if eye 
                            % position is in stim fix window
                            p.trial.outcome.CurrOutcome = p.trial.outcome.EarlyFalse;

                        end
                    
                    % Checking if median eye position is in fixation 
                    % window of stim 2
                    elseif(inFixWin(p.trial.stim.stim2, medPos))

                        % Checking if selected stimulus rewarded
                        if (p.trial.stim.rewardedStim == 2)

                            % Marking trial as "hit" but early if eye 
                            % position is in stim fix window
                            p.trial.outcome.CurrOutcome = p.trial.outcome.Early;

                        else

                            % Marking trial as early and false if eye 
                            % position is in stim fix window
                            p.trial.outcome.CurrOutcome = p.trial.outcome.EarlyFalse;

                        end
               
                    else

                        % Marking trial as fix break without relevance 
                        % to task
                        p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;

                    end 
                    
                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');
                
                end
                
            % Wait period before turning off all stimuli 
            case p.trial.epoch.WaitEnd

                % Checking if wait period completed
                if(p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.Timing.WaitEnd)

                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');

                end

            % Ending task
            case p.trial.epoch.TaskEnd

                % Turning stimuli off
                presentStim(p, 0);
                
                % Turning fix point off
                ND_FixSpot(p, 0);
                
                % Running clean-up and storage routine before concluding 
                % trial
                Task_OFF(p);
                
                % Checking if there is NaN value for start/stop of 
                % fixation on stim 1 and filling them with other stored 
                % times
                if(~isnan(p.trial.stim.stim1.EV.FixStart))
                    p.trial.EV.FixStimStart = p.trial.stim.stim1.EV.FixStart;
                    p.trial.EV.FixStimStop = p.trial.stim.stim2.EV.FixBreak;
                    
                % Checking if there is NaN value for start/stop of 
                % fixation on stim 2 and filling them with other stored 
                % times    
                elseif(~isnan(p.trial.stim.stim2.EV.FixStart))
                    p.trial.EV.FixStimStart = p.trial.stim.stim1.EV.FixStart;
                    p.trial.EV.FixStimStop = p.trial.stim.stim2.EV.FixBreak;

                end 
                
                % Flagging completion of current trial so ITI is run 
                % before next trial
                p.trial.flagNextTrial = 1;
               

        end
        



% Function to present stimuli on screen before orientation change
function presentStim(p, val)
        

        % Checking if status of stimulus presentation is different from 
        % previous trial
        if(val ~= p.trial.task.stimState)

            % Updating status of stimulus presentation if different from 
            % previous trial 
            p.trial.task.stimState = val;
            
            % Turning stimulus presentation on/off based on stimulus 
            % presentation status
            switch val
                
                % Implementing no stimulus presentation
                case 0
                    p.trial.stim.stim1.on = 0;
                    p.trial.stim.stim2.on = 0;
                
                % Implementing stimulus presentation
                case 1
                    p.trial.stim.stim1.on = 1;
                    p.trial.stim.stim2.on = 1;
                    
                    p.trial.stim.stim1.fixActive = 1;
                    p.trial.stim.stim2.fixActive = 1;
  
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
        


        
% Function to clean up screen textures and variables and to save data to 
% ascii table (FreeChoice_init.m)
function TaskCleanAndSave(p)
            
            % Saving key variables
            Task_Finish(p);
            
            % Trial outcome saved as code, and this is converting it to 
            % str name
            p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};
            
            % Loading data into ascii table for plotting
            ND_Trial2Ascii(p, 'save');
