function p = RGBcalibration(p, state)
% Main trial function for initial fixation training.
%
%
%
% Nate Faber & wolf zinke, Sep 2017


% ####################################################################### %
%% define the task name that will be used to create a sub-structure in the trial struct

if(~exist('state', 'var'))
    state = [];
end

% ####################################################################### %
%% Initial call of this function. Use this to define general settings of the experiment/session.
if(isempty(state))

    % --------------------------------------------------------------------%
    %% define ascii output file
    % call this after ND_InitSession to be sure that output directory exists!
    
    % prepare RGB values for the calibration
    
     p.defaultParameters.RGB.GreySteps = linspace(0,1,21);
     p.defaultParameters.RGB.CurrPos = 1;
     
     for(i=1:length(p.defaultParameters.RGB.GreySteps))
         p.defaultParameters.RGB.GreyNames{i} = ['RGB_', int2str(100*p.defaultParameters.RGB.GreySteps(i))];
         ND_DefineCol(p, p.defaultParameters.RGB.GreyNames{i}, i+100, p.defaultParameters.RGB.GreySteps(i));
     end

     p.defaultParameters.stim.FIXSPOT.type    = 'rect';  % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
     p.defaultParameters.stim.FIXSPOT.size    = 5;        % size of the fixation spot
     p.defaultParameters.stim.FIXSPOT.fixWin  = 0;         %\
     
     
 %% displace fixation window and fixation target
    p.defaultParameters.task.fixrect = ND_GetRect([0,0], 4);  
    
    Screen('Preference', 'TextAntiAliasing', 1);
    Screen('Preference', 'DefaultFontSize',  8);
    
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
            
% ------------------------------------------------------------------------%
% DONE DURING THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.framePrepareDrawing
        %% Get ready to display
        % prepare the stimuli that should be shown, do some required calculations
            if(~isempty(p.trial.LastKeyPress))
                KeyAction(p);
            end
            
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameDraw
        %% Display stuff on the screen
        % Just call graphic routines, avoid any computations
            TaskDraw(p)
            
    end  %/ switch state
end  %/  if(nargin == 1) [...] else [...]

% ------------------------------------------------------------------------%
%% Task related functions

% ####################################################################### %
function TaskSetUp(p)
%% main task outline
% Determine everything here that can be specified/calculated before the actual trial start
    p.trial.task.Timing.ITI  = 0.1; 
                                     
    p.trial.CurrEpoch        = p.trial.epoch.ITI;
           
    p.trial.stim.FIXSPOT.color = p.trial.RGB.GreyNames{p.trial.RGB.CurrPos};    
    p.trial.stim.fix = pds.stim.FixSpot(p);
    
    ND_CtrlMsg(p, sprintf('Current Grey scale RGB: %.2f.', p.trial.RGB.GreySteps(p.trial.RGB.CurrPos)));

% ####################################################################### %
function TaskDraw(p)
%% show epoch dependent stimuli
% go through the task epochs as defined in TaskDesign and draw the stimulus
% content that needs to be shown during this epoch.

%     scrtxt = sprintf('Greyscale value: %.2f', p.trial.RGB.GreySteps(p.trial.RGB.CurrPos));
%     Screen('DrawText', p.trial.display.overlayptr, scrtxt , 0, -8, ...
%                        p.trial.display.clut.orange, p.trial.display.clut.bg);
% 

    Screen('FillRect', p.trial.display.overlayptr, ...
                       p.trial.display.clut.(p.trial.RGB.GreyNames{p.trial.RGB.CurrPos}), ...
                       p.trial.task.fixrect);


% Save useful info to an ascii table for plotting
% ####################################################################### %

function KeyAction(p)
%% task specific action upon key press
    if(~isempty(p.trial.LastKeyPress))

        switch p.trial.LastKeyPress(1)
            
            case KbName('=+')  
                
                if(p.trial.RGB.CurrPos < length(p.trial.RGB.GreySteps))
                    p.trial.RGB.CurrPos = p.trial.RGB.CurrPos + 1;
                else
                    warning('Alleready at the end of the list');
                end
                    
            case KbName('-_')  
                
                if(p.trial.RGB.CurrPos > 1)
                    p.trial.RGB.CurrPos = p.trial.RGB.CurrPos - 1;
                else
                    warning('Alleready at the beginning of the list');
                end
        end
         
        p.trial.flagNextTrial = 1;
    end

        
