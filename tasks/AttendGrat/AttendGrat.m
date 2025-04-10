% John Amodeo, May 2023


%% RUN FUNCTION FOR TASK SESSION
function p = AttendGrat(p, state)

    % Check for task name, fill if empty
    if(~exist('state','var'))
        state = [];
    end

    %% Below is the framework used for the task
        % The task parameters are loaded and the task is flip through
        % the following series of states: task setup for equipment syncs,
        % trial setup to log the start time of each trial,
        % task design to loop over each epoch of the task within trials,
        % and task clean and save to save the data from the previous trial
        % and clean things up in preparation for the next one.
        % NOTE: a 'struct' is a nested matrix

    % Populating empty p struct with info needed to begin task
    if(isempty(state))
        p = AttendGrat_init(p);
    else
        % General info needed for all tasks loaded in p struct with general
        % trial routines function
        p = ND_GeneralTrialRoutines(p, state);
        % Flipping through epochs (cases) that make up trial based on state
        switch state
            % Loading info specific to this task in p struct with function
            case p.trial.pldaps.trialStates.trialSetup
                TaskSetUp(p); % DEFINED BELOW  
            % Marking trial start time based on current time    
            case p.trial.pldaps.trialStates.trialPrepare
                p.trial.EV.TrialStart = p.trial.CurTime;
            % Passing p struct into function to flip through trial epochs     
            case p.trial.pldaps.trialStates.framePrepareDrawing 
                TaskDesign(p); % DEFINED BELOW
            % Cleaning up info used for trial and saving data
            case p.trial.pldaps.trialStates.trialCleanUpandSave
                TaskCleanAndSave(p); % DEFINED BELOW
        end
    end


%% FUNCTIONS FOR TASK STAGES
% This function loads info specific to this task in p struct
function TaskSetUp(p)

        % Adding trial to running total for block
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
        p.trial.task.StimSel = [NaN, NaN];
        % Fixation has not yet been achieved(1), till then is marked as absent(0)
        p.trial.task.fixFix = 0;
        % Tracking whether monkey is look at stim(1) or away from stim(0)
        p.trial.task.stimFix = 0;
        % Tracking whether stimuli are on(1) or off(0)
        p.trial.task.stimState = 0;
        % Creating place to save when fixation started
        p.trial.task.SRT_FixStart = NaN;
        % Creating place to save time when stimuli came on screen
        p.trial.task.SRT_StimOn = NaN;
        % Creating space to save time taken for saccade 
        p.trial.task.FlightTime = NaN;
        % Creating space to save time when cued presented  
        p.trial.task.CueOn = NaN;
        % Creating space to save time when gratings presented 
        p.trial.task.GratOn = NaN;
        % Creating space to save magnitude of grating change 
        p.trial.task.changeMag = NaN;
        % Creating space to save task condition (cued = 1, uncued = 0)
        p.trial.task.cued = NaN;
        % Flagging trial as repeat of blown trial
        p.trial.task.blown_repeat = 0;
        
        p.trial.task.trialConfig = {};

        % Generating fixation spot stimulus
        p.trial.stim.fix = pds.stim.FixSpot(p);
        

        % Randomly selecting stimulus arrangement
        % Shuffling stim positions for certain arrangements
        rng('shuffle', 'twister')
        posIndex = datasample([1, 2, 3, 4, 5, 6, 7], 1); 
        posList = p.trial.task.posList(posIndex, :);
        p.trial.task.trialConfig = [p.trial.task.trialConfig posList];

        % Randomly selecting orientations for gratings
        oriList = p.trial.task.oriList;
        rng('shuffle', 'twister')
        oriList = oriList(randperm(length(oriList)));
        p.trial.task.trialConfig = [p.trial.task.trialConfig oriList];

        % Randomly selecting task condition (cued = 1 or uncued = 0)
        rng('shuffle', 'twister')
        p.trial.task.cued = datasample(p.trial.task.cued_ratio, 1);

        if p.trial.task.cued
            rng('shuffle', 'twister')
            p.trial.task.changeMag = datasample(p.trial.Block.cuedMagList, 1);
        else
            rng('shuffle', 'twister')
            p.trial.task.changeMag = datasample(p.trial.Block.uncuedMagList, 1);
        end
        
        p.trial.task.trialConfig = [p.trial.task.trialConfig p.trial.task.cued];
        p.trial.task.trialConfig = [p.trial.task.trialConfig p.trial.task.changeMag];
  
        
        % Checking for blown trials and mixing them in
        if ~isempty(p.defaultParameters.blownTrials)
            rng('shuffle', 'twister')
            mix_in = datasample(p.trial.task.shuffleRange, 1);
            blown_trial = p.defaultParameters.blownTrials(1, :);
            
            if mix_in
                posList = blown_trial([1 2 3 4]);
                oriList = cell2mat(blown_trial(5));
                p.trial.task.cued = cell2mat(blown_trial(6));
                p.trial.task.changeMag = cell2mat(blown_trial(7));
                p.trial.task.blown_repeat = 1;  
            end

            p.defaultParameters.mixList = [p.defaultParameters.mixList mix_in];
        end
                
        
        % Creating cue ring by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        idxRange = [1, 2, 3, 4];

        if p.trial.task.cued
            p.trial.stim.RING.color = p.trial.stim.ringParameters.cueCon;
            rng('shuffle', 'twister')
            posIdx = datasample([2, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1, 3, 3, 4], 1);
            idxRange(idxRange == posIdx) = [];
        else
            p.trial.stim.RING.color = p.trial.stim.ringParameters.distCon;
            rng('shuffle', 'twister')
            posIdx = datasample([2, 1, 4, 3], 1);
            idxRange(idxRange == posIdx) = [];
        end

        TargPos = cell2mat(posList(posIdx));
        p.trial.stim.RING.pos = TargPos([1 2]);
        p.trial.stim.RING.contrast = p.trial.display.clut.(p.trial.stim.RING.color);
        p.trial.stim.rings.cue = pds.stim.Ring(p);

        % Creating distractor ring 1 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        Dis1Pos = cell2mat(posList(idxRange(1)));
        p.trial.stim.RING.pos = Dis1Pos([1 2]);
        p.trial.stim.RING.color = p.trial.stim.ringParameters.distCon;
        p.trial.stim.RING.contrast = p.trial.display.clut.(p.trial.stim.RING.color);
        p.trial.stim.rings.distractor1 = pds.stim.Ring(p);

        % Creating distractor ring 2 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        Dis2Pos = cell2mat(posList(idxRange(2)));
        p.trial.stim.RING.pos = Dis2Pos([1 2]);
        p.trial.stim.rings.distractor2 = pds.stim.Ring(p);

        % Creating distractor ring 3 by assigning values to ring properties in p object
        % Compiling properties into pldaps struct to present ring on screen
        Dis3Pos = cell2mat(posList(idxRange(3)));
        p.trial.stim.RING.pos = Dis3Pos([1 2]);
        p.trial.stim.rings.distractor3 = pds.stim.Ring(p);
        
        
        % Creating target grating pre-orientation change by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.DRIFTGABOR.pos = TargPos([1 2]);
        p.trial.stim.DRIFTGABOR.angle = oriList(1);
        p.trial.stim.DRIFTGABOR.speed = p.trial.stim.gaborParameters.tFreq;
        p.trial.stim.DRIFTGABOR.frequency = p.trial.stim.gaborParameters.sFreq;
        p.trial.stim.DRIFTGABOR.contrast = p.trial.stim.gaborParameters.contrast;
        p.trial.stim.gabors.preTarget = pds.stim.DriftGabor(p);

        % Creating target grating post-orientation change by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.DRIFTGABOR.pos = TargPos([1 2]);
        p.trial.stim.DRIFTGABOR.angle = oriList(1) + p.trial.task.changeMag;
        p.trial.stim.gabors.postTarget = pds.stim.DriftGabor(p);

        % Creating distractor grating 1 by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.DRIFTGABOR.pos = Dis1Pos([1 2]);
        p.trial.stim.DRIFTGABOR.angle = oriList(2);
        p.trial.stim.gabors.distractor1 = pds.stim.DriftGabor(p);

        % Creating distractor grating 2 by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.DRIFTGABOR.pos = Dis2Pos([1 2]);
        p.trial.stim.DRIFTGABOR.angle = oriList(3);
        p.trial.stim.gabors.distractor2 = pds.stim.DriftGabor(p);

        % Creating distractor grating 3 by assigning values to grating properties in p object
        % Compiling properties into pldaps struct to present grating on screen
        p.trial.stim.DRIFTGABOR.pos = Dis3Pos([1 2]);
        p.trial.stim.DRIFTGABOR.angle = oriList(4);
        p.trial.stim.gabors.distractor3 = pds.stim.DriftGabor(p);
        
        
        % Selecting time of wait before target grating change from flat hazard function
        p.trial.task.GratWait = datasample(p.trial.task.flatHazard, 1);

        % Taking control of activation of grating fix windows
        p.trial.stim.gratingParameters.targetAutoFixWin = 0;
        p.trial.stim.gratingParameters.distractorAutoFixWin = 0;

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

            % Implementing wait period to ensure enough time has passed 
            % since previous trial 
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


            % Checking if fixation has been achieved within pre-set amount 
            % of time 
            case p.trial.epoch.WaitFix

                Task_WaitFixStart(p);


            % Checking if animal is in fix window
            case p.trial.epoch.Fixating
                % Checking if animal is fixating on fix spot
                if(p.trial.stim.fix.fixating)
                    % Checking phase of trial
                    if(p.trial.task.stimState == 0)
                        ND_AddScreenEvent(p, p.trial.event.FIXSPOT_FIX, 'fixspotFix');
                        % Is current time after presentation of fix point?
                        if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)
                            % Presenting rings
                            stimRings(p, 1)
                            p.trial.task.CueOn = p.trial.CurTime;

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
                    % Dispensing reward
                    pds.reward.give(p, 0.005);

                    if(p.trial.CurTime > p.trial.task.CueOn + p.trial.task.CueWait)
                        stimPreGratOriChange(p, 2);
                        p.trial.task.GratOn = p.trial.CurTime;
                        ND_SwitchEpoch(p, 'WaitChange')   
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

                    if (p.trial.CurTime > p.trial.task.GratOn + p.trial.task.GratWait)
                        stimPostGratOriChange(p, 3);
                        ND_SwitchEpoch(p, 'WaitSaccade')
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

                if(p.trial.CurTime > p.trial.EV.StimOn + p.trial.task.Timing.saccadeStart)

                    % Checking if gaze has left fix point
                    if(~p.trial.stim.fix.looking)

                        % If gaze has left fix point, checking if saccade was to target
                        ND_SwitchEpoch(p, 'CheckResponse');
                    
                    % If fix held, checking time against pre-set response window before ending trial due to time-out    
                    elseif(p.trial.CurTime > p.trial.EV.StimOn + p.trial.task.saccadeTimeout)

                        % Checking if no orientation change applied
                        if p.trial.task.changeMag == 0

                            % Marking trial outcome as correct
                            p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
                            p.trial.task.Good = 1;
                            
                            % Dispensing reward
                            pds.reward.give(p, p.trial.reward.Dur);
                            
                            % Playing audio signaling correct trial
                            pds.audio.playDP(p, 'reward', 'left');
                            
                            % Record time at which reward given
                            p.trial.EV.Reward = p.trial.CurTime;
                    
                            if p.trial.task.blown_repeat
                                numRows = size(p.defaultParameters.blownTrials, 1);
                                if numRows > 1
                                    p.defaultParameters.blownTrials = p.defaultParameters.blownTrials(2:end,:);
                                else
                                    p.defaultParameters.blownTrials = [];
                                end
                            end
                            
                            % Switching epoch to end task
                            ND_SwitchEpoch(p, 'WaitEnd');

                        else
                            % Marking trial outcome as 'Miss' trial
                            p.trial.outcome.CurrOutcome = p.trial.outcome.Miss;
                            % Play noise signaling response period time-out
                            pds.audio.playDP(p, 'incorrect', 'left');

                            if p.trial.task.blown_repeat
                                numRows = size(p.defaultParameters.blownTrials, 1);
                                if numRows > 1
                                    p.defaultParameters.blownTrials = p.defaultParameters.blownTrials(2:end,:);
                                else
                                    p.defaultParameters.blownTrials = [];
                                end
                            end

                            % Switching epoch to end task
                            ND_SwitchEpoch(p, 'TaskEnd');
                        end

                    end

                elseif(~p.trial.stim.fix.looking)
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
        
            % Checking if saacade response made was to target    
            case p.trial.epoch.CheckResponse

                % Confirming current gaze shift is first response made
                if(~p.trial.task.stimFix)

                    % Checking if gaze specifically within target grating fix window
                    if(p.trial.stim.gabors.postTarget.fixating)

                        % Logging correct selection of grating (target)
                        p.trial.task.stimFix = 1;
                        p.trial.task.StimSel = p.trial.stim.gabors.preTarget.pos;
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        % Logging flight time
                        p.trial.task.FlightTime = p.trial.CurTime - p.trial.EV.FixLeave;
                        
                    % Checking if gaze specifically within distractor 1 grating fix window
                    elseif(p.trial.stim.gabors.distractor1.fixating)

                        % Playing noise signaling incorrect selection
                        pds.audio.playDP(p, 'incorrect', 'left');
                        % Logging incorrect selection of grating (distractor)
                        p.trial.task.StimSel = p.trial.stim.gabors.distractor1.pos;
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        % Logging flight time
                        p.trial.task.FlightTime = p.trial.CurTime - p.trial.EV.FixLeave;

                        % Marking trial as false and ending trial
                        p.trial.outcome.CurrOutcome = p.trial.outcome.False;

                        p.defaultParameters.breakFlag = 1;

                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                        

                    % Checking if gaze specifically within distractor 2 grating fix window   
                    elseif(p.trial.stim.gabors.distractor2.fixating)

                        % Playing noise signaling incorrect selection
                        pds.audio.playDP(p, 'incorrect', 'left');
                        % Logging incorrect selection of grating (distractor)
                        p.trial.task.StimSel = p.trial.stim.gabors.distractor2.pos;
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        % Logging flight time
                        p.trial.task.FlightTime = p.trial.CurTime - p.trial.EV.FixLeave;

                        % Marking trial as false and ending trial  
                        p.trial.outcome.CurrOutcome = p.trial.outcome.False;

                        p.defaultParameters.breakFlag = 1;

                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd')
                        
                    % Checking if gaze specifically within distractor 3 grating fix window   
                    elseif(p.trial.stim.gabors.distractor3.fixating)
                        % Playing noise signaling incorrect selection
                        pds.audio.playDP(p, 'incorrect', 'left');
                        % Logging incorrect selection of grating (distractor)
                        p.trial.task.StimSel = p.trial.stim.gabors.distractor3.pos;
                        % Logging fix duration
                        p.trial.task.SRT_FixStart = p.trial.EV.FixLeave - p.trial.stim.fix.EV.FixStart;
                        % Logging response latency
                        p.trial.task.SRT_StimOn = p.trial.EV.FixLeave - p.trial.EV.StimOn;
                        % Logging flight time
                        p.trial.task.FlightTime = p.trial.CurTime - p.trial.EV.FixLeave;

                        % Marking trial as false and ending trial
                        p.trial.outcome.CurrOutcome = p.trial.outcome.False;

                        p.defaultParameters.breakFlag = 1;

                        % Switching epoch to end task
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
                        % Logging flight time
                        p.trial.task.FlightTime = p.trial.CurTime - p.trial.EV.FixLeave;

                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                    
                    % Checking if gaze returned to fix point in time to be considered 'no response yet'    
                    %elseif(p.trial.stim.fix.looking)
                    %    ND_SwitchEpoch(p, 'WaitSaccade');
                    end
                    
                else
                    % Checking if fix on target held for pre-set minimum amount of time 
                    if(p.trial.CurTime > p.trial.stim.gabors.postTarget.EV.FixStart + p.trial.task.minTargetFixTime)
                        % If so, marking trial as correct and dispensing
                        % reward
                        Task_CorrectReward(p);
                    
                    % Checking if gaze leaves target grating fix window
                    elseif(~p.trial.stim.gabors.postTarget.fixating)
                        % Marking trial as Target Break
                        p.trial.outcome.CurrOutcome = p.trial.outcome.TargetBreak;
                        % Playing noise signaling break of fix from target
                        pds.audio.playDP(p, 'incorrect', 'left');
                                                
                        p.defaultParameters.blownTrials = [p.defaultParameters.blownTrials; p.trial.task.trialConfig];

                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                    end

                end
                     
            % Checking if fixation was broken pre-maturely    
            case p.trial.epoch.BreakFixCheck

                p.defaultParameters.blownTrials = [p.defaultParameters.blownTrials; p.trial.task.trialConfig];

                delay = p.trial.task.breakFixCheck;
                % Checking if fix break was committed before response window
                if(p.trial.task.stimState < 1)

                    % Marking trial as fix break if it occured before response window
                    p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                    
                    % Switching epoch to end task
                    ND_SwitchEpoch(p, 'TaskEnd');
                    
                elseif(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + delay)

                    % Collecting screen frames for trial to check median eye position
                    frames = ceil(p.trial.display.frate * delay);
                    % Calculating median position of eyes across frames
                    medPos = prctile([p.trial.eyeX_hist(1:frames)', p.trial.eyeY_hist(1:frames)'], 50);
                    
                    % Checking if median eye position is in fixation window of target 
                    if(inFixWin(p.trial.stim.gabors.postTarget, medPos))
                        % Marking trial as "hit" but early if eye position is in target fix window
                        p.trial.outcome.CurrOutcome = p.trial.outcome.Early;

                        % Flagging trial as early
                        if p.trial.task.cued
                            p.defaultParameters.earlyFlag = 1;
                        end

                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                    
                    % Checking if median eye position is in fixation window of distractor 1
                    elseif(inFixWin(p.trial.stim.gabors.distractor1, medPos))
                        % Marking trial as "miss" but early if eye position is in distractor fix window
                        p.trial.outcome.CurrOutcome = p.trial.outcome.EarlyFalse;

                        % Flagging trial as early
                        p.defaultParameters.breakFlag = 1;

                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                        
                    % Checking if median eye position is in fixation window of distractor 2
                    elseif(inFixWin(p.trial.stim.gabors.distractor2, medPos))
                        % Marking trial as "miss" but early if eye position is in distractor fix window
                        p.trial.outcome.CurrOutcome = p.trial.outcome.EarlyFalse;

                        % Flagging trial as early
                        p.defaultParameters.breakFlag = 1;

                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                        
                    % Checking if median eye position is in fixation window of distractor 3
                    elseif(inFixWin(p.trial.stim.gabors.distractor3, medPos))
                        % Marking trial as "miss" but early if eye position is in distractor fix window
                        p.trial.outcome.CurrOutcome = p.trial.outcome.EarlyFalse;
               
                        % Flagging trial as early
                        p.defaultParameters.breakFlag = 1;

                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');

                    else
                        % Marking trial as fix break without relevance to task
                        p.trial.outcome.CurrOutcome = p.trial.outcome.StimBreak;
                        
                        % Flagging trial as stim break
                        p.defaultParameters.breakFlag = 1;
                            
                        % Switching epoch to end task
                        ND_SwitchEpoch(p, 'TaskEnd');
                        
                    end 
                
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
                
                % Turning fix point off
                ND_FixSpot(p, 0);
                
                % Running clean-up and storage routine before concluding 
                % trial
                Task_OFF(p);
                
                % Checking if there is "nan" value for start of fixation 
                % on target
                if(~isnan(p.trial.stim.gabors.postTarget.EV.FixStart))
                    p.trial.EV.FixStimStart = p.trial.stim.gabors.postTarget.EV.FixStart;
                    p.trial.EV.FixStimStop = p.trial.stim.gabors.postTarget.EV.FixBreak;
                end
                
                % Flagging completion of current trial so ITI run before 
                % next trial
                p.trial.flagNextTrial = 1; 
        end
        
     
%% SUPPORT FUNCTIONS
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
                ND_AddScreenEvent(p, p.trial.event.RING_REMV, 'RingRemv');   
            elseif(val == 1)
                ND_AddScreenEvent(p, p.trial.event.RING_PRES, 'RingPres');   
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
                    p.trial.stim.gabors.postTarget.on = 0;
                    p.trial.stim.gabors.preTarget.on = 0;
                    p.trial.stim.gabors.distractor1.on = 0;
                    p.trial.stim.gabors.distractor2.on = 0;
                    p.trial.stim.gabors.distractor3.on = 0;
                
                % Implementing stimulus presentation
                case 2
                    p.trial.stim.gabors.preTarget.on = 1;
                    p.trial.stim.gabors.distractor1.on = 1;
                    p.trial.stim.gabors.distractor2.on = 1;
                    p.trial.stim.gabors.distractor3.on = 1;
                    
                    p.trial.stim.gabors.preTarget.fixActive = 1;
                    p.trial.stim.gabors.distractor1.fixActive = 1;
                    p.trial.stim.gabors.distractor2.fixActive = 1;
                    p.trial.stim.gabors.distractor3.fixActive = 1;
                    
                otherwise
                    error('unusable stim value')
      
            end

            % Recording strat time of no stimulus presentation
            if(val == 0)
                ND_AddScreenEvent(p, p.trial.event.GRAT_REMV, 'GratRemv');
                
            elseif(val == 2)
                ND_AddScreenEvent(p, p.trial.event.GRAT_PRES, 'GratPres');
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
                    p.trial.stim.gabors.preTarget.on = 0;
                    p.trial.stim.gabors.preTarget.fixActive = 0;
    
                    p.trial.stim.gabors.postTarget.on = 1;
                    p.trial.stim.gabors.postTarget.fixActive = 1;

                otherwise
                    error('unusable stim value')     
            end

            % Recording strat time of no stimulus presentation
            if(val == 0)
                ND_AddScreenEvent(p, p.trial.event.CHNG_REMV, 'ChangeRemv');
                
            elseif(val == 3)
                ND_AddScreenEvent(p, p.trial.event.CHNG_PRES, 'ChangePres');
                
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

        if p.trial.task.blown_repeat
            numRows = size(p.defaultParameters.blownTrials, 1);
            if numRows > 1
                p.defaultParameters.blownTrials = p.defaultParameters.blownTrials(2:end,:);
            else 
                p.defaultParameters.blownTrials = [];
            end
        end
        
        % Switching epoch to end task
        ND_SwitchEpoch(p, 'WaitEnd');
        
 
% Function to clean up screen textures and variables and to save data to ascii table (AttendGrat_init.m)
function TaskCleanAndSave(p)
           
        % Saving key variables
        Task_Finish(p);
        % Trial outcome saved as code, and this is converting it to str name
        p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};
        % Loading data into ascii table for plotting
        ND_Trial2Ascii(p, 'save');
        
