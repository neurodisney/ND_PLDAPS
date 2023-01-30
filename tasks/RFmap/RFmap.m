function p = RFmap(p, state)
% Presenting sequence of stimuli that allow offline calculation of visual receptive fields using reverse correlation

% Nate Faber, July/August 2017
% Anita Disney, May/June 2020

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
    
    p = ND_AddAsciiEntry(p, 'tFreq',       'p.trial.stim.GRATING.tFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'sFreq',       'p.trial.stim.GRATING.sFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'contrast',    'p.trial.stim.GRATING.contrast',       '%.1f');
    p = ND_AddAsciiEntry(p, 'StimSize',    '2*p.trial.stim.GRATING.radius',       '%.1f');
    
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'FixStart',    'p.trial.EV.FixSpotStart',             '%.5f');
    p = ND_AddAsciiEntry(p, 'FixBreak',    'p.trial.EV.FixSpotStop',              '%.5f');
    p = ND_AddAsciiEntry(p, 'FixDur',      'p.trial.task.fixDur',                 '%.5f');
    p = ND_AddAsciiEntry(p, 'TaskEnd',     'p.trial.EV.TaskEnd',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.behavior.fixation.FixWin',    '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwd',     'p.trial.EV.FirstReward',              '%.5f');
    p = ND_AddAsciiEntry(p, 'Reward',      'p.trial.EV.Reward',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'RewardDur',   'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)',           '%.5f');
    p = ND_AddAsciiEntry(p, 'TotalRwd',    'sum(p.trial.reward.timeReward(:,2))', '%.5f');
    
    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');
    
    % --------------------------------------------------------------------%
      %% Create stimulus log file
    % initialize a simple ascii file that logs the information of the gratings shown for the RF mapping
    
    p.trial.stimtbl.file = fullfile(p.defaultParameters.session.dir, ...
                                   [p.defaultParameters.session.filestem,'_Stimuli.csv']);
                               
    %---------------------------------------------------------------------%
    
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.
    
    
    % --------------------------------------------------------------------%
    %% Determine conditions and their sequence
    % define conditions (conditions could be passed to the pldaps call as
    % cell array, or defined here within the main trial function. The
    % control of trials, especially the use of blocks, i.e. the repetition
    % of a defined number of trials per condition, needs to be clarified.
    %---------------------------------------------------------------------%
    
    %% Allocate memory and reset counters
    p.trial.stim.count = 0;
    p.trial.pulse.count= 0;
    
    %---------------------------------------------------------------------%
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
            TaskCleanAndSave(p);
            %% trial end
            
            
    end  %/ switch state
end  %/  if(nargin == 1) [...] else [...]

% ------------------------------------------------------------------------%
%% Task related functions

% ####################################################################### %
function TaskSetUp(p)
%% main task outline
% Determine everything here that can be specified/calculated before the actual trial start
p.trial.task.Timing.ITI  = ND_GetITI(p.trial.task.Timing.MinITI,  ...
                            p.trial.task.Timing.MaxITI, ...
                            [], [], 1, 0.10);


p.trial.CurrEpoch        = p.trial.epoch.ITI;

% Flag to indicate if ITI was too long (set to 0 if ITI epoch is reached before it expires)

% Outcome if no fixation occurs at all during the trial
p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

p.trial.task.Good    = 0;
p.trial.task.fixFix  = 0;
p.trial.task.stimState = 0;

p.trial.task.fixDur = NaN;


%% Generate all the visual stimuli

% Fixation spot
p.trial.stim.fix = pds.stim.FixSpot(p);

% Gratings
% Generate all the possible gratings 
p.trial.stim.gratings = {};
stimdef = p.trial.stim.(p.trial.stim.RFmeth);
for ori = stimdef.ori
    p.trial.stim.GRATING.ori = ori;
    
    for radius = stimdef.radius
        p.trial.stim.GRATING.radius = radius;
        
        for sFreq = stimdef.sFreq
            p.trial.stim.GRATING.sFreq = sFreq;
            
            for tFreq = stimdef.tFreq
                p.trial.stim.GRATING.tFreq = tFreq;
                
                for contr = stimdef.contrast
                    p.trial.stim.GRATING.contrast = contr;
                    
                    p.trial.stim.gratings{end+1} = pds.stim.Grating(p);
                    
                end
            end
        end
    end
end

% Generate all the possible positions for the stimulus to be
allXPos = stimdef.xRange(1) : stimdef.grdStp : stimdef.xRange(2);
allYPos = stimdef.yRange(1) : stimdef.grdStp : stimdef.yRange(2);
p.trial.stim.locations = combvec(allXPos,allYPos)';


%% Generate a shuffled list of all possible stimuli and location indices for reference during the experiment
% Only do this the first trial, because stim sequence should continue between trials
if p.trial.stim.count == 0;
reshuffle_stims(p);
end

%% Preallocate memory for RF-calculations
% AD I think this code is NOT NEEDED, hangover for prior non-functional code that attempted real time RF calc
% maxFrames = p.trial.pldaps.maxFrames;

% Create a 3D matrix representing the locations of stimuli within the visual field across time
% x,y are 1 when a stimulus is present in that location, 0 otherwise. Each z position represents one frame
%spatialRes = p.trial.RF.spatialRes;
%p.trial.RF.visualField = nan(spatialRes,spatialRes,maxFrames);

% Create a 2D matrix representing the identity of the stimuli that were on
%p.trial.RF.stimsOn = nan(length(p.trial.stim.gratings),maxFrames);

%p.trial.RF.spikes = nan(p.trial.RF.maxSpikesPerTrial,1);
%p.trial.RF.nSpikes = 0;

% ####################################################################### %
function TaskDesign(p)
%% main task outline

% This gets set to 1, if a stim is turned on or off this frame
p.trial.stim.changeThisFrame = 0;

% The different task stages (i.e. 'epochs') are defined here.
switch p.trial.CurrEpoch
    
    case p.trial.epoch.ITI
        %% inter-trial interval: wait until sufficient time has passed from the last trial
        Task_WaitITI(p);        
%         if p.trial.CurTime < p.trial.EV.PlanStart
%             % All intertrial processing was completed before the ITI expired
%             p.trial.task.longITI = 0;
%             
%         else
%             if isnan(p.trial.EV.PlanStart)
%                 % First trial, or after a break
%                 p.trial.task.longITI = 0;
%             end
%             
%             % If intertrial processing took too long, display a warning
%             if p.trial.task.longITI
%                 warning('ITI exceeded intended duration of by %.2f seconds!', ...
%                          p.trial.CurTime - p.trial.EV.PlanStart)
%             end
%             
%             ND_SwitchEpoch(p,'TrialStart');
%             
%         end
        
        % ----------------------------------------------------------------%    
    case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot       
        tms = pds.datapixx.strobe(p.trial.event.TASK_ON);
        p.trial.EV.DPX_TaskOn = tms(1);
        p.trial.EV.TDT_TaskOn = tms(2);
        
        p.trial.EV.TaskStart = p.trial.CurTime;
        p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
        
        if(p.trial.datapixx.TTL_trialOn)
            pds.datapixx.TTL(p.trial.datapixx.TTL_trialOnChan, 1);
        end
        
        fixspot(p,1);
        
        ND_SwitchEpoch(p,'WaitFix');
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.WaitFix
        %% Fixation target shown, waiting for a sufficiently held gaze
        
        % Gaze is outside fixation window
        if p.trial.task.fixFix == 0
            
            % Fixation has occured
            if p.trial.stim.fix.fixating
                p.trial.task.fixFix = 1;
                
                
                % Time to fixate has expired
            elseif p.trial.CurTime > p.trial.EV.TaskStart + p.trial.task.Timing.WaitFix
                           
                % Long enough fixation did not occur, failed trial
                p.trial.task.Good = 0;
                p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;
                
                % Go directly to TaskEnd, do not start task, do not collect reward
                fixspot(p,0);
                ND_SwitchEpoch(p,'TaskEnd');
                
            end
            
            % If gaze is inside fixation window
        elseif p.trial.task.fixFix == 1
            
            % Fixation ceases
            if ~p.trial.stim.fix.fixating
                
                p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                % Turn off the spot and end the trial
                fixspot(p,0);
                ND_SwitchEpoch(p,'TaskEnd');
                
                % Fixation has been held for long enough
            elseif (p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.fixLatency)
                
                % Turn the first stim on
                stim(p,1);
                
                % Set the timer for the first reward
                p.trial.EV.nextReward = p.trial.CurTime + p.trial.reward.Period;
                
                % Transition to the succesful fixation epoch
                ND_SwitchEpoch(p,'Fixating')
                
            end
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.Fixating
        %% Initial reward has been given (if it is not 0), now stim target will appear
        
        % Still fixating
        if p.trial.stim.fix.fixating
               
             % Jackpot time has not yet been reached
            if p.trial.CurTime < p.trial.stim.fix.EV.FixStart + p.trial.task.jackpotTime 
                
                %send the event code_CR
                %pds.datapixx.strobe(p.trial.datapixx.TTL_InjStrobe);
               
    
                % If stim count goes above the total number of generated stimuli/positions, reshuffle the stims and start again
                if p.trial.stim.count > length(p.trial.stim.iStim)
                    reshuffle_stims(p); 
                end

%                 % When stage is switched to fine, count is reset at 0, display no stims and wait for jackpot
%                 if p.trial.stim.count == 0
%                     stim(p,0);
%                     return;
%                 end
                
                % Reward if reward period has elapsed
                if p.trial.CurTime >= p.trial.EV.nextReward
                    % Give reward if it is enabled
                    if p.trial.reward.Dur > 0
                        pds.reward.give(p, p.trial.reward.Dur);
                    end
                    
                    % Reset the reward timer
                    p.trial.EV.nextReward = p.trial.CurTime + p.trial.reward.Period;
                    end
                
                if p.trial.task.stimState
                    % Keep stim on for stimOn Time
                    if p.trial.CurTime > p.trial.EV.StimOn + p.trial.task.stimOnTime
                        % Full stimulus presentation has occurred
                     
                        % Turn stim off
                        stim(p,0);
                        
                        % Increment stim counter
                        p.trial.stim.count = p.trial.stim.count + 1;
                        p.trial.pulse.count = p.trial.pulse.count + 1;
                        
                        if p.trial.datapixx.TTL_ON == 1  
                         
                         %run the pulses_CR
                            if p.trial.pulse.count <= 3 
                                
                               %Send the event code_CR
                               pds.datapixx.strobe(p.trial.datapixx.TTL_InjStrobe);
                                
                               %Run the Pulses_CR
                                pds.datapixx.TTL(p.trial.datapixx.TTL_chan, 1, p.trial.datapixx.TTL_PulseDur);
                            end
                        end    
                    end
                    
                elseif ~p.trial.task.stimState
                    % Wait the stim off period before displaying the next stimuli
                    if p.trial.CurTime > p.trial.EV.StimOff + p.trial.task.stimOffTime
                        % Turn stim on
                        stim(p,1);
                    end
                    
                end
                
            else
                % Monkey has fixated long enough to get the jackpot
                p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
                
%                 % Do incremental rewards (if enabled)
%                 if(p.trial.reward.IncrConsecutive == 1)
%                     AddPulse = find(p.trial.reward.PulseStep <= p.trial.LastHits+1, 1, 'last');
%                     if(~isempty(AddPulse))
%                         p.trial.reward.jackpotnPulse = p.trial.reward.jackpotnPulse + AddPulse;
%                     end
%                     
%                     fprintf('     REWARD!!!  [%d pulse(s) for %d subsequent correct trials]\n\n', ...
%                         p.trial.reward.jackpotnPulse, p.trial.LastHits+1);
%                 end
                
                pds.reward.give(p, p.trial.reward.Dur, p.trial.reward.jackpotnPulse);
                pds.audio.playDP(p,'jackpot','left');
                
                % Record main reward time
                p.trial.EV.Reward = p.trial.CurTime;
                
                % Turn off fixspot and stim
                fixspot(p,0);
                stim(p,0);
                
                p.trial.task.Good = 1;
                ND_SwitchEpoch(p,'TaskEnd');
            end
                
        elseif ~p.trial.stim.fix.fixating
            % Fixation Break, end the trial
            pds.audio.playDP(p,'breakfix','left');
            
            p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
            ND_SwitchEpoch(p,'TaskEnd')
            
            % Turn off fixspot and stim
            fixspot(p,0);
            stim(p,0);
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % Run standard TaskEnd routine
        Task_OFF(p);
        
        % Grab the fixation stopping and starting values from the stim properties
        p.trial.EV.FixSpotStart = p.trial.stim.fix.EV.FixStart;
        p.trial.EV.FixSpotStop  = p.trial.stim.fix.EV.FixBreak;
        
        % Calculate the total fixation duration
        currOutcome = p.trial.outcome.CurrOutcome;
        if(currOutcome == p.trial.outcome.Correct)
            fixDur = p.trial.EV.TaskEnd - p.trial.EV.FixStart;
        elseif(currOutcome == p.trial.outcome.FixBreak)
            fixDur = p.trial.EV.FixBreak - p.trial.EV.FixStart;
        else
            fixDur = NaN;
        end
        
        p.trial.task.fixDur = fixDur;
      
        
        % Flag next trial ITI is done at begining
        p.trial.flagNextTrial = 1;
        
        % ----------------------------------------------------------------%
        
end  % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% Custom draw function for this experiment


% ####################################################################### %
function TaskCleanAndSave(p)
%% Clean up textures, variables, and save useful info to ascii table
Task_Finish(p);

% Get the text name of the outcome
p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

% Save useful info to an ascii table for plotting
ND_Trial2Ascii(p, 'save');

% ####################################################################### %
function KeyAction(p)
%% task specific action upon key press
SS.key.reward    = KbName('space');  % trigger reward
SS.key.quit      = KbName('ESCAPE'); % end experiment
SS.key.pause     = KbName('p');      % pause the experiment
SS.key.break     = KbName('b');      % give a break
SS.key.CtrJoy    = KbName('j');      % set current joystick position as zero


%% additional inline functions
% ####################################################################### %

function fixspot(p,bool)
if bool && ~p.trial.stim.fix.on
    p.trial.stim.fix.on = 1;
elseif ~bool && p.trial.stim.fix.on
    p.trial.stim.fix.on = 0;
end


function stim(p,val)
% Turn on/off or change the stim
oldVal = p.trial.task.stimState;

% Don't do anything if stim doesn't change
if val == oldVal; return; end

% Indicate that a stim has been turned on or off this frame
p.trial.stim.changeThisFrame = 1;

p.trial.task.stimState = val;

% Turn on/off the appropriate generated stimuli
% Only use the fixation window of the high contrast stimulus to avoid problems with overlapping fix windows
switch val
    case 0
        % Turn off all stimuli (as a precaution)
        for grating = p.trial.stim.gratings
            grating{1}.on = 0;
        end
        
    case 1
        % Select the proper stim
        stimNum = p.trial.stim.count;
        stim = p.trial.stim.gratings{p.trial.stim.iStim(stimNum)};
        
        % Move the stim to the proper position
        curPos = p.trial.stim.locations(p.trial.stim.iPos(stimNum,:),:);
        stim.pos = curPos;
        
        % Make the stim visible
        stim.on = 1;
              
    otherwise
        error('bad stim value')
end


function reshuffle_stims(p)
% Get the number of stimuli and positions
nStims = length(p.trial.stim.gratings);
nLocs = size(p.trial.stim.locations,1);

% Rerandomize the list of stimuli
indexReference = Shuffle(combvec(1:nStims,1:nLocs)');
p.trial.stim.iStim = indexReference(:,1);
p.trial.stim.iPos = indexReference(:,2);

p.trial.stim.count = 1;   