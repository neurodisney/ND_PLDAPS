% Task for presenting still or moving image sets
% John Amodeo, May 2025

% Function to run task for experiment
function p = ViewScene(p, state)
    % Checking for task name
    if(~exist('state','var'))
        state = [];
    end
    
     % Initializing task
    if(isempty(state))
        p = ViewScene_init(p);
    else
        p = ND_GeneralTrialRoutines(p, state);
        MasterFlow(p, state)
    end


function MasterFlow(p, state)
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
    
% Function to gather materials to start trial
function TaskSetUp(p)
    p.trial.Block.trialCount = 1;
    p.trial.Block.trialCount = p.trial.Block.trialCount + 1;
    p.trial.task.fixFix = 0;
    p.trial.task.stimState = 0;
    p.trial.task.SRT_FixStart = NaN;
    p.trial.stim.fix = pds.stim.FixSpot(p);
    p.trial.stim.IMAGE.pos = [0 0];

    rng('shuffle');
    scene = datasample(p.trial.task.stim.sceneNames, 1);
    p.trial.stim.sceneName = scene{1};

    if strcmp(p.trial.task.stim.sceneType, 'image')
        p.trial.stim.IMAGE.imagePath = fullfile(p.trial.task.stim.sceneDir, scene{1});
        p.trial.stim.scene = pds.stim.Image(p);
    elseif strcmp(p.trial.task.stim.sceneType, 'video')
        p.trial.stim.VIDEO.moviePath = fullfile(p.trial.task.stim.sceneDir, scene{1});
        p.trial.stim.scene = pds.stim.Video(p);
    end

    ND_SwitchEpoch(p, 'ITI');

function TaskDesign(p)
    % Command moving trial from epoch to epoch over course of trial
    switch p.trial.CurrEpoch
        case p.trial.epoch.ITI
            Task_WaitITI(p);
        case p.trial.epoch.TrialStart
            Task_ON(p);
            ND_FixSpot(p, 1);
            p.trial.EV.TaskStart = p.trial.CurTime;
            p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
            ND_SwitchEpoch(p,'WaitFix')
        case p.trial.epoch.WaitFix
            Task_WaitFixStart(p);
        case p.trial.epoch.Fixating
            if(p.trial.stim.fix.fixating)
                showScene(p, 1)
                ND_SwitchEpoch(p,'WaitResponse')
            end
        case p.trial.epoch.WaitResponse
            ND_FixSpot(p, 0);
            if(p.trial.stim.scene.fixating)
                dur = p.trial.stim.scene.duration + p.trial.task.durOffset;
                if (p.trial.EV.TaskStart + dur) < p.trial.CurTime
                    Task_Correct(p)
                    showScene(p, 0)
                end
            end
            if(~p.trial.stim.scene.fixating)         
                Task_Incorrect(p)
            end
        case p.trial.epoch.TaskEnd
            p.trial.flagNextTrial = 1;
            Task_OFF(p);
    end


function showScene(p, display_val)
    if(display_val ~= p.trial.task.stimState)
        p.trial.task.stimState = display_val;
        switch display_val
            case 0
               p.trial.stim.scene.on = 0;
               p.trial.stim.scene.fixActive = 0;
               ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff'); 
            case 1
                p.trial.stim.scene.on = 1;
                p.trial.stim.scene.fixActive = 1;
                ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');
            otherwise
                error('Unusable stimulus or display value')
        end
    end  

function p = Task_Correct(p)
    p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
    p.trial.task.Good = 1;
    % pds.audio.playDP(p,'jackpot','left');
    pds.reward.give(p, 0.1);
    p.trial.EV.Reward = p.trial.CurTime;
    ND_SwitchEpoch(p,'TaskEnd');

function p = Task_Incorrect(p)
    p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
    p.trial.task.Good = 0;
    % pds.audio.playDP(p, 'breakfix', 'left');
    ND_SwitchEpoch(p,'TaskEnd');

function TaskCleanAndSave(p)
    Task_Finish(p);
    p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};
    ND_Trial2Ascii(p, 'save');
