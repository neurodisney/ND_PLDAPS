function p = PercEqui(p, state)
% Main trial function for a perceptual equilibrium task.
%
%
%
% wolf zinke, Nov. 2017

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
    
    % call initialisation routine
    p = PercEqui_init(p);
    
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
           %TaskDraw(p);

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

    p.trial.task.Good      = 0;
    p.trial.task.fixFix    = 0;
    p.trial.task.stimFix   = 0;
    p.trial.task.stimState = 0;  % 0 is off, 1 is on

    %% Generate all the visual stimuli
    % Fixation spot
    p.trial.stim.fix = pds.stim.FixSpot(p);

    % determine grating parameters
    if(p.trial.task.RandomPar == 1)
        p.trial.stim.Ref.sFreq = datasample(p.trial.stim.sFreqLst, 1); % spatial frequency as cycles per degree
        p.trial.stim.Ref.ori   = datasample(p.trial.stim.OriLst,   1); % orientation of grating
    end
    
    % get grating location
    % if random position is required pick one and move fix spot
    if(p.trial.task.RandomPos == 1)
        p.trial.stim.PosY = datasample(p.trial.stim.PosYlst, 1);
    end

    if(p.trial.task.RandomHemi == 1)
        p.trial.stim.Hemi = datasample(['l', 'r'], 1);
    end

    % define both gratings
    p.trial.stim.Trgt.Contrast = p.trial.stim.trgtconts(p.trial.Nr); % contrast determined by condition number
    
    % pick the higher contrast item as saccade target and make sure it is on the specified hemifield
    if(p.trial.stim.Trgt.Contrast >= p.trial.stim.Ref.Contrast)
        p.trial.stim.SaccadeTarget     = 'target';
        p.trial.stim.SaccadeDistractor = 'reference';

        if(p.trial.stim.Hemi == 'r')
            p.trial.stim.Ref.Pos  = [-1* p.trial.stim.PosX, p.trial.stim.PosY];
            p.trial.stim.Trgt.Pos = [ 1* p.trial.stim.PosX, p.trial.stim.PosY];
        else
            p.trial.stim.Ref.Pos  = [ 1* p.trial.stim.PosX, p.trial.stim.PosY];
            p.trial.stim.Trgt.Pos = [-1* p.trial.stim.PosX, p.trial.stim.PosY];
        end
    
    else
        p.trial.stim.SaccadeTarget     = 'reference';
        p.trial.stim.SaccadeDistractor = 'target';
    
        if(p.trial.stim.Hemi == 'l')
            p.trial.stim.Ref.Pos  = [-1* p.trial.stim.PosX, p.trial.stim.PosY];
            p.trial.stim.Trgt.Pos = [ 1* p.trial.stim.PosX, p.trial.stim.PosY];
        else
            p.trial.stim.Ref.Pos  = [ 1* p.trial.stim.PosX, p.trial.stim.PosY];
            p.trial.stim.Trgt.Pos = [-1* p.trial.stim.PosX, p.trial.stim.PosY];
        end
    end
    
    % Create Reference grating (parameter in question is kept constant)
    p.trial.stim.GRATING.sFreq     = p.trial.stim.Ref.sFreq;
    p.trial.stim.GRATING.ori       = p.trial.stim.Ref.ori;
    p.trial.stim.GRATING.pos       = p.trial.stim.Ref.Pos;
    p.trial.stim.GRATING.contrast  = p.trial.stim.Ref.Contrast;
    p.trial.stim.reference         = pds.stim.Grating(p);

    % create distractor
    if(p.trial.task.RandomPar == 1 && p.trial.task.EqualStim == 0)
        p.trial.stim.Trgt.sFreq = datasample(p.trial.stim.sFreqLst, 1); % spatial frequency as cycles per degree
        p.trial.stim.Trgt.ori   = datasample(p.trial.stim.OriLst,   1); % orientation of grating
    else
        p.trial.stim.Trgt.sFreq = p.trial.stim.Ref.sFreq;
        p.trial.stim.Trgt.ori   = p.trial.stim.Ref.ori; 
    end

    p.trial.stim.GRATING.sFreq     = p.trial.stim.Trgt.sFreq;
    p.trial.stim.GRATING.ori       = p.trial.stim.Trgt.ori;
    p.trial.stim.GRATING.pos       = p.trial.stim.Trgt.Pos;
    p.trial.stim.GRATING.contrast  = p.trial.stim.Trgt.Contrast;
    p.trial.stim.target            = pds.stim.Grating(p);

    % Assume manual control of the activation of the grating fix windows
    p.trial.stim.grating_target.autoFixWin    = 0;
    p.trial.stim.grating_reference.autoFixWin = 0;
    
    % increase reward after defined number of correct trials
    RewDur = find(p.trial.reward.IncrementTrial > p.trial.NHits+1, 1, 'first');
    p.trial.reward.Dur = p.trial.reward.IncrementDur(RewDur);

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

        case p.trial.epoch.Fixating
        %% check fixation until target stimulus will appear
            if(p.trial.stim.fix.fixating)
                if(p.trial.task.stimState == 0)                    
                    if(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.stimLatency)
                        stim(p, 1); % Turn on stim
                        ND_SwitchEpoch(p, 'WaitSaccade');
                    end
                end
                
            % Fixation Break, end the trial
            elseif(~p.trial.stim.fix.fixating)
                pds.audio.playDP(p, 'breakfix', 'left');

                ND_SwitchEpoch(p, 'BreakFixCheck');
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitSaccade
        %% Items shown, animal has to decide what's the target and make a saccade towards it
            % Animal has not yet saccaded to target
                % Need to check if no saccade has been made or if a wrong saccade has been made

            if(~p.trial.stim.fix.looking)
            % gaze left fixation spot, check what the response is    
                ND_SwitchEpoch(p, 'CheckResponse');

            elseif(p.trial.CurTime > p.trial.EV.FixOff + p.trial.task.saccadeTimeout)
            % If no saccade has been made before the time runs out, end the trial

                p.trial.outcome.CurrOutcome = p.trial.outcome.Miss;

                % Play an incorrect sound
                pds.audio.playDP(p, 'incorrect', 'left');

                ND_SwitchEpoch(p, 'TaskEnd');
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.CheckResponse
        %% Response occurred, check if it was the correct one
            if(~p.trial.task.stimFix)
            % Animal has not yet saccaded to target
        
                if(p.trial.stim.(p.trial.stim.SaccadeTarget).fixating)
                % Animal has saccaded to correct stim
                    p.trial.task.stimFix = 1;

                elseif(p.trial.stim.(p.trial.stim.SaccadeDistractor).looking)        
                % wrong item chosen
                    % Play breakfix sound
                    pds.audio.playDP(p, 'incorrect','left');

                    % Turn the stim off and fixation off
                    stim(p,0);
                    ND_FixSpot(p,0);

                    % Mark trial (early) false and end task
                    p.trial.outcome.CurrOutcome = p.trial.outcome.False;
                    
                    % time to early to detect proper fixation break, thus set the time here explicitly
                    p.trial.EV.Response         = p.trial.EV.FixLeave;

                    ND_SwitchEpoch(p, 'TaskEnd');

                elseif(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + p.trial.task.breakFixCheck)
                % gaze away from fixation spot but not item selected: fix break
                    p.trial.outcome.CurrOutcome = p.trial.outcome.NoTargetFix;
                    p.trial.EV.Response         = p.trial.EV.FixLeave;

                    % Turn the stim off and fixation off
                    stim(p,0);
                    ND_FixSpot(p,0);

                    % Play an incorrect sound
                    pds.audio.playDP(p, 'incorrect', 'left');

                    % End the trial
                    ND_SwitchEpoch(p, 'TaskEnd');
                    
                elseif(p.trial.stim.fix.looking)
                % returned in time to fixation spot, not considered a response saccade yet
                     ND_SwitchEpoch(p, 'WaitSaccade');
                end                 
            else  % stimFix == 1
            % Animal is currently fixating on target
                % Wait for animal to hold fixation for the required length of time then give reward and mark trial good
                if(p.trial.CurTime > p.trial.stim.(p.trial.stim.SaccadeTarget).EV.FixStart + p.trial.task.minTargetFixTime)

                    p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
                    p.trial.EV.Response         = p.trial.EV.FixLeave;
                    p.trial.task.Good = 1;

                    pds.reward.give(p, p.trial.reward.Dur);
                    pds.audio.playDP(p, 'reward', 'left');

                    % Record main reward time
                    p.trial.EV.Reward = p.trial.CurTime;

                    ND_SwitchEpoch(p, 'WaitEnd');

                elseif(~p.trial.stim.(p.trial.stim.SaccadeTarget).fixating)
                % If animal's gaze leaves window, end the task and do not give reward
                    p.trial.outcome.CurrOutcome = p.trial.outcome.TargetBreak;
                    p.trial.EV.Response         = p.trial.EV.FixLeave;

                    % Play an incorrect sound
                    pds.audio.playDP(p, 'incorrect', 'left');

                    ND_SwitchEpoch(p, 'TaskEnd');
                end
            end
                
        % ----------------------------------------------------------------%
        case p.trial.epoch.BreakFixCheck
        %% Determine whether stim early saccade or a stimBreak
            % Wait for enough time to elapse after the stimBreak
            delay = p.trial.task.breakFixCheck;
            if(p.trial.task.stimState == 0)
                p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                p.trial.EV.Response         = p.trial.stim.fix.EV.FixBreak;

                ND_SwitchEpoch(p, 'TaskEnd');
            
            elseif(p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + delay)
                % Get the median eye position in the delay
                frames = ceil(p.trial.display.frate * delay);
                medPos = prctile([p.trial.eyeX_hist(1:frames)', p.trial.eyeY_hist(1:frames)'], 50);

                p.trial.EV.Response = p.trial.EV.FixLeave;

                % Determine if the medPos is in the fixation window for the stim
                if(inFixWin(p.trial.stim.(p.trial.stim.SaccadeTarget), medPos))
                    p.trial.outcome.CurrOutcome = p.trial.outcome.Early;

                elseif(inFixWin(p.trial.stim.(p.trial.stim.SaccadeDistractor), medPos))
                    p.trial.outcome.CurrOutcome = p.trial.outcome.EarlyFalse;

                else
                    p.trial.outcome.CurrOutcome = p.trial.outcome.StimBreak;
                end

                ND_SwitchEpoch(p, 'TaskEnd');
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitEnd
        %% wait before turning all stuff off
            if(p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.Timing.WaitEnd)
                ND_SwitchEpoch(p, 'TaskEnd');
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
            stim(p,0);   % Turn off stim
            ND_FixSpot(p, 0);

            Task_OFF(p); % Run standard TaskEnd routine

            if(~isnan(p.trial.stim.target.EV.FixStart))
                p.trial.EV.FixStimStart = p.trial.stim.target.EV.FixStart;
                p.trial.EV.FixStimStop  = p.trial.stim.target.EV.FixBreak;

            elseif(~isnan(p.trial.stim.reference.EV.FixStart))
                p.trial.EV.FixStimStart = p.trial.stim.reference.EV.FixStart;
                p.trial.EV.FixStimStop  = p.trial.stim.reference.EV.FixBreak;
            end

            % Flag next trial ITI is done at begining
            p.trial.flagNextTrial = 1;

    end  % switch p.trial.CurrEpoch

% ####################################################################### %
% function TaskDraw(p)
% %% Custom draw function for this experiment

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

        % random position of target on each trial
        case KbName('r') 
             p.trial.task.RandomPos = abs(p.trial.task.RandomPos - 1);

           if(p.trial.task.RandomPos)
                ND_CtrlMsg(p, 'Random Grating location on each trial.');
            else
                ND_CtrlMsg(p, 'Grating location is kept constant.');
            end

        % randomly select a new spatial frequency
        case KbName('f')
            p.trial.stim.GRATING.sFreq = datasample(p.trial.stim.sFreqLst, 1); % spatial frequency as cycles per degree
            ND_CtrlMsg(p, 'Grating spatial frequency changed.');

        % randomly select a new grating orientation
        case KbName('o')
            p.trial.stim.GRATING.ori = datasample(p.trial.stim.OriLst, 1); % orientation of grating
            ND_CtrlMsg(p, 'Grating orientation changed.');

        % select grating parameters at random for every trial
        case KbName('g')  % randomly select a new grating orientation
            p.trial.task.RandomPar = abs(p.trial.task.RandomPar - 1);

            if(p.trial.task.RandomPar)
                ND_CtrlMsg(p, 'Random Grating parameter on each trial.');
            else
                ND_CtrlMsg(p, 'Grating parameter are kept constant.');
            end

        % select grating parameters at random for every trial
        case KbName('h')  % randomly select a new grating orientation
            p.trial.task.RandomHemi = abs(p.trial.task.RandomHemi - 1);

            if(p.trial.task.RandomHemi)
                ND_CtrlMsg(p, 'Random hemifield for target on each trial.');
            else
                ND_CtrlMsg(p, 'Target will be shown in the same hemifield for subsequent trials.');
            end

        % determine wether both gratings have same orientation and spatial frequency
        case KbName('DownArrow')
            p.trial.task.EqualStim = abs(p.trial.task.EqualStim - 1);

            if(p.trial.task.EqualStim)
                ND_CtrlMsg(p, 'Both, target and distractor, have same grating parameters.');
            else
                ND_CtrlMsg(p, 'Target and distractor grating parameters are different.');
            end

        % move target to left or right hemifield
        case KbName('RightArrow')
            p.trial.stim.Hemi  = 'r';
            ND_CtrlMsg(p, 'Target in right hemifield.');

        case KbName('LeftArrow')
            p.trial.stim.Hemi  = 'l';
            ND_CtrlMsg(p, 'Target in left hemifield.');

        % move target to grid positions
        case p.trial.key.GridKeyCell
            gpos = p.trial.key.GridKey == p.trial.LastKeyPress(1);
            p.trial.stim.PosY = p.trial.stim.GridPos(gpos);
            ND_CtrlMsg(p, ['Moved Grating to Y ', num2str(p.trial.stim.PosY, '%.2f'), '.']);
    end
end

% ####################################################################### %
function stim(p, val)
    % Don't do anything if stim doesn't change
    if(val ~= p.trial.task.stimState)

        p.trial.task.stimState = val;

        % Turn on/off the appropriate generated stimuli
        % Only use the fixation window of the high contrast stimulus to avoid problems with overlapping fix windows
        switch val
            case 0
                p.trial.stim.reference.on        = 0;
                p.trial.stim.target.on           = 0;

            case 1
                p.trial.stim.target.on           = 1;
                p.trial.stim.target.fixActive    = 1;

                p.trial.stim.reference.on        = 1;
                p.trial.stim.reference.fixActive = 1;
                
            otherwise
                error('bad stim value');
        end

        % Record the change timing
        if(val == 0)
            % Stim is turning off
            ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');

        elseif(val == 1)
            % Stim is turning on
            ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');
        end
    end

% ####################################################################### %
function Calculate_SRT(p)
    % Grab the fixation stopping and starting values from the stim properties
    p.trial.EV.FixSpotStart = p.trial.stim.fix.EV.FixStart;
    
    if(~strcmp(p.trial.outcome.CurrOutcomeStr,'False'))
        p.trial.EV.FixSpotStop  = p.trial.stim.fix.EV.FixBreak;
    end

    switch p.trial.outcome.CurrOutcomeStr
        case {'NoStart', 'Break', 'Miss', 'NoFix'}
            p.trial.task.SRT_FixStart = NaN;
            p.trial.task.SRT_StimOn   = NaN;

        case {'FixBreak'}
            p.trial.task.SRT_FixStart = p.trial.EV.FixSpotStop -  p.trial.EV.FixSpotStart;
            p.trial.task.SRT_StimOn   = p.trial.EV.FixSpotStop - (p.trial.EV.FixSpotStart + p.trial.task.stimLatency);

        case {'StimBreak', 'Early', 'EarlyFalse', 'NoTargetFix'}
            p.trial.task.SRT_FixStart = p.trial.EV.FixSpotStop -  p.trial.EV.FixSpotStart;
            p.trial.task.SRT_StimOn   = p.trial.EV.FixSpotStop -  p.trial.EV.StimOn;

        case {'False', 'Correct', 'TargetBreak'}
            p.trial.task.SRT_FixStart = p.trial.EV.FixSpotStop - p.trial.EV.FixSpotStart;
            p.trial.task.SRT_StimOn   = p.trial.EV.FixSpotStop - p.trial.EV.StimOn;

        otherwise
            warning(['Calculate_SRT: unrecognized outcome: ', p.trial.outcome.CurrOutcomeStr]);
            p.trial.task.SRT_FixStart = NaN;
            p.trial.task.SRT_StimOn   = NaN;
    end




