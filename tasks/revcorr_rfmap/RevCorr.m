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
        

    
    %% Preallocate data and reset counters
    new_neuron(p);   
    
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
            
            ProcessSpikes(p);
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


p.trial.CurrEpoch        = p.trial.epoch.ITI;

% Flag to indicate if ITI was too long (set to 0 if ITI epoch is reached before it expires)
%p.trial.task.longITI = 1;

% Outcome if no fixation occurs at all during the trial
p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

p.trial.task.Good    = 0;
p.trial.task.fixFix  = 0;
p.trial.task.stimState = 0;

p.trial.task.fixDur = NaN;

%% Switch modes or reset RF data based on flags
if p.trial.RF.flag_fine
    switch_to_fine(p);
end

if p.trial.RF.flag_new
    new_neuron(p);
end

%% Generate all the visual stimuli

% Fixation spot
p.trial.stim.fix = pds.stim.FixSpot(p);

% Gratings
% Generate all the possible gratings 
p.trial.stim.gratings = {};
stimdef = p.trial.stim.(p.trial.stim.stage);
for angle = stimdef.angle
    p.trial.stim.GRATING.ori = angle;
    
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
maxFrames = p.trial.pldaps.maxFrames;

% Create a 3D matrix representing the locations of stimuli within the visual field across time
% x,y are 1 when a stimulus is present in that location, 0 otherwise. Each z position represents one frame
spatialRes = p.trial.RF.spatialRes;
p.trial.RF.visualField = nan(spatialRes,spatialRes,maxFrames);

% Create a 2D matrix representing the identity of the stimuli that were on
p.trial.RF.stimsOn = nan(length(p.trial.stim.gratings),maxFrames);

p.trial.RF.spikes = nan(p.trial.RF.maxSpikesPerTrial,1);
p.trial.RF.nSpikes = 0;

%% Read and forget all the spikes that occured during the ITI
if p.trial.tdt.use
    pds.tdt.readSpikes(p);
end

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
%             switchEpoch(p,'TrialStart');
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
                
                % Set the timer for the first reward
                p.trial.EV.nextReward = p.trial.CurTime + p.trial.reward.Period;
                
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
                        % TODO: Record data here
                     
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
        Task_OFF(p);
        
        % Grab the fixation stopping and starting values from the stim properties
        p.trial.EV.FixSpotStart = p.trial.stim.fix.EV.FixStart;
        p.trial.EV.FixSpotStop  = p.trial.stim.fix.EV.FixBreak;
        
        % Calculate the total fixation duration
        currOutcome = p.trial.outcome.CurrOutcome;
        if currOutcome == p.trial.outcome.Correct
            fixDur = p.trial.EV.TaskEnd - p.trial.EV.FixStart;
        elseif currOutcome == p.trial.outcome.FixBreak
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

    % Make a vector to indicate whether or not each of the stimuli was on during this frame
    stimsOn = zeros(length(p.trial.stim.gratings),1);
    
    % For each stimulus, if the stimulus is on, interpolate a circle of 1's onto where it would be in the visual field
    for iGrating = 1:length(p.trial.stim.gratings)
        stim = p.trial.stim.gratings{iGrating};
        if stim.on
            % Record that the stimulus was on
            stimsOn(iGrating) = 1;
            
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
    
    % Add the stim on information to the history
    p.trial.RF.stimsOn(:,iFrame) = stimsOn;
    
else
    p.trial.RF.visualField(:,:,iFrame) = p.trial.RF.visualField(:,:,iFrame - 1);
    p.trial.RF.stimsOn(:,iFrame) = p.trial.RF.stimsOn(:,iFrame - 1);
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
p.trial.RF.stimsOn(:,p.trial.iFrame:end) = [];
p.trial.RF.spikes(p.trial.RF.nSpikes+1:end,:) = [];

% Get the text name of the outcome
p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

% Save useful info to an ascii table for plotting
ND_Trial2Ascii(p, 'save');

% ####################################################################### %
function Calculate_RF(p)
nSpikes = p.trial.RF.nSpikes;
stimdef = p.trial.stim.(p.trial.stim.stage);
rfdef = p.trial.RF.(p.trial.stim.stage);

% Don't add anymore information to matrices if switching to fine or creating a new map
if p.trial.RF.flag_new || p.trial.RF.flag_fine
    return;
end

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
        
        % Don't interpolate if this spike has the same time as the last one
        if iSpike > 1 && spikeTime == p.trial.RF.spikes(iSpike - 1)
            spikeHyperCube(:,:,:,iSpike) = spikeHyperCube(:,:,:,iSpike-1);
            continue;
        end
        
        % Generate the times to use for interpolation
        timeRange = spikeTime + p.trial.RF.(p.trial.stim.stage).temporalRange;
        times = linspace(timeRange(1), timeRange(2), tRes);
        
        % Interpolate the visual field during the time before each spike
        spikeCube = interp1(t,Vf,times,'previous',0);
        
        % Rearrange the dimensions again
        spikeCube = permute(spikeCube,[2,3,1]);
        
        % Add the spikeCube to the spikeHyperCube
        spikeHyperCube(:,:,:,iSpike) = spikeCube;
    end
    
    % Save this trial's spikeHyperCube to p
    rfdef.spikeHyperCube = spikeHyperCube;
    
    % Average across all spikes
    meanCube = mean(spikeHyperCube, 4);
    
    % And combine this average with the results from previous trials (weighting, of course, by number of spikes)
    if rfdef.nAllSpikes == 0
        rfdef.revCorrCube = meanCube;
    else
        rfdef.revCorrCube = (meanCube * nSpikes + rfdef.revCorrCube * rfdef.nAllSpikes) / (nSpikes + rfdef.nAllSpikes);    
    end
    
    % Generate a positional heatmap by taking the maximum value across the time dimension
    rfdef.heatmap = max(rfdef.revCorrCube, [], 3);
      
    % Find the location with the highest density of spike responses
    [maxRow, maxCol] = ind2sub(size(rfdef.heatmap),find(rfdef.heatmap == max(max(rfdef.heatmap)),1));
    xSpace = linspace(rfdef.xRange(1), rfdef.xRange(2), p.trial.RF.spatialRes);
    ySpace = linspace(rfdef.yRange(1), rfdef.yRange(2), p.trial.RF.spatialRes);
    maxPos = [xSpace(maxCol), ySpace(maxRow)];
    maxInd = [maxRow, maxCol];
    
    % Save this to the p struct
    rfdef.maxPos = maxPos;
    rfdef.maxInd = maxInd;
    
    if rfdef.useCustPos
        selectPos = rfdef.custPos;
        selectInd = rfdef.custInd;
    else
        selectPos = maxPos;
        selectInd = maxInd;
    end
    
    % Calculate the temporal profile (when stims appeared) for this max location
    temporalProfile = squeeze(rfdef.revCorrCube(selectInd(1), selectInd(2), :));
    
    
    % Change processing depending on the stage
    if strcmp(p.trial.stim.stage, 'coarse')
        
        % Define the xRange and yRange for the fine stage
        p.trial.stim.fine.xRange = selectPos(1) + [-p.trial.stim.fine.extent, p.trial.stim.fine.extent];
        p.trial.stim.fine.yRange = selectPos(2) + [-p.trial.stim.fine.extent, p.trial.stim.fine.extent];

        % Find the maximum value in the temporal profile
        [maxVal, maxIndex] = max(temporalProfile);
        times = linspace(rfdef.temporalRange(1), rfdef.temporalRange(2), p.trial.RF.temporalRes);
        rfdef.timeOfMax = times(maxIndex);

        %% Find the times when the temporal profile goes below the threshold proportion of the max value
        thresh = p.trial.RF.temporalProfileRefineProportion * maxVal;

        % Get the part of temporal profile before the max value point
        lowerProf = temporalProfile(1:maxIndex);
        % Find the closest point to the max value where the profile goes beneath threshold
        lowerThreshTime = times(find(lowerProf < thresh, 1, 'last'));
        if isempty(lowerThreshTime) || lowerThreshTime < rfdef.temporalRange(1)
            minFineRange = rfdef.temporalRange(1);
        else
            minFineRange = lowerThreshTime;
        end

        % Get the part of the temporal profile after the max value point
        upperProf = temporalProfile(maxIndex:end);
        upperThreshTime = times(maxIndex -1 + find(upperProf < thresh, 1, 'first'));
        if isempty(upperThreshTime) || upperThreshTime > rfdef.temporalRange(2)
            maxFineRange = rfdef.temporalRange(2);
        else
            maxFineRange = upperThreshTime;
        end

        % Assign this new temporal range
        p.trial.RF.fine.temporalRange = [minFineRange, maxFineRange];
        
    elseif strcmp(p.trial.stim.stage, 'fine')
        % TODO: store final receptive field position
        
        
        %% Calculate the presence of individual stims before each spike
        % Preallocate a 3D matrix to hold the stim/spike information
        % (stim, time, nSpike)
        nStims = length(p.trial.stim.gratings);
        spikeStimsCube = nan(nStims, tRes, nSpikes);
        
        % Get the stim information for the trials (transpose so that time dimension is first)
        stimsOn = p.trial.RF.stimsOn';
        
        % For each spike, interpolate the stims that are on before the spike into consistent slices
        for iSpike = 1:nSpikes
            spikeTime = p.trial.RF.spikes(iSpike);
            
            % Don't interpolate if this spike has the same time as the last one
            if iSpike > 1 && spikeTime == p.trial.RF.spikes(iSpike - 1)
                spikeStimsCube(:,:,iSpike) = spikeStimsCube(:,:,iSpike-1);
                continue;
            end
            
            % Generate the times to use for interpolation
            timeRange = spikeTime + p.trial.RF.(p.trial.stim.stage).temporalRange;
            times = linspace(timeRange(1), timeRange(2), tRes);
            
            % Interpolate the visual field during the time before each spike
            spikeStims = interp1(t, stimsOn, times, 'previous', 0)';
            
            % Add the spikeStims to the spikeStimCube
            spikeStimsCube(:,:,iSpike) = spikeStims;
        end
        
        % Save this trial's spikeStimsCube to p
        rfdef.spikeStimsCube = spikeStimsCube;
        
        % Average across all spikes
        meanSpikeStimsCube = mean(spikeStimsCube, 3);
        
        % And combine this average with the result from previous trials
        if rfdef.nAllSpikes == 0
            rfdef.revCorrStims = meanSpikeStimsCube;
        else
            rfdef.revCorrStims = (meanSpikeStimsCube * nSpikes + rfdef.revCorrStims * rfdef.nAllSpikes) / (nSpikes + rfdef.nAllSpikes);
        end
        
        % revCorrStims is a 2D matrix (stim, time), with each value being the proportion of spikes that had stim on at time
        % before it occured.
        
        %% Calculate orientation tuning
        nOrients = length(stimdef.angle);
        
        % Create matrix showing the mapping from stims to orientations
        % stims x orientations
        stims2angle = false(nStims, nOrients);
        for iStim = 1:nStims
            stim = p.trial.stim.gratings{iStim};
            angle = stim.angle;
            stims2angle(iStim, stimdef.angle == angle) = true;
        end
        
        % First preallocate. Each number here will represent the proportion of spikes that occured following each of the orientations
        rfdef.orientationTuning = nan(1,nOrients);
        
        % Now for each orientation, grab the appropriate stims from the spikeStimsCube,
        % and average the spike response to orientation across all spikes
        for iOrient = 1:nOrients
            iStims = stims2angle(:, iOrient);
            
            % Sum across stims that have the same orientation,
            % and take the max value in time as the orientation tuning
            rfdef.orientationTuning(iOrient) = max(sum(rfdef.revCorrStims(iStims,:), 1));
            
        end
        
    end

    % Increment the total spikes
    rfdef.nAllSpikes = rfdef.nAllSpikes + nSpikes;
    
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
            % Start new neuron on next trial
            p.trial.RF.flag_new = 1;
            
        case KbName('f')
            % Switch to fine mode on next trial
            p.trial.RF.flag_fine = 1;
            
        case KbName('s')
            % Allow manual spiking to be triggered if TDT is not used
            if ~p.trial.tdt.use
                p.trial.RF.nSpikes = p.trial.RF.nSpikes + 1;
                p.trial.RF.spikes(p.trial.RF.nSpikes) = p.trial.CurTime;
            end
            
    end
    
end

% ####################################################################### %

function ProcessSpikes(p)
% Get all the incoming spikes from TDT and then process the spike counts
if p.trial.tdt.use
    % Load in the spikes
    spikes = p.trial.tdt.spikes;
    
    % Sum across all specified channels and sort codes
    channels = p.trial.RF.channels;
    sortCodes = p.trial.RF.sortCodes;
    newSpikes = sum(sum(spikes(channels, sortCodes)));
    
    % Add to the list of spikes at the current time
    if newSpikes > 0
        nSpikeRange = p.trial.RF.nSpikes+1 : p.trial.RF.nSpikes+newSpikes;
        p.trial.RF.spikes(nSpikeRange) = p.trial.CurTime;
        p.trial.RF.nSpikes = p.trial.RF.nSpikes + newSpikes;
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

% Reset spike counts
p.trial.RF.coarse.nAllSpikes = 0;
p.trial.RF.fine.nAllSpikes = 0;

% Remove all data
p.trial.RF.coarse.revCorrCube = [];
p.trial.RF.fine.revCorrCube = [];
p.trial.RF.fine.revCorrStims = [];
p.trial.stim.fine.xRange = NaN;
p.trial.stim.fine.yRange = NaN;

% Use automatic position again
p.trial.RF.coarse.useCustPos = 0;
p.trial.RF.fine.useCustPos = 0;

% Reset flags
p.trial.RF.flag_new = 0;
p.trial.RF.flag_fine = 0;

function switch_to_fine(p)

% Switch to fine mapping, or reset the fine mapping step
p.trial.stim.stage = 'fine';
p.trial.stim.count = 0;

% Clear the last coarse trial's hypercube out of memory so it is not continually resaved to disk
p.trial.RF.coarse.spikeHyperCube = [];

% Reset fine data (to allow for retrying fine calibration midway)
p.trial.RF.fine.nAllSpikes = 0;

% Reset flag
p.trial.RF.flag_fine = 0;
      
