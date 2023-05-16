% John Amodeo, May 2023

% Function to run task for experiment
function p = ConRes(p, state)

    % Checking for task name and filling if empty
    if(~exist('state','var'))
        state = [];
    end
    
     % Initializing task
    if(isempty(state))
        % Populating pldaps structure with elements needed to begin task if empty
        p = ConRes_init(p);

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


        % Trial marked as incorrect(0) until it is done successfully(1)
        p.trial.task.Good = 0;
        % Creating spot to store selection of target stimulus
        p.trial.task.TargetSel = NaN;
        % Fixation has not yet been achieved(1), till then it is marked as 
        % absent(0)
        p.trial.task.fixFix = 0;
        % Tracking whether monkey is look at stim(1) or away from stim(0)
        p.trial.task.stimFix = 0;
        % Tracking whether stimuli are on(1) or off(0)
        p.trial.task.stimState = 0;
        % Creating place to save time from fix start to fix leave
        p.trial.task.SRT_FixStart = NaN;
        % Creating place to save time when stimuli came on screen
        p.trial.task.SRT_StimOn = NaN;

        % Generating fixation spot stimulus
        p.trial.stim.fix = pds.stim.FixSpot(p);

        
        % Creating distractor ring 1 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        pos = [4,4];
        p.trial.stim.RING.pos = pos;
        p.trial.stim.RING.color = char(datasample(p.trial.task.upConRange, 1, 'Replace', false));
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.ring = pds.stim.Ring(p);
        

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
                Task_ON(p);

                % Presenting fix spot
                ND_FixSpot(p, 1);

                % Recording start time of task
                p.trial.EV.TaskStart = p.trial.CurTime;
                p.trial.EV.TaskStartTime = datestr(now, 'HH:MM:SS:FFF');
                
                % Switching task to epoch checking for fixation
                ND_SwitchEpoch(p,'WaitFix');

            % Starting task epoch checking if fixation has been achieved 
            % within pre-set abount time 
            case p.trial.epoch.WaitFix

                Task_WaitFixStart(p);

            % Starting task epoch checking fix duration if fixation has 
            % been achieved 
            case p.trial.epoch.Fixating

                % Checking if monkey is contining to fixate
                if(p.trial.stim.fix.fixating)
                    % Checking if current time is pre-set amount after 
                    % point at which fixation started
                    if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)
                        % Presenting ring
                        presentStim(p, 2);
                        % Marking time stimulus was presented
                        p.trial.task.SRT_StimOn = p.trial.CurTime;

                        % Switching task to epoch in which stimulus
                        % changes in orientation after variable amount
                        % of time
                        ND_SwitchEpoch(p, 'WaitReward')  
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
                    % Marking trial as fix break
                    p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                    % Switching task epoch to address fix break before 
                    % ending trial
                    ND_SwitchEpoch(p, 'TaskEnd');
                end
                
            % Starting task epoch employing wait period before stimulus 
            % change if all stimuli presented and fixation is maintained
            case p.trial.epoch.WaitReward

                % Confirming monkey is still fixating
                if(p.trial.stim.fix.fixating)
                    % Checking fixation time against value selected from flat
                    % hazard function
                    if (p.trial.CurTime > p.trial.task.SRT_StimOn + p.trial.task.presDur)
                        Task_CorrectReward(p);
                    end

                % Checking if fixation has been broken    
                elseif(~p.trial.stim.fix.fixating)        
                        % If fix broken, play noise signaling fix break
                        pds.audio.playDP(p, 'breakfix', 'left'); 
                        % Calculating and storing time from fix start to fix leave
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Calculating and storing time from presenting fix point to fix leave
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - (p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency);
                        % Marking trial as fix break
                        p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                        % Switching task epoch to address fix break before 
                        % ending trial
                        ND_SwitchEpoch(p, 'TaskEnd');
                end
                
            % Starting task epoch consisting of wait period before turning 
            % off all stimuli 
            case p.trial.epoch.WaitEnd

                % Checking if current time greater than pre-set delay
                % before task end
                if(p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.Timing.WaitEnd)

                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');

                end

            % Starting task epoch that ends task
            case p.trial.epoch.TaskEnd
                
                % Turning gratings off
                presentStim(p, 0);
                
                % Turning fix point off
                ND_FixSpot(p, 0);
                
                % Running clean-up and storage routine before concluding trial
                Task_OFF(p);
                
                % Flagging completion of current trial so ITI is run before next trial
                p.trial.flagNextTrial = 1;
        end
       
        


% Function to present stimuli on screen
function presentStim(p, val)
        
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
                   p.trial.stim.ring.on = 0;
                   p.trial.stim.ring.fixActive = 0;
                
                % Implementing stimulus (grat) presentation, both object on
                % screen and fixation window around it
                case 2
                    p.trial.stim.ring.on = 1;
                    p.trial.stim.ring.fixActive = 0;
                
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


