function p=joy_task(p, state)
% Main trial function for initial joystick training. 
% 
% The animal needs to learn how to operate a joystick (i.e. lever) in order
% to receive a juice reward.
% 
% 1) The trial starts with a change of background color (maybe changed to a
% appearance of a frame). 
% 2) The animal has to press a lever and a large square is shown together
% with a juice reward (this first reward will be disabled once the main 
% principle is understood).
% 3) If the animal keeps the lever pressed for a minimum hold time and then
% releases it, the square changes its contrast and another reward will be
% delivered.
% 
% TODO: add accoustic feedback
%
% wolf zinke, Dec. 2016


% if(nargin < 3)
%     task='joy_train'; % this will be used to create a sub-structur in the trial structure
% end


% ####################################################################### %        
%% Initial call of this function. Use this to define general layout.
% Here, default parameters of the pldaps class could be adjusted if needed
if(nargin == 1)
    
    % not sure how the pldaps wanted to solve this, their task concept for
    % specofying a trial sub-struct just does not work, try  to use a global
    % definition here to cope with it.
    if(exist('task','var'))
        clear task
    end
        
    % initialize the random number generator (verify how this affects pldaps)
    rng('shuffle', 'twister');
    
    % ensure that the data directory exists (TODO: use the entry from the trial struct)
    if(~exist(p.trial.pldaps.dirs.data,'dir'))
        mkdir(p.trial.pldaps.dirs.data);
    end
    
    % define ascii output file
    
    Trial2Ascii(p, 'init');
    
    
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
    
    ND_GetConditionList(p, conditions, maxTrials_per_BlockCond, maxBlocks);
    
    
else
% ####################################################################### %        
%% Subsequent calls during actual trials
% execute trial specific commands here.

    switch state
        % TODO: find out what trialstates are used and check for reliability
        % in their timings by  executing triggers in this switch command.
  
% ####################################################################### %        
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
        
        StartTrial(p); % this defines the actual trial start time

% ####################################################################### %        
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
        
% ####################################################################### %        
% DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
          
            FinishTask(p);
                        
            ND_CheckCondRepeat(p);     % ensure all conditions were performed correctly equal often
            
            ND_TrialCleanUpandSave(p); % end all trial related processes           
            
            Trial2Ascii(p, 'save');
            
            % just as fail safe, make sure to finish when done
            if(p.trial.pldaps.iTrial == length(p.conditions))
                p.trial.pldaps.finish = p.trial.pldaps.iTrial;
            end
            
    end  %/ switch state
end  %/  if(nargin == 1) [...] else [...]

% ------------------------------------------------------------------------%
%% Task related functions
% TODO: SOme of tyhese functions should become stand alone functions that
% could be called from other paradigms as well. Right now, to have
% something up and running, all functions are included below.

% ------------------------------------------------------------------------%
function Trial2Ascii(p, state)
%% Save trial progress in an ASCII table
% 'init' creats the file with a header defining all columns
% 'save' adds a line with the information for the current trial
%
% make sure that number of header names is the same as the number of entries
% to write, also that the position matches.

    switch state
        case 'init'
            p.trial.session.asciitbl = [datestr(now,'yyyy_mm_dd_HHMM'),'.dat'];
            tblptr = fopen(fullfile(p.trial.pldaps.dirs.data, p.trial.pldaps.save.asciitbl) , 'w');
            
            fprintf(tblptr, 'Date  Subject  Experiment  Tcnt  Tstart');
            
        case 'save'
            tblptr = fopen(fullfile(p.trial.pldaps.dirs.data, p.trial.session.asciitbl) , 'w');
            fprintf(tblptr, '%s  %s  %s  %d  %s \n' , ...
                            datestr(p.trial.session.initTime,'yyyy_mm_dd'), p.trial.session.subject, task, ...
                            p.trial.pldaps.iTrial, p.trial.TrialStart);  
    end

    fclose(tblptr);
    
    
% ------------------------------------------------------------------------%
function InitTask(p)
%% prepare everything prior to starting the main trial loop, i.e. allocate
% stimuli and set parameter.

    % ensure background color is correct

    

% ------------------------------------------------------------------------%
function StartTrial(p)
%% this defines the start of the trial

    % TODO: Make sure not to start a trial without the joystick being in rest state (i.e. lever released).

    % for now, change the background to indicate trial is active
    % change this in the future to a frame (i.e. two overlayd rects?)
    Screen('FillRect', p.trial.display.ptr, p.trial.(task).TrialStartCol);
    
    p.trial.pldaps.lastBgColor = p.trial.display.bgColor;

    vblTime = Screen('Flip', p.trial.display.ptr, 0); 
    
    p.trial.trstart = vblTime;
    p.trial.stimulus.timeLastFrame = vblTime - p.trial.trstart;

    p.trial.ttime  = GetSecs - p.trial.trstart;
    p.trial.timing.syncTimeDuration = p.trial.ttime;
    
    p.trial.TrialStart = datestr(now,'HH:MM:SS:FFF');  % WZ: added absolute time as string
    
    
    p.trial.(task).CurrEpoch = p.trial.(task).epoch.WaitPress;
% ------------------------------------------------------------------------%
function PrepStim(p)

    switch p.trial.(task).CurrEpoch


    end

% ------------------------------------------------------------------------%
function DrawStim(p)


    switch p.trial.(task).CurrEpoch


    end


function FinishTask(p)
