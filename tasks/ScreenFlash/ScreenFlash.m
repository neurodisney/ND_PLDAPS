function p = ScreenFlash(p, state)
% A stripped down task loop that is designed to flash the screen at a random interval with options for drug delivery via pressure injection.
%
%
% Nate Faber & wolf zinke, Sep 2017
% Corey Roach, May 2021


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
    % call this after ND_InitSession to be sure that output directory exists!
    
    p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%s');
    p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Tstart',      'p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart',   '%d');
    p = ND_AddAsciiEntry(p, 'FixRT',       'p.trial.EV.FixStart-p.trial.EV.TaskStart',                     '%d');
    p = ND_AddAsciiEntry(p, 'RewCnt',      'p.trial.reward.count',                '%d');
    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'FixPeriod',   'p.trial.EV.FixBreak-p.trial.EV.FixStart', '%.5f');
    p = ND_AddAsciiEntry(p, 'FixColor',    'p.trial.stim.FIXSPOT.color',          '%s');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');
    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.stim.fix.fixWin',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_X',    'p.trial.stim.fix.pos(1)',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_Y',    'p.trial.stim.fix.pos(2)',             '.%5f');
    
    
    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');

    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.
 
    p.trial.task.Color_list = {'white'};
    
    % --------------------------------------------------------------------%
    
    %% Determine conditions and their sequence
    % define conditions (conditions could be passed to the pldaps call as
    % cell array, or defined here within the main trial function. The
    % control of trials, especially the use of blocks, i.e. the repetition
    % of a defined number of trials per condition, needs to be clarified.


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
            TaskDraw(p)
            
% ------------------------------------------------------------------------%
% DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
            TaskCleanAndSave(p);
                        
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

    p.trial.CurrEpoch = p.trial.epoch.ITI;

    % Flag to indicate if ITI was too long (set to 0 if ITI epoch is reached before it expires)
    p.trial.task.longITI = 1;
      
    % Reward
    nRewards = p.trial.reward.nRewards;
    
    % Reset the reward counter (separate from iReward to allow for manual rewards)
    p.trial.reward.count = 0;
  
    % Outcome if no fixation occurs at all during the trial
    p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;        
    p.trial.task.Good   = 0;
    
    % State for acheiving fixation
    p.trial.task.fixFix = 0;
   
    % If the fixspot color is a cell, choose one of the strings from the cell to be the color
    if iscell(p.trial.stim.FIXSPOT.color)
       nColors = length(p.trial.stim.FIXSPOT.color);
       iColor = randi(nColors);
       p.trial.stim.FIXSPOT.color = p.trial.stim.FIXSPOT.color{iColor};
    end
        
    
    %% Make the visual stimuli
    % Fixation spot
    p.trial.stim.fix = pds.stim.FixSpot(p);
    
% ####################################################################### %
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
    switch p.trial.CurrEpoch
        
        case p.trial.epoch.ITI
        %% inter-trial interval: wait until sufficient time has passed from the last trial
        if p.trial.CurTime < p.trial.EV.PlanStart
            % All intertrial processing was completed before the ITI expired
            p.trial.task.longITI = 0;
            
        else
            if isnan(p.trial.EV.PlanStart)
                % First trial, or after a break
                p.trial.task.longITI = 0;
            end
            
            % If intertrial processing took too long, display a warning
            if p.trial.task.longITI
                disp('Warning: longer ITI than specified');
            end
            
            switchEpoch(p,'WaitStart');
            
        end
        
        % ----------------------------------------------------------------%  
        case p.trial.epoch.WaitStart
            %% Press TAB to trigger the PicoSpitzer 
             
            % Manual Key Board Drug Pulse 
             p.trial.task.drugSent = 1;
    
            if p.trial.task.useDrug && ~p.trial.task.drugSent
                ND_PulseSeries(p.trial.datapixx.TTL_spritzerChan,    p.trial.datapixx.TTL_spritzerDur,       ...
                               p.trial.datapixx.TTL_spritzerNpulse,  p.trial.datapixx.TTL_spritzerPulseGap,  ...
                               p.trial.datapixx.TTL_spritzerNseries, p.trial.datapixx.TTL_spritzerSeriesGap, ...
                               p.trial.event.INJECT);
                           
                p.trial.task.drugSent = 1;
            
            end
            
            if p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.Timing.drugFlashDelay
                switchEpoch(p,'TrialStart');
            end
        % ----------------------------------------------------------------%  
        case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot    
            ND_FixSpot(p,1); % generates flash            
            tms = pds.datapixx.strobe(p.trial.event.TASK_ON);   

            p.trial.EV.TaskStart = p.trial.CurTime;
            p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
            
            if(p.trial.datapixx.TTL_trialOn)
                pds.datapixx.TTL(p.trial.datapixx.TTL_trialOnChan, 1);
            end
            
             if p.trial.datapixx.TTL_ON == 1  
                                
                                % Send the event code for drug pulse
                                pds.datapixx.strobe(p.trial.datapixx.TTL_InjStrobe);
                                
                                % Run the drug pulse
                                for(i=1:p.trial.datapixx.TTL_Npulse)
                                    pds.datapixx.TTL(p.trial.datapixx.TTL_chan, 1, p.trial.datapixx.TTL_PulseDur);
                                    
                                    if(i < p.trial.datapixx.TTL_Npulse)
                                        WaitSecs(p.trial.datapixx.TTL_GapDur);
                                    end
                                end     
             end
             
            switchEpoch(p,'WaitFix');
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
            %% Fixation target shown, waiting for a sufficiently held gaze
            
             %Gaze is outside fixation window
                if p.trial.task.fixFix == 0
               
                % Fixation has occured
                if p.trial.stim.fix.fixating
                    p.trial.task.fixFix = 1;
                
                % Time to fixate has expired
                elseif p.trial.CurTime > p.trial.EV.TaskStart + p.trial.task.Timing.WaitFix
                    
                    %Turn off fixation spot
                    ND_FixSpot(p,0);
                    
                    %Mark trial NoFix, go directly to TaskEnd, do not start task, do not collect reward
                    p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;
                    switchEpoch(p,'TaskEnd')                   
                end
                                  
        end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % Run standard TaskEnd routine
        Task_OFF(p);
        
        % Flag next trial ITI is done at begining
        p.trial.flagNextTrial = 1;
        
            
    end  % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% show epoch dependent stimuli
% go through the task epochs as defined in TaskDesign and draw the stimulus
% content that needs to be shown during this epoch.

    
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
    if(~isempty(p.trial.LastKeyPress))

        switch p.trial.LastKeyPress(1)
            
            case KbName('p')  % change color ('paint')
                 p.trial.task.Color_list = Shuffle(p.trial.task.Color_list);
                 p.trial.task.FixCol     = p.trial.task.Color_list{mod(p.trial.blocks(p.trial.pldaps.iTrial), ...
                                           length(p.trial.task.Color_list))+1};
                                
        end
    end

% ####################################################################### %
%% additional inline functions
% ####################################################################### %
function switchEpoch(p,epochName)
p.trial.CurrEpoch = p.trial.epoch.(epochName);
p.trial.EV.epochEnd = p.trial.CurTime;

%function fixspot(p,bool)
%if bool && ~p.trial.stim.fix.on
    %p.trial.stim.fix.on = 1;
    %p.trial.EV.FixOn = p.trial.CurTime;
    %pds.datapixx.strobe(p.trial.event.FIXSPOT_ON);
%elseif ~bool && p.trial.stim.fix.on
    %p.trial.stim.fix.on = 0;
    %p.trial.EV.FixOff = p.trial.CurTime;
    %pds.datapixx.strobe(p.trial.event.FIXSPOT_OFF);
%end
