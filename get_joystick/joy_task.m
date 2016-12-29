function p=joy_run(p, state)
% main trial function for the joystick training. 
%
% wolf zinke, Dec. 2016


% if(nargin < 3)
%     task='joy_train'; % this will be used to create a sub-structur in the trial structure
% end



% ------------------------------------------------------------------------%
%% Initial call of this function. Use this to define general layout.
% Here, default parameters of the pldaps class could be adjusted if needed
if(nargin == 1)
    
    % initialize the random number generator (verify how this affects pldaps)
    rng('shuffle', 'twister');

    % The frame allocation can only be set once the pldaps is run,
    % otherwise p.trial.display.frate will not be available because it is
    % defined in the openscreen call.
    p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;

    % --------------------------------------------------------------------%
    %% Determine conditions and their sequence
    % define conditions (conditions could pe passed to the pldaps call as
    % cell array, or defined here within the main trial function. The
    % control of trials, especially the use of blocks, i.e. the repetition
    % of a defined number of trials per condition, needs to be clarified.
    % Right now, it is a placeholder).
    
    maxTrials_per_BlockCond = 10;  
    maxBlocks = 100;
    
    % condition 1
    c1.Nr = 1; 
      
    % condition 2
    c2.Nr = 2; 
    
    % condition 3
    c3.Nr = 3; 
      
    % condition 4
    c4.Nr = 4; 
    
    % create a cell array containing all conditions
    conditions = {c1, c2, c3, c4};
    
    % generate sequence of blocks and conditions
    % TODO: This might become its own function to allow for more
    % flexebility and general use

    Ncond               = length(conditions);
    maxTrials_per_Block = maxTrials_per_BlockCond * Ncond;
    maxTrials           = maxTrials_per_Block * maxBlocks;
    
    BlockCondSet = repmat(1:Ncond, 1, maxTrials_per_BlockCond);
    CNDlst = nan(1, maxTrials);
    BLKlst = nan(1, maxTrials);
    
    % pre-define order of conditions
    for(cblk = 1:maxBlocks)
        Blk = ((cblk-1) * maxTrials_per_Block) + 1;
        CNDlst(Blk:Blk+maxTrials_per_Block-1) = BlockCondSet(randperm(maxTrials_per_Block));
        BLKlst(Blk:Blk+maxTrials_per_Block-1) = cblk;
    end
    
    p.conditions = conditions(CNDlst);
    p.blocks     = BLKlst; % added this to pldaps, seems that they do not use blocks
        
    p.defaultParameters.pldaps.finish = maxTrials; 
    
    
else
% ------------------------------------------------------------------------%
%% Subsequent calls during actual trials
% execute trial specific commands here.

    switch state
        % TODO: find out what trialstates are used and check for reliability
        % in their timings by  executing triggers in this switch command.
        
   % DONE BEFORE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialSetup
        %% trial set-up
        % prepare everything for the trial, including allocation of stimuli
        % and all other more time demanding stuff.
        
        p = joy_train_taskdef(p, task);  % brute force: read in task parameters every time to allow for online modifications
        
        ND_StartUpTrial(p);
        
        InitTask(p);
        
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialPrepare
        %% trial preparation            
        % just prior to actual trial start, use it for time sensitive
        % preparations;

   % DONE DURING THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameUpdate
        %% collect data (i.e. a hardware module) and store it
        
        ND_CheckKeyMouse(p);         % check for key hits, read mouse, use mouse for eye position if needed
        pds.datapixx.adc.getData(p); % get analogData from Datapixx, including eye position and joystick
        
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.framePrepareDrawing
        %% Get ready to display
        % prepare the stimuli that should be shown, do some required calculations
        
        PrepStim(p);
        
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameDraw
        %% Display stuff on the screen
        % Just call graphic routines, avoid any computations
               
        ND_DrawControlScreen(p);
        DrawStim(p);
        
        
    % DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
          
            % ------------------------------------------------------------%
            % ensure all conditions were performed correctly equal often
            % TODO: This might become its own function to allow for more
            % flexebility and general use
            if(p.trial.(task).EqualCorrect && ~p.trial.pldaps.goodtrial) % need to check if success, repeat if not    
                curCND = p.conditions{p.trial.pldaps.iTrial};
                curBLK = p.blocks{p.trial.pldaps.iTrial};

                poslst = 1:length(p.conditions);
                cpos   = find(poslst > p.trial.pldaps.iTrial & p.blocks == curBLK);

                InsPos = cpos(randi(length(cpos))); % determine random position in the current block for repetition

                p.conditions = [p.conditions(1:InsPos-1) curCND p.conditions(InsPos:end)];
                p.blocks     = [    p.blocks(1:InsPos-1) curBLK     p.blocks(InsPos:end)];
                
                p.trial.pldaps.finish = p.trial.pldaps.finish + 1; % added a required trial
            end

            % just as fail safe, make sure to finish when done
            if(p.trial.pldaps.iTrial == length(p.conditions))
                p.trial.pldaps.finish = p.trial.pldaps.iTrial;
            end
            
            ND_TrialCleanUpandSave(p);
            
    end  %/ switch state
end  %/  if(nargin == 1) [...] else [...]

% ------------------------------------------------------------------------%
%% Task related functions
% TODO: SOme of tyhese functions should become stand alone functions that
% could be called from other paradigms as well. Right now, to have
% something up and running, all functions are included below.



% ------------------------------------------------------------------------%
function InitTask(p)
% prepare everything prior to starting the main trial loop, i.e. allocate
% stimuli and set parameter.

    %ensure background color is correct
    Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor);
    p.trial.pldaps.lastBgColor = p.trial.display.bgColor;

    vblTime = Screen('Flip', p.trial.display.ptr,0); 
    p.trial.trstart = vblTime;
    p.trial.stimulus.timeLastFrame = vblTime - p.trial.trstart;

    p.trial.ttime  = GetSecs - p.trial.trstart;
    p.trial.timing.syncTimeDuration = p.trial.ttime;





% ------------------------------------------------------------------------%
function PrepStim(p)

switch p.trial.(task).CurrEpoch


end

% ------------------------------------------------------------------------%
function DrawStim(p)


switch p.trial.(task).CurrEpoch


end

