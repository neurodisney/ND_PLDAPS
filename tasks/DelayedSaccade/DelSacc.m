function p = DelSacc(p, state)
% Main trial function for initial fixation training.
%
%
%
% wolf zinke, Apr. 2017
% Nate Faber, May 2017

% ####################################################################### %
%% define the task name that will be used to create a sub-structure in the trial struct

if(~exist('state', 'var'))
    state = [];
end

% ####################################################################### %
%% Initial call of this function. Use this to define general settings of the experiment/session.
% Here, default parameters of the pldaps class could be adjusted if needed.
% This part corresponds to the experimental setup file and could be a separate
% file. In this case p.defaultParameters.pldaps.trialFunction needs to be
% defined here to refer to the file with the actual trial.
% At this stage, p.trial is not yet defined. All assignments need
% to go to p.defaultparameters
if(isempty(state))
    % --------------------------------------------------------------------%
    %% define ascii output file
    p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'Good',        'p.trial.task.Good',                   '%d');

    p = ND_AddAsciiEntry(p, 'StimPosX',    'p.trial.stim.GRATING.pos(1)',         '%.3f');
    p = ND_AddAsciiEntry(p, 'StimPosY',    'p.trial.stim.GRATING.pos(2)',         '%.3f');
    p = ND_AddAsciiEntry(p, 'Eccentricity','p.trial.stim.GRATING.eccentricity',   '%.3f');
    p = ND_AddAsciiEntry(p, 'AnglePos',    'p.trial.stim.GRATING.PosAngle',       '%.3f');
    p = ND_AddAsciiEntry(p, 'tFreq',       'p.trial.stim.GRATING.tFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'sFreq',       'p.trial.stim.GRATING.sFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'lContr',      'p.trial.stim.GRATING.lowContrast',    '%.1f');
    p = ND_AddAsciiEntry(p, 'hContr',      'p.trial.stim.GRATING.highContrast',   '%.1f');
    p = ND_AddAsciiEntry(p, 'StimSize',    '2*p.trial.stim.GRATING.radius',       '%.1f');

    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOn',      'p.trial.EV.StimOn',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOff',     'p.trial.EV.StimOff',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'StimChange',  'p.trial.EV.StimChange',               '%.5f');
    p = ND_AddAsciiEntry(p, 'GoCue',       'p.trial.EV.GoCue',                    '%.5f');
    p = ND_AddAsciiEntry(p, 'FixStart',    'p.trial.EV.FixSpotStart',             '%.5f');
    p = ND_AddAsciiEntry(p, 'FixBreak',    'p.trial.EV.FixSpotStop',              '%.5f');
    p = ND_AddAsciiEntry(p, 'StimFix',     'p.trial.EV.FixTargetStart',           '%.5f');
    p = ND_AddAsciiEntry(p, 'StimBreak',   'p.trial.EV.FixTargetStop',            '%.5f');
    p = ND_AddAsciiEntry(p, 'TaskEnd',     'p.trial.EV.TaskEnd',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');
    p = ND_AddAsciiEntry(p, 'GoLatency',   'p.trial.task.centerOffLatency',       '%.5f');
    p = ND_AddAsciiEntry(p, 'StimLatency', 'p.trial.task.stimLatency',            '%.5f');
    p = ND_AddAsciiEntry(p, 'SRT_FixStart','p.trial.task.SRT_FixStart',           '%.5f');
    p = ND_AddAsciiEntry(p, 'SRT_StimOn',  'p.trial.task.SRT_StimOn',             '%.5f');
    p = ND_AddAsciiEntry(p, 'SRT_Go',      'p.trial.task.SRT_Go',                 '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.behavior.fixation.FixWin',    '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwd',     'p.trial.EV.InitReward',               '%.5f');
    p = ND_AddAsciiEntry(p, 'Reward',      'p.trial.EV.Reward',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'RewPulses',   'p.trial.reward.nPulse',               '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwdDur',  'p.trial.reward.InitialRew * ~isnan(p.trial.EV.InitReward)', '%.5f');
    p = ND_AddAsciiEntry(p, 'RewardDur',   'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)',           '%.5f');

    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');

    %% initialize target parameters
    p.defaultParameters.behavior.fixation.FixWin = 2.5;
    
    p.defaultParameters.task.RandomPos = 0; % if 1, randomly change the grating location each trial
    p.defaultParameters.task.RandomPar = 0; % if 1, randomly change orientation and spatial frequency of the grating each trial

    % define random grating parameters for each session
    p.defaultParameters.stim.GRATING.RandAngles = 0:15:359;  % if in random mode chose an angle from this list
    p.defaultParameters.stim.GRATING.sFreqLst   = 1:0.2:6; % spatial frequency as cycles per degree
    p.defaultParameters.stim.GRATING.OriLst     = 0:15:179; % orientation of grating
    
    p.defaultParameters.stim.GRATING.PosAngle   = datasample(p.defaultParameters.stim.GRATING.RandAngles, 1);
    p.defaultParameters.stim.GRATING.sFreq      = datasample(p.defaultParameters.stim.GRATING.sFreqLst,   1); % spatial frequency as cycles per degree
    p.defaultParameters.stim.GRATING.ori        = datasample(p.defaultParameters.stim.GRATING.OriLst,     1); % orientation of grating

else
    % ####################################################################### %
    %% Call standard routines before executing task related code
    % This carries out standard routines, mainly in respect to hardware interfacing.
    % Be aware that this is done first for each trial state!
    p = ND_GeneralTrialRoutines(p, state);

    % ####################################################################### %
    %% Subsequent calls during actual trials
    % execute trial specific commands here.

    switch state
        % ------------------------------------------------------------------------%
        % DONE BEFORE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialSetup
        %% trial set-up
        % prepare everything for the trial, including allocation of stimuli
        % and all other more time demanding stuff.
            TaskSetUp(p);

        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialPrepare
        %% trial preparation
        % just prior to actual trial start, use it for time sensitive preparations;
            p.trial.EV.TrialStart = p.trial.CurTime;

        % ------------------------------------------------------------------------%
        % DONE DURING THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.framePrepareDrawing
        %% Get ready to display
        % prepare the stimuli that should be shown, do some required calculations
            if(~isempty(p.trial.LastKeyPress))
                KeyAction(p);
            end
            TaskDesign(p);

        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameDraw
        %% Display stuff on the screen
        % Just call graphic routines, avoid any computations
           TaskDraw(p);

        % ------------------------------------------------------------------------%
        % DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
            TaskCleanAndSave(p);

    end  %/ switch state
end  %/  if(nargin == 1) [...] else [...]

% ####################################################################### %
%% Task related functions
% ####################################################################### %

% ####################################################################### %
function TaskSetUp(p)
    %% main task outline
    % Determine everything here that can be specified/calculated before the actual trial start

    % Outcome if no fixation occurs at all during the trial
    p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

    p.trial.task.Good    = 0;
    p.trial.task.fixFix  = 0;
    p.trial.task.stimFix = 0;

    %% Generate all the visual stimuli
    % Fixation spot
    p.trial.stim.fix = pds.stim.FixSpot(p);

    % get grating location
    % if random position is required pick one and move fix spot
    if(p.trial.task.RandomPos == 1)        
         p.trial.stim.GRATING.PosAngle = datasample(p.trial.stim.GRATING.RandAngles, 1);
    end
    
    if(p.trial.task.RandomPar == 1)      
        p.trial.stim.GRATING.sFreq = datasample(p.trial.stim.GRATING.sFreqLst, 1); % spatial frequency as cycles per degree
        p.trial.stim.GRATING.ori   = datasample(p.trial.stim.GRATING.OriLst,   1); % orientation of grating
    end

    [Gx, Gy] = pol2cart(deg2rad(p.trial.stim.GRATING.PosAngle), ...
                                p.trial.stim.GRATING.eccentricity);
    p.trial.stim.GRATING.pos = [Gx, Gy];

    % Generate the low contrast stimulus
    p.trial.stim.GRATING.contrast = p.trial.stim.GRATING.lowContrast;
    p.trial.stim.gratingL = pds.stim.Grating(p);

    % and the high contrast stimulus
    p.trial.stim.GRATING.contrast = p.trial.stim.GRATING.highContrast;
    p.trial.stim.gratingH = pds.stim.Grating(p);

    % Assume manual control of the activation of the grating fix windows
    p.trial.stim.gratingL.autoFixWin = 0;
    p.trial.stim.gratingH.autoFixWin = 0;

    p.trial.task.stimState = 0;   % 0 is off, 1 is low contrast, 2 is high contrast -> stim starts off
    
    p.trial.task.centerOffLatency = ND_GetITI(p.trial.task.MinWaitGo, p.trial.task.MaxWaitGo); % Time from stim appearing to fixspot disappearing

    ND_SwitchEpoch(p, 'ITI');
    
% ####################################################################### %
function TaskDesign(p)
    %% main task outline
    % The different task stages (i.e. 'epochs') are defined here.
    switch p.trial.CurrEpoch

        % ----------------------------------------------------------------%
        case p.trial.epoch.ITI
        %% inter-trial interval: wait until sufficient time has passed from the last trial
            Task_WaitITI(p);
        % ----------------------------------------------------------------%
        case p.trial.epoch.TrialStart
         %% trial starts with onset of fixation spot
            Task_ON(p);
            ND_FixSpot(p, 1);

            p.trial.EV.TaskStart     = p.trial.CurTime;
            p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');

            ND_SwitchEpoch(p,'WaitFix');
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
        %% Fixation target shown, waiting for a sufficiently held gaze
            Task_WaitFixStart(p);

            if(p.trial.CurrEpoch == p.trial.epoch.Fixating)
            % fixation just started, initialize fixation epoch
                p.trial.outcome.CurrOutcome = p.trial.outcome.Fixation;

                % initial rewardfor fixation start
                if(p.trial.reward.GiveInitial == 1)
                    p.trial.EV.InitReward = p.trial.CurTime;
                    pds.reward.give(p, p.trial.reward.InitialRew);
                end
            end
            
            % ----------------------------------------------------------------%
        case p.trial.epoch.Fixating
        %% Initial reward has been given (if it is not 0), now stim target will appear
            % Still fixating
            if(p.trial.stim.fix.fixating)
                % Wait stim latency before showing reward
                if(~p.trial.task.stimState)
                    if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)
                        stim(p, 1); % Turn on stim
                    end

                else
                    % Must maintain fixation (inhibit saccade) until central
                    % fixation spot disappears
                    if(p.trial.CurTime > p.trial.EV.StimOn + p.trial.task.centerOffLatency)

                        % Saccade has been inhibited long enough. Make the central fix spot disappear
                        ND_FixSpot(p, 0);
                        ND_AddScreenEvent(p, p.trial.event.GOCUE, 'GoCue');

                        stim(p, 2) % Make the stim high contrast

                        % Change to the saccade epoch
                        ND_SwitchEpoch(p, 'Saccade');
                    end
                end

                % Fixation Break, end the trial
            elseif(~p.trial.stim.fix.fixating)
                pds.audio.playDP(p, 'breakfix', 'left');

                if(p.trial.task.stimState)
                    % If the stim is on, need to determine whether it is an early saccade
                    % or a stimBreak. Calculated in the BreakFixCheck epoch
                    ND_SwitchEpoch(p, 'BreakFixCheck');
                else
                    p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                    ND_SwitchEpoch(p, 'TaskEnd');
                end

                % Turn off fixspot and stim
                ND_FixSpot(p, 0);
                stim(p, 0);
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.Saccade
        %% Central fixation spot has disappeared. Animal must quickly saccade to stim to get the main reward
            if(~p.trial.task.stimFix)
                % Animal has not yet saccaded to target
                % Need to check if no saccade has been made or if a wrong saccade has been made

                if(p.trial.stim.gratingH.looking)
                    % Animal has saccaded to stim

                    % Make sure that saccade was actually a reaction to the go cue,
                    % rather than a lucky precocious saccade
                    if(p.trial.stim.fix.EV.FixBreak < p.trial.EV.FixOff + p.trial.task.minSaccReactTime)
                        % Play breakfix sound
                        pds.audio.playDP(p, 'breakfix','left');

                        % Turn the stim off and fixation off
                        stim(p,0);
                        ND_FixSpot(p,0);

                        % Mark trial early and end task
                        p.trial.outcome.CurrOutcome = p.trial.outcome.Early;
                        ND_SwitchEpoch(p, 'TaskEnd');

                    elseif(p.trial.stim.gratingH.fixating)
                        % Real reaction to GO cue and has acheived fixation
                        p.trial.task.stimFix = 1;
                    end

                elseif(~p.trial.stim.fix.fixating)
                    % Eye has left the central fixation spot. Wait a breifly for eye to arrive
                        if(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + p.trial.task.breakFixCheck)
                            % Eye has saccaded somewhere besides the target
                            p.trial.outcome.CurrOutcome = p.trial.outcome.NoTargetFix;

                            % Turn the stim off and fixation off
                            stim(p,0);
                            ND_FixSpot(p,0);

                            % Play an incorrect sound
                            pds.audio.playDP(p, 'incorrect', 'left');

                            % End the trial
                            ND_SwitchEpoch(p, 'TaskEnd');
                        end

                elseif(p.trial.CurTime > p.trial.EV.FixOff + p.trial.task.saccadeTimeout)
                    % If no saccade has been made before the time runs out, end the trial

                    p.trial.outcome.CurrOutcome = p.trial.outcome.Miss;

                    % Turn the stim off and fixation off
                    stim(p,0);
                    ND_FixSpot(p,0);

                    % Play an incorrect sound
                    pds.audio.playDP(p, 'incorrect', 'left');

                    ND_SwitchEpoch(p, 'TaskEnd');
                end
            else
                % Animal is currently fixating on target

                % Wait for animal to hold fixation for the required length of time
                % then give reward and mark trial good
                if(p.trial.CurTime > p.trial.stim.gratingH.EV.FixStart + p.trial.task.minTargetFixTime)
                    
                    p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
                    p.trial.task.Good = 1;
                    
                    % add additional reward pulses for subsequent correct trials
                    if(p.trial.reward.IncrConsecutive == 1)
                        AddPulse = find(p.trial.reward.PulseStep <= p.trial.LastHits+1, 1, 'last');
                        if(~isempty(AddPulse))
                            p.trial.reward.nPulse = p.trial.reward.nPulse + AddPulse;
                        end

                        fprintf('     REWARD!!!  [%d pulse(s) for %d subsequent correct trials]\n\n', ...
                                 p.trial.reward.nPulse, p.trial.LastHits+1);
                    end

                    % increase reward after defined number of correct trials
                    AddDur = find(p.trial.reward.IncrementDur <= p.trial.NHits+1, 1, 'last');
                    if(~isempty(AddDur))
                        AddDur = p.trial.reward.IncrementDur(AddDur);
                    else
                        AddDur = 0;
                    end

                    pds.reward.give(p, p.trial.reward.Dur+AddDur, p.trial.reward.nPulse);
                    pds.audio.playDP(p,'reward','left');

                    % Record main reward time
                    p.trial.EV.Reward = p.trial.CurTime;

                    ND_SwitchEpoch(p,'WaitEnd');

                elseif(~p.trial.stim.gratingH.fixating)
                    % If animal's gaze leaves window, end the task and do not give reward
                    p.trial.outcome.CurrOutcome = p.trial.outcome.TargetBreak;

                    % Turn the stim off
                    stim(p,0);

                    % Play an incorrect sound
                    pds.audio.playDP(p,'incorrect','left');

                    ND_SwitchEpoch(p,'TaskEnd');
                end
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.BreakFixCheck
        %% Determine whether stim early saccade or a stimBreak
            % Wait for enough time to elapse after the stimBreak
            delay = p.trial.task.breakFixCheck;

            if(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + delay)
                % Get the median eye position in the delay
                frames = ceil(p.trial.display.frate * delay);
                medPos = prctile([p.trial.eyeX_hist(1:frames)', p.trial.eyeY_hist(1:frames)'], 50);

                % Determine if the medPos is in the fixation window for the stim
                if(inFixWin(p.trial.stim.gratingH, medPos))
                    p.trial.outcome.CurrOutcome = p.trial.outcome.Early;
                else
                    p.trial.outcome.CurrOutcome = p.trial.outcome.StimBreak;
                end

                ND_SwitchEpoch(p,'TaskEnd');
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitEnd
        %% wait before turning all stuff off
            if(p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.Timing.WaitEnd)
                % Turn off stim
                stim(p,0);
                ND_SwitchEpoch(p,'TaskEnd');
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
            Task_OFF(p); % Run standard TaskEnd routine

            % Grab the fixation stopping and starting values from the stim properties
            p.trial.EV.FixSpotStart   = p.trial.stim.fix.EV.FixStart;
            p.trial.EV.FixSpotStop    = p.trial.stim.fix.EV.FixBreak;
            p.trial.EV.FixTargetStart = p.trial.stim.gratingH.EV.FixStart;
            p.trial.EV.FixTargetStop  = p.trial.stim.gratingH.EV.FixBreak;

            % Flag next trial ITI is done at begining
            p.trial.flagNextTrial = 1;

    end  % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% Custom draw function for this experiment

    % show helping cue by moving fixation spot to target location
    if(p.trial.task.ShowHelp == 1 && p.trial.task.stimState == 2)
        HelpRect = ND_GetRect(p.trial.stim.GRATING.pos, 2*p.trial.stim.FIXSPOT.size);

        Screen('FillOval',  p.trial.display.overlayptr, ...
            p.trial.display.clut.(p.trial.stim.FIXSPOT.color), HelpRect);
    end

% ####################################################################### %
function TaskCleanAndSave(p)
%% Clean up textures, variables, and save useful info to ascii table
    Task_Finish(p);

    % Get the text name of the outcome
    p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

    % Calculate the Saccadic Response Time for easy plotting
    Calculate_SRT(p);

    % Save useful info to an ascii table for plotting
    ND_Trial2Ascii(p, 'save');

% ####################################################################### %
%% additional inline functions
% ####################################################################### %

function KeyAction(p)
%% task specific action upon key press
if(~isempty(p.trial.LastKeyPress))

    switch p.trial.LastKeyPress(1)

        case KbName('r')  % random position of target on each trial
             p.trial.task.RandomPos = abs(p.trial.task.RandomPos - 1);
             
           if(p.trial.task.RandomPos)
                ND_CtrlMsg(p, 'Random Grating location on each trial.');
            else
                ND_CtrlMsg(p, 'Grating location is kept constant.');
            end
            
        % randomly select a new spatial frequency
        case KbName('f') 
            p.trial.stim.GRATING.sFreq = datasample(p.trial.stim.GRATING.sFreqLst,   1); % spatial frequency as cycles per degree
            ND_CtrlMsg(p, 'Grating spatial frequency changed.');
            
        % randomly select a new grating orientation
        case KbName('o')  
            p.trial.stim.GRATING.ori = datasample(p.trial.stim.GRATING.OriLst,     1); % orientation of grating
            ND_CtrlMsg(p, 'Grating orientation changed.');
            
        % select grating parameters at random for every trial    
        case KbName('g')  % randomly select a new grating orientation
            p.trial.task.RandomPar = abs(p.trial.task.RandomPar - 1);
            
            if(p.trial.task.RandomPar)
                ND_CtrlMsg(p, 'Random Grating parameter on each trial.');
            else
                ND_CtrlMsg(p, 'Grating parameter are kept constant.');
            end

        % move target to grid positions
        case p.trial.key.GridKeyCell
            gpos = find(p.trial.key.GridKey == p.trial.LastKeyPress(1));
            
            if(gpos ~= 5)
                if(gpos > 5) % center position not used
                    gpos = gpos - 1;
                end

                p.trial.stim.GRATING.PosAngle = p.trial.stim.GRATING.GridAngles(gpos);

                [Gx, Gy] = pol2cart(deg2rad(p.trial.stim.GRATING.PosAngle), ...
                                        p.trial.stim.GRATING.eccentricity);
                p.trial.stim.GRATING.pos = [Gx, Gy];

                % Assume manual control of the activation of the grating fix windows
                % p.trial.stim.gratingL.pos = p.trial.stim.GRATING.pos;
                % p.trial.stim.gratingH.pos = p.trial.stim.GRATING.pos;
                
                ND_CtrlMsg(p, ['Moved Grating to array location ', int2str(gpos), '.']);
            end
    end
end

% ####################################################################### %
function stim(p, val)
    % Don't do anything if stim doesn't change
    if(val ~= p.trial.task.stimState)
 
        oldVal = p.trial.task.stimState;
        p.trial.task.stimState = val;

        % Turn on/off the appropriate generated stimuli
        % Only use the fixation window of the high contrast stimulus to avoid problems with overlapping fix windows
        switch val
            case 0
                p.trial.stim.gratingL.on = 0;
                p.trial.stim.gratingH.on = 0;

            case 1
                p.trial.stim.gratingL.on = 1;
                p.trial.stim.gratingH.on = 0;
                p.trial.stim.gratingH.fixActive = 1;

            case 2
                p.trial.stim.gratingL.on = 0;
                p.trial.stim.gratingH.on = 1;
                p.trial.stim.gratingH.fixActive = 1;

            otherwise
                error('bad stim value');
        end

        % Record the change timing
        if(val == 0)
            % Stim is turning off
            ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');

        elseif(oldVal == 0)
            % Stim is turning on
            ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');

        else
            % Stim is changing
            ND_AddScreenEvent(p, p.trial.event.STIM_CHNG, 'StimChange');
        end
    end
    
% ####################################################################### %
function Calculate_SRT(p)

    switch p.trial.outcome.CurrOutcomeStr
        case {'NoStart', 'Break', 'Miss'}
            p.trial.task.SRT_FixStart = NaN;
            p.trial.task.SRT_StimOn   = NaN;
            p.trial.task.SRT_Go       = NaN;

        case {'FixBreak'}
            p.trial.task.SRT_FixStart = p.trial.EV.FixSpotStop - p.trial.EV.FixSpotStart;
            p.trial.task.SRT_StimOn   = p.trial.EV.FixSpotStop - (p.trial.EV.FixSpotStart + p.trial.task.stimLatency);
            p.trial.task.SRT_Go       = p.trial.EV.FixSpotStop - (p.trial.EV.FixSpotStart + p.trial.task.stimLatency + p.trial.task.centerOffLatency);

        case {'StimBreak', 'Early'}
            p.trial.task.SRT_FixStart = p.trial.EV.FixSpotStop - p.trial.EV.FixSpotStart;
            p.trial.task.SRT_StimOn   = p.trial.EV.FixSpotStop - p.trial.EV.StimOn;
            p.trial.task.SRT_Go       = p.trial.EV.FixSpotStop - (p.trial.EV.StimOn + p.trial.task.centerOffLatency);

        case {'False', 'Correct', 'TargetBreak'}
            p.trial.task.SRT_FixStart = p.trial.EV.FixSpotStop - p.trial.EV.FixSpotStart;
            p.trial.task.SRT_StimOn   = p.trial.EV.FixSpotStop - p.trial.EV.StimOn;
            p.trial.task.SRT_Go       = p.trial.EV.FixSpotStop - p.trial.EV.StimChange;

        otherwise
            warning('Calculate_SRT: unrecognized outcome');
            p.trial.task.SRT_FixStart = NaN;
            p.trial.task.SRT_StimOn   = NaN;
            p.trial.task.SRT_Go       = NaN;
    end

    
    
    
