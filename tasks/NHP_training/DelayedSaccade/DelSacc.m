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
%% Call standard routines before executing task related code
% This carries out standard routines, mainly in respect to hardware interfacing.
% Be aware that this is done first for each trial state!
p = ND_GeneralTrialRoutines(p, state);

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
    p = ND_AddAsciiEntry(p, 'Date',       'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',       'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Subject',    'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment', 'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',       'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',       'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Result',     'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',    'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'Good',       'p.trial.task.Good',                   '%d');
    
    p = ND_AddAsciiEntry(p, 'StimPosX',   'p.trial.stim.pos(1)',                 '%.3f');
    p = ND_AddAsciiEntry(p, 'StimPosY',   'p.trial.stim.pos(2)',                 '%.3f');
    p = ND_AddAsciiEntry(p, 'tFreq',      'p.trial.stim.tFreq',                  '%.2f');
    p = ND_AddAsciiEntry(p, 'sFreq',      'p.trial.stim.sFreq',                  '%.2f');
    p = ND_AddAsciiEntry(p, 'lContr',     'p.trial.stim.lowContrast',            '%.1f');
    p = ND_AddAsciiEntry(p, 'hContr',     'p.trial.stim.highContrast',           '%.1f');
    p = ND_AddAsciiEntry(p, 'StimSize',   '2*p.trial.stim.radius',               '%.1f');
    
    p = ND_AddAsciiEntry(p, 'Secs',       'p.trial.EV.DPX_TaskOn',               '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOn', ' p.trial.EV.FixOn',                    '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOff', 'p.trial.EV.FixOff',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOn',     'p.trial.EV.StimOn',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOff',    'p.trial.EV.StimOff',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'FixStart',   'p.trial.EV.FixSpotStart',             '%.5f');
    p = ND_AddAsciiEntry(p, 'FixBreak',   'p.trial.EV.FixSpotStop',              '%.5f');
    p = ND_AddAsciiEntry(p, 'StimFix',    'p.trial.EV.FixTargetStart',           '%.5f');
    p = ND_AddAsciiEntry(p, 'StimBreak',  'p.trial.EV.FixTargetStop',            '%.5f');
    p = ND_AddAsciiEntry(p, 'TaskEnd',    'p.trial.EV.TaskEnd',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'ITI',        'p.trial.task.Timing.ITI',             '%.5f');
    
    p = ND_AddAsciiEntry(p, 'FixWin',     'p.trial.behavior.fixation.FixWin',    '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwd',    'p.trial.EV.FirstReward',              '%.5f');
    p = ND_AddAsciiEntry(p, 'Reward',     'p.trial.EV.Reward',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwdDur', 'p.trial.reward.initialFixRwd * ~isnan(p.trial.EV.FirstReward)', '%.5f');
    p = ND_AddAsciiEntry(p, 'RewardDur',  'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)',           '%.5f');

    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');
    
    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.
    
    p.trial.task.Color_list = Shuffle({'black'});
    
    % --------------------------------------------------------------------%
    %% Determine conditions and their sequence
    % define conditions (conditions could be passed to the pldaps call as
    % cell array, or defined here within the main trial function. The
    % control of trials, especially the use of blocks, i.e. the repetition
    % of a defined number of trials per condition, needs to be clarified.
        
    % condition 1
    c1.Nr = 1;    
    c1.nTrials = 20000;
    
    
    % Fill a conditions list with n of each kind of condition sequentially
    conditions = cell(1,5000);
    blocks = nan(1,5000);
    totalTrials = 0;
    
    % Iterate through each condition to fill conditions
    conditionsIterator = {c1};
    
    for iCond = 1:size(conditionsIterator,2)
        cond = conditionsIterator(iCond);
        nTrials = cond{1}.nTrials;
        conditions(1, totalTrials+1:totalTrials+nTrials) = repmat(cond,1,nTrials);
        blocks(1, totalTrials+1:totalTrials+nTrials) = repmat(iCond,1,nTrials);
        totalTrials = totalTrials + nTrials;
    end
    
    % Truncate the conditions cell array to it's actualy size
    conditions = conditions(1:totalTrials);
    blocks = blocks(1:totalTrials);
    
    p.conditions = conditions;
    p.trial.blocks = blocks;
    
    p.defaultParameters.pldaps.finish = totalTrials;
    
else
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
            TaskDraw(p)
            
            % ------------------------------------------------------------------------%
            % DONE AFTER THE MAIN TRIAL LOOP:
            % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
            %% trial end
            Task_Finish(p);
            p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};
            ND_Trial2Ascii(p, 'save');
            
    end  %/ switch state
end  %/  if(nargin == 1) [...] else [...]

% ------------------------------------------------------------------------%
%% Task related functions

% ####################################################################### %
function TaskSetUp(p)
%% main task outline
% Determine everything here that can be specified/calculated before the actual trial start
p.trial.task.Timing.ITI  = ND_GetITI(p.trial.task.Timing.MinITI,  ...
    p.trial.task.Timing.MaxITI,  [], [], 1, 0.10);


p.trial.CurrEpoch        = p.trial.epoch.TrialStart;

% Reference distance to check if a wrong saccade is made
p.trial.behavior.fixation.refDist = NaN;

% Outcome if no fixation occurs at all during the trial
p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;

p.trial.task.Good                = 0;
p.trial.behavior.fixation.GotFix = 0;
p.trial.stim.GotFix              = 0;

pds.fixation.move(p);

p.trial.behavior.fixation.FixCol = p.trial.task.Color_list{mod(p.trial.blocks(p.trial.pldaps.iTrial), length(p.trial.task.Color_list))+1};


%% Reward

% Fixation spot
p.trial.behavior.fixation.fixPos = [0,0];
p.trial.behavior.fixation.FixType = 'disc';
pds.fixation.move(p)

%% Stimulus parameters

% Must set spatial frequency before generating the stimulus
p.trial.stim.grating.sFreq = datasample(p.trial.stim.sFreq,1);

% Generate the stimulus
p.trial.stim.grating1 = pds.stim.Grating(p,p.trial.stim.radius);

% Calculate the location of the stim
direction = p.trial.stim.locations{randi(length(p.trial.stim.locations))};
magnitude = p.trial.stim.eccentricity;
p.trial.stim.pos = magnitude * direction / norm(direction);
p.trial.stim.grating1.pos = p.trial.stim.pos;

% Stimulus angle
p.trial.stim.angle = datasample(p.trial.stim.orientations,1);
p.trial.stim.grating1.angle = p.trial.stim.angle;

% Other stim properties
p.trial.stim.grating1.tFreq = p.trial.stim.tFreq;


% stim starts off
p.trial.stim.on = 0;   % 0 is off, 1 is low contrast, 2 is high contrast
% ####################################################################### %
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
switch p.trial.CurrEpoch
    
    case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot       
        tms = pds.datapixx.strobe(p.trial.event.TASK_ON);
        p.trial.EV.DPX_TaskOn = tms(1);
        p.trial.EV.TDT_TaskOn = tms(2);
        
        p.trial.EV.TaskStart = p.trial.CurTime;
        p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
        
        if(p.trial.datapixx.TTL_trialOn)
            pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan, 1);
        end
        
        fixspot(p,1);
        p.trial.behavior.fixation.FixWin = p.trial.behavior.fixation.centralFixWin;
        pds.fixation.move(p)
        
        switchEpoch(p,'WaitFix');
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.WaitFix
        %% Fixation target shown, waiting for a sufficiently held gaze
        
        % Gaze is outside fixation window
        if p.trial.behavior.fixation.GotFix == 0
            
            % Fixation has occured
            if p.trial.FixState.Current == p.trial.FixState.FixIn
                p.trial.EV.FixSpotStart = p.trial.EV.FixStart;
                p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak; %Will become FullFixation upon holding long enough
                p.trial.behavior.fixation.GotFix = 1;
                
                % Time to fixate has expired
            elseif p.trial.CurTime > p.trial.EV.TaskStart + p.trial.task.Timing.WaitFix
                
                % Long enough fixation did not occur, failed trial
                p.trial.task.Good = 0;
                
                % Go directly to TaskEnd, do not start task, do not collect reward
                fixspot(p,0);
                switchEpoch(p,'TaskEnd');
                
            end
            
            
            % If gaze is inside fixation window
        elseif p.trial.behavior.fixation.GotFix == 1
            
            % Fixation ceases
            if p.trial.FixState.Current == p.trial.FixState.FixOut
                
                p.trial.EV.FixSpotStop = p.trial.EV.FixBreak;
                p.trial.behavior.fixation.GotFix = 0;
                
                % Fixation has been held for long enough && not currently in the middle of breaking fixation
            elseif (p.trial.CurTime > p.trial.EV.FixStart + p.trial.task.fixLatency) && p.trial.FixState.Current == p.trial.FixState.FixIn
                
                p.trial.outcome.CurrOutcome = p.trial.outcome.FullFixation;
                
                % Reward the monkey if there is initial reward for this trial
                if p.trial.reward.initialFixRwd > 0
                    pds.reward.give(p, p.trial.reward.initialFixRwd);
                    p.trial.EV.FirstReward = p.trial.CurTime;
                end
                
                % Transition to the succesful fixation epoch
                switchEpoch(p,'Fixating')
                
            end
            
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.Fixating
        %% Animal has reached fixation criteria and now starts receiving rewards for continued fixation
        
        % Still fixating
        if p.trial.FixState.Current == p.trial.FixState.FixIn
            
            % Wait stim latency before showing reward
            if ~p.trial.stim.on
                if p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.stimLatency
                    % Turn on stim
                    stim(p,1)
                end
                
                
            else
                
                % Must maintain fixation (inhibit saccade) until central
                % fixation spot disappears
                if p.trial.CurTime > p.trial.EV.StimOn + p.trial.task.centerOffLatency
                    
                    % Saccade has been inhibited long enough. Make the central fix spot disappear
                    p.trial.behavior.fixation.fixPos = p.trial.stim.pos;
                    p.trial.behavior.fixation.FixType = 'off';
                    p.trial.behavior.fixation.FixWin = p.trial.stim.FixWin;
                    pds.fixation.move(p);
                    p.trial.EV.FixOff = p.trial.CurTime;
                    pds.datapixx.strobe(p.trial.event.FIXSPOT_OFF);
                    p.trial.EV.FixSpotStop = p.trial.CurTime;
                    
                    
                    % Make the stim high contrast
                    stim(p,2)
                    
                    % Change to the saccade epoch
                    switchEpoch(p,'Saccade');
                    
                    % Record the current distance of the eye away from the stim as a reference
                    p.trial.behavior.fixation.refDist = sqrt(sum((p.trial.stim.pos - [p.trial.eyeX p.trial.eyeY]) .^ 2));
                    
                end
            
            end
            
            % Fixation Break, end the trial
        elseif p.trial.FixState.Current == p.trial.FixState.FixOut
            pds.audio.playDP(p,'breakfix','left');
            
            % If the stim is on when breakfix occurs, saccade is precocious
            p.trial.outcome.CurrOutcome = p.trial.outcome.earlySaccade;
            
            % Record time
            p.trial.EV.FixSpotStop = p.trial.EV.FixBreak;
            
            % Turn off fixspot and stim
            fixspot(p,0);
            stim(p,0);
            
            switchEpoch(p,'TaskEnd')
            
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.Saccade
        %% Central fixation spot has disappeared. Animal must quickly saccade to stim to get the main reward
        
        if ~p.trial.stim.GotFix
            % Animal has not yet saccaded to target
            % Need to check if no saccade has been made or if a wrong saccade has been made

            if p.trial.FixState.Current == p.trial.FixState.FixIn
                % Animal has saccaded to stim
                p.trial.stim.GotFix = 1;
                p.trial.EV.FixTargetStart = p.trial.EV.FixStart;


            elseif p.trial.eyeAmp > p.trial.behavior.fixation.refDist + p.trial.behavior.fixation.distInc
                % If the distance from the stim increases, a wrong saccade has been made

                p.trial.outcome.CurrOutcome = p.trial.outcome.wrongSaccade;

                % Turn the stim off and fixation off
                stim(p,0)
                fixspot(p,0)

                % Play an incorrect sound
                pds.audio.playDP(p,'incorrect','left');

                % End the trial
                switchEpoch(p,'TaskEnd');



            elseif p.trial.CurTime > p.trial.EV.FixOff + p.trial.task.saccadeTimeout
                % If no saccade has been made before the time runs out, end the trial

                p.trial.outcome.CurrOutcome = p.trial.outcome.noSaccade;

                % Turn the stim off and fixation off
                stim(p,0);
                fixspot(p,0);

                % Play an incorrect sound
                pds.audio.playDP(p,'incorrect','left');

                switchEpoch(p,'TaskEnd')              

            end

        else
            % Animal is currently fixating on target

            % Wait for animal to hold fixation for the required length of time
            % then give reward and mark trial good
            if p.trial.CurTime > p.trial.EV.FixStart + p.trial.task.minTargetFixTime
                p.trial.outcome.CurrOutcome = p.trial.outcome.goodSaccade;
                
                pds.reward.give(p, p.trial.reward.Dur);
                pds.audio.playDP(p,'reward','left');
                
                % Record main reward time
                p.trial.EV.Reward = p.trial.CurTime;
                
                % Turn off stim
                stim(p,0)
                
                % Record time fixation on stim ending
                p.trial.EV.FixTargetStop = p.trial.CurTime;
                
                p.trial.task.Good = 1;
                switchEpoch(p,'TaskEnd');


            elseif p.trial.FixState.Current == p.trial.FixState.FixOut
                % If animal's gaze leaves window, end the task and do not give reward
                p.trial.outcome.CurrOutcome = p.trial.outcome.glance;

                % Turn the stim off
                stim(p,0);

                % Record time fixation on stim ending
                p.trial.EV.FixTargetStop = p.trial.EV.FixBreak;
                
                % Play an incorrect sound
                pds.audio.playDP(p,'incorrect','left');

                switchEpoch(p,'TaskEnd')

            end

        end

        
        % ----------------------------------------------------------------%
    case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % set timer for intertrial interval
        tms = pds.datapixx.strobe(p.trial.event.TASK_OFF);
        p.trial.EV.DPX_TaskOff = tms(1);
        p.trial.EV.TDT_TaskOff = tms(2);
        
        p.trial.EV.TaskEnd = p.trial.CurTime;
        
        if(p.trial.datapixx.TTL_trialOn)
            pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan, 0);
        end
        
        % determine ITI
        switch p.trial.outcome.CurrOutcome
            
            case ~p.trial.task.Good
                % Timeout if task not performed correctly
                p.trial.task.Timing.ITI = p.trial.task.Timing.ITI + p.trial.task.Timing.TimeOut;
        end
        
        p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.ITI;
        
        p.trial.Timer.ITI  = p.trial.Timer.Wait;
        switchEpoch(p,'ITI');
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.ITI
        %% inter-trial interval: wait before next trial to start
        Task_WaitITI(p);
        
end  % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% show epoch dependent stimuli
% go through the task epochs as defined in TaskDesign and draw the stimulus
% content that needs to be shown during this epoch.

%% TODO: draw predicted eye pos for calibration grid, draw indicator for random posiiton vs. fix, indicate current position

if p.trial.behavior.fixation.enableCalib
    pds.eyecalib.draw(p)
end

if p.trial.behavior.fixation.on
    pds.fixation.draw(p);
end

if p.trial.stim.on == 1
    p.trial.stim.grating1.contrast = p.trial.stim.lowContrast;
    draw(p.trial.stim.grating1,p);
elseif p.trial.stim.on == 2
    p.trial.stim.grating1.contrast = p.trial.stim.highContrast;
    draw(p.trial.stim.grating1,p);
end



% ####################################################################### %
function KeyAction(p)
%% task specific action upon key press
if(~isempty(p.trial.LastKeyPress))
    
    switch p.trial.LastKeyPress(1)
        
        case KbName('p')  % change color ('paint')
            p.trial.task.Color_list = Shuffle(p.trial.task.Color_list);
            p.trial.task.FixCol     = p.trial.task.Color_list{mod(p.trial.blocks(p.trial.pldaps.iTrial), ...
                length(p.trial.task.Color_list))+1};
            
    end
    
    pds.fixation.move(p);
end

% ####################################################################### %
%% additional inline functions that
% ####################################################################### %
function switchEpoch(p,epochName)
p.trial.CurrEpoch = p.trial.epoch.(epochName);
p.trial.EV.epochEnd = p.trial.CurTime;

function fixspot(p,bool)
if bool
    p.trial.behavior.fixation.on = 1;
    p.trial.EV.FixOn = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.FIXSPOT_ON);
else
    p.trial.behavior.fixation.on = 0;
    p.trial.EV.FixOff = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.FIXSPOT_OFF);
end

function stim(p,val)
% Turn on/off or change the stim
oldVal = p.trial.stim.on;

% Don't do anything if stim doesn't change
if val == oldVal; return; end

if val == 0
    % Turn the stim off
    p.trial.stim.on = 0;
    p.trial.EV.StimOff = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.STIM_OFF);
    
elseif oldVal == 0
    % Stim is turning on
    p.trial.stim.on = val;
    p.trial.EV.StimOn = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.STIM_ON);
    
else
    % Stim is changing
    p.trial.stim.on = val;
    p.trial.EV.StimChange = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.STIM_CHNG);
end
