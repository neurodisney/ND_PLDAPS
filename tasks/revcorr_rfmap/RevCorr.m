function p = RevCorr(p, state)
% Calculating receptive fields using reverse correlation of stimuli with spike data
% 
%
%
% Nate Faber, July/August 2017

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
    p = ND_AddAsciiEntry(p, 'tFreq',       'p.trial.stim.GRATING.tFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'sFreq',       'p.trial.stim.GRATING.sFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'contrast',    'p.trial.stim.GRATING.contrast',       '%.1f');
    p = ND_AddAsciiEntry(p, 'StimSize',    '2*p.trial.stim.GRATING.radius',       '%.1f');
    
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOn',      'p.trial.EV.StimOn',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOff',     'p.trial.EV.StimOff',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'FixStart',    'p.trial.EV.FixSpotStart',             '%.5f');
    p = ND_AddAsciiEntry(p, 'FixBreak',    'p.trial.EV.FixSpotStop',              '%.5f');
    p = ND_AddAsciiEntry(p, 'StimFix',     'p.trial.EV.FixTargetStart',           '%.5f');
    p = ND_AddAsciiEntry(p, 'StimBreak',   'p.trial.EV.FixTargetStop',            '%.5f');
    p = ND_AddAsciiEntry(p, 'TaskEnd',     'p.trial.EV.TaskEnd',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.behavior.fixation.FixWin',    '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwd',     'p.trial.EV.FirstReward',              '%.5f');
    p = ND_AddAsciiEntry(p, 'Reward',      'p.trial.EV.Reward',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'RewPulses',   'p.trial.reward.nPulse',               '%.5f');
    p = ND_AddAsciiEntry(p, 'RewardDur',   'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)',           '%.5f');
    p = ND_AddAsciiEntry(p, 'TotalRwd',    'sum(p.trial.reward.timeReward(:,2))', '%.5f');
    
    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');
    
    % --------------------------------------------------------------------%
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
    
    p.trial.stim.count = 0;
    p.trial.stim.stage = 'coarse';
    
    p.trial.RF.coarse.revCorrCube = NaN;
    p.trial.RF.fine.revCorrCube = NaN;
    
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
            Make_RF_VisualField(p);
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
            Calculate_RF(p);
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
    p.trial.task.Timing.MaxITI,  [], [], 1, 0.10);


p.trial.CurrEpoch        = p.trial.epoch.TrialStart;


% Outcome if no fixation occurs at all during the trial
p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

p.trial.task.Good    = 0;
p.trial.task.fixFix  = 0;
p.trial.task.stimState = 0;

%% Generate all the visual stimuli

% Fixation spot
p.trial.stim.fix = pds.stim.FixSpot(p);

% Gratings
% Generate all the possible gratings 
p.trial.stim.gratings = {};
stimdef = p.trial.stim.(p.trial.stim.stage);
for angle = stimdef.angle
    p.trial.stim.GRATING.angle = angle;
    
    for radius = stimdef.radius
        p.trial.stim.GRATING.radius = radius;
        
        for sFreq = stimdef.sFreq
            p.trial.GRATING.sFreq = sFreq;
            
            for tFreq = stimdef.tFreq
                p.trial.GRATING.tFreq = tFreq;
                
                for contr = stimdef.contrast
                    p.trial.GRATING.contrast = contr;
                    
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
maxFrames = p.trial.pldaps.maxFrames;

% Create a 3D matrix representing the locations of stimuli within the visual field across time
% x,y are 1 when a stimulus is present in that location, 0 otherwise. Each z position represents one frame
spatialRes = p.trial.RF.spatialRes;
p.trial.RF.visualField = nan(spatialRes,spatialRes,maxFrames);

p.trial.RF.spikes = nan(p.trial.RF.maxSpikesPerTrial,1);
p.trial.RF.nSpikes = 0;


% ####################################################################### %
function TaskDesign(p)
%% main task outline

% This gets set to 1, if a stim is turned on or off this frame
p.trial.stim.changeThisFrame = 0;

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
        
        switchEpoch(p,'WaitFix');
        
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
                switchEpoch(p,'TaskEnd');
                
            end
            
            
            % If gaze is inside fixation window
        elseif p.trial.task.fixFix == 1
            
            % Fixation ceases
            if ~p.trial.stim.fix.fixating
                
                p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                % Turn off the spot and end the trial
                fixspot(p,0);
                switchEpoch(p,'TaskEnd');
                
                % Fixation has been held for long enough
            elseif (p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.fixLatency)
                
                % Turn the first stim on
                stim(p,1)
                
                % Transition to the succesful fixation epoch
                switchEpoch(p,'Fixating')
                
            end
            
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.Fixating
        %% Initial reward has been given (if it is not 0), now stim target will appear
        
        % Still fixating
        if p.trial.stim.fix.fixating
            
            if p.trial.CurTime < p.trial.stim.fix.EV.FixStart + p.trial.task.jackpotTime
                % Jackpot time has not yet been reached
                
                % If stim count goes above the total number of generated stimuli/positions, reshuffle the stims and start again
                if p.trial.stim.count > length(p.trial.stim.iStim)
                    reshuffle_stims(p);
                end
                
                % When stage is switched to fine, count is reset at 0, display no stims and wait for jackpot
                if p.trial.stim.count == 0
                    stim(p,0);
                    return;
                end
                
                if p.trial.task.stimState
                    % Keep stim on for stimOn Time
                    if p.trial.CurTime > p.trial.EV.StimOn + p.trial.task.stimOnTime
                        % Full stimulus presentation has occurred
                        % TODO: Record data here
                        
                        % Give reward if it is enabled
                        if p.trial.reward.Dur > 0
                            pds.reward.give(p, p.trial.reward.Dur);
                        end
                        
                        % Turn stim off
                        stim(p,0)
                        
                        % Increment stim counter
                        p.trial.stim.count = p.trial.stim.count + 1;
                    end
                    
                elseif ~p.trial.task.stimState
                    % Wait the stim off period before displaying the next stimuli
                    if p.trial.CurTime > p.trial.EV.StimOff + p.trial.task.stimOffTime
                        % Turn stim on
                        stim(p,1)
                    end
                    
                end
                
            else
                % Monkey has fixated long enough to get the jackpot
                p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
                
                % Do incremental rewards (if enabled)
                if(p.trial.reward.IncrConsecutive == 1)
                    AddPulse = find(p.trial.reward.PulseStep <= p.trial.LastHits+1, 1, 'last');
                    if(~isempty(AddPulse))
                        p.trial.reward.nPulse = p.trial.reward.nPulse + AddPulse;
                    end
                    
                    fprintf('     REWARD!!!  [%d pulse(s) for %d subsequent correct trials]\n\n', ...
                        p.trial.reward.nPulse, p.trial.LastHits+1);
                end
                
                pds.reward.give(p, p.trial.reward.Dur, p.trial.reward.nPulse);
                pds.audio.playDP(p,'jackpot','left');
                
                % Record main reward time
                p.trial.EV.Reward = p.trial.CurTime;
                
                % Turn off fixspot and stim
                fixspot(p,0);
                stim(p,0);
                
                p.trial.task.Good = 1;
                switchEpoch(p,'TaskEnd');
                
            end
                
           
        elseif ~p.trial.stim.fix.fixating
            % Fixation Break, end the trial
            pds.audio.playDP(p,'breakfix','left');
            
            p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
            switchEpoch(p,'TaskEnd')
            
            % Turn off fixspot and stim
            fixspot(p,0);
            stim(p,0);
          
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % Run standard TaskEnd routine
        Task_OFF(p)
        
        % Grab the fixation stopping and starting values from the stim properties
        p.trial.EV.FixSpotStart = p.trial.stim.fix.EV.FixStart;
        p.trial.EV.FixSpotStop  = p.trial.stim.fix.EV.FixBreak;
      
        switchEpoch(p,'ITI');
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.ITI
        %% inter-trial interval: wait before next trial to start
        Task_WaitITI(p);
        
end  % switch p.trial.CurrEpoch

% ####################################################################### %
function Make_RF_VisualField(p)
%% Generate the RF visual stimulus grid for this frame. Used for calculating reverse correlation

iFrame = p.trial.iFrame;

% Only recalculate this is a change has occured, otherwise just copy from the last frame
if p.trial.stim.changeThisFrame || iFrame == 1
    stimdef = p.trial.stim.(p.trial.stim.stage);

    % Find the x's and y's of the area of interest
    xmin = stimdef.xRange(1) - stimdef.radius;
    xmax = stimdef.xRange(2) + stimdef.radius;
    ymin = stimdef.yRange(1) - stimdef.radius;
    ymax = stimdef.yRange(2) + stimdef.radius;
    sRes = p.trial.RF.spatialRes;
    
    % Save these values for plotting later
    p.trial.RF.(p.trial.stim.stage).xRange = [xmin xmax];
    p.trial.RF.(p.trial.stim.stage).yRange = [ymin ymax];

    [Xv,Yv] = meshgrid(linspace(xmin,xmax,sRes),linspace(ymin,ymax,sRes));

    % Generate a matrix of zeros representing the relevant visual plane
    Vv = zeros(sRes);

    % Generate a circle of 1's, which will be interpolated to the right size and location later
    [Xc, Yc] = meshgrid(-10:10);
    onecirc = double((Xc.^2 + Yc.^2) <= 100);
    circRes = size(onecirc,1);

    % For each stimulus, if the stimulus is on, interpolate a circle of 1's onto where it would be in the visual field
    for iGrating = 1:length(p.trial.stim.gratings)
        stim = p.trial.stim.gratings{iGrating};
        if stim.on
            radius = stim.radius;
            pos = stim.pos;

            % The correct x and y range for the stimulus
            xvals = linspace(pos(1) - radius, pos(1) + radius, circRes);
            yvals = linspace(pos(2) - radius, pos(2) + radius, circRes);
            [Xs, Ys] = meshgrid(xvals,yvals);
            

            % Interpolate the stimulus onto the visual space
            visFieldRep = interp2(Xs, Ys, onecirc, Xv, Yv, 'nearest', 0);

            % Now add it to the Vv (which represents all the visual stimuli
            Vv = Vv | visFieldRep;
        end
    end

    % Add the visual field representation to the history
    p.trial.RF.visualField(:,:,iFrame) = Vv;
    
else
    p.trial.RF.visualField(:,:,iFrame) = p.trial.RF.visualField(:,:,iFrame - 1);
end

% ####################################################################### %
function TaskDraw(p)
%% Custom draw function for this experiment


% ####################################################################### %
function TaskCleanAndSave(p)
%% Clean up textures, variables, and save useful info to ascii table
Task_Finish(p);

% Destroy the two grating textures generated to save memory
for grating = p.trial.stim.gratings
    Screen('Close', grating{1}.texture);
end

% Remove NaNs at the end of the RF data
p.trial.RF.visualField(:,:,p.trial.iFrame:end) = [];

% Get the text name of the outcome
p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

% Save useful info to an ascii table for plotting
ND_Trial2Ascii(p, 'save');

% ####################################################################### %
function Calculate_RF(p)
nSpikes = p.trial.RF.nSpikes;
if nSpikes > 0
    % Preallocate a 4D matrix to hold the visual field information for each spike
    % x,y,time,spike
    sRes = p.trial.RF.spatialRes;
    tRes = p.trial.RF.temporalRes;
    spikeHyperCube = nan(sRes, sRes, tRes, nSpikes);
    
    % Get the visual field information for this trial
    t = p.trial.AllCurTimes(1:end-1);
    % For 1D interpolation, interpolated dimension (time) must be first
    Vf = permute(p.trial.RF.visualField, [3, 1, 2]);
    
    % For each spike, interpolate the visual field occuring before it into consistent slices
    for iSpike = 1:nSpikes
        spikeTime = p.trial.RF.spikes(iSpike);
        
        % Generate the times to use for interpolation
        startTime = spikeTime - p.trial.RF.maxHistory;
        tRes = p.trial.RF.temporalRes;
        times = linspace(startTime, spikeTime, tRes);
        
        % Interpolate the visual field during the time before each spike
        spikeCube = interp1(t,Vf,times,'previous',0);
        
        % Rearrange the dimensions again
        spikeCube = permute(spikeCube,[2,3,1]);
        
        % Add the spikeCube to the spikeHyperCube
        spikeHyperCube(:,:,:,iSpike) = spikeCube;
    end
    
    % Append this trials spikeHyperCube to the one spanning all trials
    rfdef = p.trial.RF.(p.trial.stim.stage);
    
    if ~isfield(rfdef,'spikeHyperCube')
        rfdef.spikeHyperCube = spikeHyperCube;
    else
        rfdef.spikeHyperCube = cat(4, rfdef.spikeHyperCube, spikeHyperCube);
    end
    
    % Average across all spikes
    rfdef.revCorrCube = mean(rfdef.spikeHyperCube, 4);
    
    % Generate a positional heatmap by taking the maximum value across the time dimension
    rfdef.heatmap = max(rfdef.revCorrCube, [], 3);
    
    % Plot the heatmap
    subplot(1,2,1)
    xRange = p.trial.RF.(p.trial.stim.stage).xRange;
    yRange = p.trial.RF.(p.trial.stim.stage).yRange;
    imagesc(xRange, yRange, rfdef.heatmap);
    colormap('pink')
    hold on;
    
    % Plot the temporal density of the maximum point on the heatmap
    [maxRow, maxCol] = ind2sub(size(rfdef.heatmap),find(rfdef.heatmap == max(max(rfdef.heatmap)),1));
    rfdef.maxTemporalProfile = squeeze(rfdef.revCorrCube(maxRow, maxCol, :));
    
    subplot(1,2,2)
    plot(rfdef.maxTemporalProfile)
    
    drawnow
    
    
    % Save rfdef back into p
    p.trial.RF.(p.trial.stim.stage) = rfdef;
        
        
        
end

% ####################################################################### %

% ####################################################################### %
function KeyAction(p)
%% task specific action upon key press
if(~isempty(p.trial.LastKeyPress))
    
    switch p.trial.LastKeyPress(1)
        
        case KbName('n')  % Space for custom key press routines
            new_neuron(p)
            
        case KbName('f')
            switch_to_fine(p)
            
        case KbName('s')
            p.trial.RF.nSpikes = p.trial.RF.nSpikes + 1;
            p.trial.RF.spikes(p.trial.RF.nSpikes) = p.trial.CurTime;
            
    end
    
end

% ####################################################################### %
%% additional inline functions
% ####################################################################### %
function switchEpoch(p,epochName)
p.trial.CurrEpoch = p.trial.epoch.(epochName);
p.trial.EV.epochEnd = p.trial.CurTime;



function fixspot(p,bool)
if bool && ~p.trial.stim.fix.on
    p.trial.stim.fix.on = 1;
    p.trial.EV.FixOn = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.FIXSPOT_ON);
elseif ~bool && p.trial.stim.fix.on
    p.trial.stim.fix.on = 0;
    p.trial.EV.FixOff = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.FIXSPOT_OFF);
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
        p.trial.EV.StimOff = p.trial.CurTime;
        pds.datapixx.strobe(p.trial.event.STIM_OFF);
        
    case 1
        % Select the proper stim
        stimNum = p.trial.stim.count;
        stim = p.trial.stim.gratings{p.trial.stim.iStim(stimNum)};
        
        % Move the stim to the proper position
        curPos = p.trial.stim.locations(p.trial.stim.iPos(stimNum,:),:);
        stim.pos = curPos;
        
        % Make the stim visible
        stim.on = 1;
        
        % Record the timings
        p.trial.EV.StimOn = p.trial.CurTime;
        pds.datapixx.strobe(p.trial.event.STIM_ON); 
              
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

function new_neuron(p)
% Reset to coarse mapping
p.trial.stim.stage = 'coarse';
p.trial.stim.count = 0;

function switch_to_fine(p)
p.trial.stim.stage = 'fine';
p.trial.stim.count = 0;
      
