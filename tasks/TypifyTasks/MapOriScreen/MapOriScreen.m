% John Amodeo, July 2024


%% RUN FUNCTION FOR TASK SESSION
function p = MapOriScreen(p, state)
    if(~exist('state','var'))
        state = [];
    end
    if(isempty(state))
        p = MapOriScreen_init(p);
    else
        p = ND_GeneralTrialRoutines(p, state);
        switch state
            case p.trial.pldaps.trialStates.trialSetup
                TaskSetUp(p);

            case p.trial.pldaps.trialStates.trialPrepare
                p.trial.EV.TrialStart = p.trial.CurTime;

            case p.trial.pldaps.trialStates.framePrepareDrawing 
                TaskDesign(p); 

            case p.trial.pldaps.trialStates.trialCleanUpandSave
                TaskCleanAndSave(p);   
        end
    end
    

%% FUNCTIONS FOR TASK STAGES
function TaskSetUp(p)
        % Establishing fix status of fix dot
        p.trial.task.fixFix = 0;
        % Establishing fix status of stim
        p.trial.task.stimFix = 0;
        % Establishing stim state for stim presentation
        p.trial.task.stimState = 0;
        
        % Creating fix spot
        p.trial.stim.fix = pds.stim.FixSpot(p);

        % Creating gabor
        oriRange = p.trial.task.oriRange;

        p.trial.stim.DRIFTGABOR.pos = [0, 0];
        p.trial.stim.DRIFTGABOR.size = [100, 100];
        p.trial.stim.DRIFTGABOR.radius = 500;
        disp(p.trial.Block.locIdx)
        p.trial.stim.DRIFTGABOR.angle = oriRange(p.trial.Block.locIdx);
        p.trial.stim.DRIFTGABOR.speed = 5;
        p.trial.stim.DRIFTGABOR.frequency = 1.5;
        p.trial.stim.DRIFTGABOR.contrast = 0.65;
        p.trial.stim.gabor = pds.stim.DriftGabor(p);

        if (p.trial.Block.locIdx == length(oriRange))
            p.trial.Block.locIdx = 1;
        else
            p.trial.Block.locIdx = p.trial.Block.locIdx + 1;
        end

        % Moving task from set-up stage to wait period before launching
        ND_SwitchEpoch(p, 'ITI');
    
        
% Function to execute task
function TaskDesign(p)
        switch p.trial.CurrEpoch
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
                if(p.trial.stim.fix.fixating) 
                    if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)
                        presentStim(p, 2);
                        p.trial.task.SRT_StimOn = p.trial.CurTime;
                        ND_SwitchEpoch(p, 'WaitReward')  
                    end   
                end
                
                % Checking if monkey has broken fixation
                if(~p.trial.stim.fix.fixating)
                    Task_Incorrect(p);
                end
                
            % Checking if fixation is maintained 
            case p.trial.epoch.WaitReward
                % Confirming monkey is still fixating
                if(p.trial.stim.fix.fixating)
                    % Jackpot time has not yet been reached
                    if (p.trial.CurTime < p.trial.task.SRT_StimOn + p.trial.task.presDur)

                        if (p.trial.reward.Continuous)
                            if (isnan(p.trial.EV.nextReward))
                                p.trial.EV.nextReward = p.trial.CurTime;
                            end
                        end
                        
                        % Reward if reward period has elapsed
                        if p.trial.CurTime >= p.trial.EV.nextReward
                            % Give reward
                            pds.reward.give(p, p.trial.reward.duration);
                            % Reset the reward timer
                            p.trial.EV.nextReward = p.trial.CurTime + p.trial.reward.Period;
                        end                            
                    else
                        % Monkey has fixated long enough to get the jackpot
                        Task_CorrectReward(p);
                    end

                % Checking if fixation has been broken    
                elseif(~p.trial.stim.fix.fixating)
                    Task_Incorrect(p);
                end

            % Starting task epoch that ends task
            case p.trial.epoch.TaskEnd
                % Running clean-up and storage routine before concluding trial
                Task_OFF(p);
                % Flagging completion of current trial so ITI is run before next trial
                p.trial.flagNextTrial = 1;
        end


%% SUPPORT FUNCTIONS
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
               p.trial.stim.gabor.on = 0;
               p.trial.stim.gabor.fixActive = 0;
            % Implementing stimulus (grat) presentation, both object on
            % screen and fixation window around it
            case 2
                p.trial.stim.gabor.on = 1;
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
    presentStim(p, 0);
    ND_FixSpot(p, 0);
    pds.audio.playDP(p,'jackpot','left');
    p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
    pds.reward.give(p, p.trial.reward.duration, p.trial.reward.jackpotnPulse);
    p.trial.EV.Reward = p.trial.CurTime;
    ND_SwitchEpoch(p, 'TaskEnd');

function p = Task_Incorrect(p)
    presentStim(p, 0);
    ND_FixSpot(p, 0);
    pds.audio.playDP(p, 'breakfix', 'left'); 
    p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
    if (p.trial.Block.locIdx == 1)
        p.trial.Block.locIdx = length(p.trial.task.oriRange);
    else
        p.trial.Block.locIdx = p.trial.Block.locIdx - 1;
    end
    ND_SwitchEpoch(p, 'TaskEnd');
            

% Function to clean up screen textures and variables, and to save data to 
% ascii table (ReportChange_init.m)
function TaskCleanAndSave(p)
    Task_Finish(p);
    p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};
    ND_Trial2Ascii(p, 'save');


