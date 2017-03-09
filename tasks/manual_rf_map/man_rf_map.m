function p = man_rf_map(p, state)
% The main trial function for creating a movable bar for manual RF mapping
%
% The eventual goals for this task
% 1. TODO: Create a black bar on 50% contrast background
% 2. TODO: Mouse movement moves the bar around
% 3. TODO: Keyboard input to change the parameters of the bar
%       Left/Right Arrows - change orientation of the bar
%       Up/Down Arrows - change the contrast of the bar
%       W/S - Change length of bar
%       A/D - Change width of bar
%
% Nate Faber, Mar 2017
% Adapted from framework developed by Wolf Zinke

% ####################################################################### %
%% Define the the state parameter if undefined to keep track of trial state

if (~exist('state' ,'var'))
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
% file. In this case p.defaultParameters.pldaps.trialFunction needs to be defined
% here to refer to the file with the actual trial
if(isempty(state))

    % --------------------------------------------------------------------%
    %% Set initial parameters for the rf bar
    
    p.trial.task.rfbar.length_dva   =   6; % Length of the bar in degrees of visual angle
    p.trial.task.rfbar.width_dva    =   3;
    p.trial.task.rfbar.pos_dva      =   [0, 0];
    p.trial.task.rfbar.angle        =   0;
    
    % Convert these to pixels
    p.trial.task.rfbar.length_pxl   =   ND_dva2pxl(p.trial.task.rfbarLength_dva, p);
    p.trial.task.rfbar.width_pxl    =   ND_dva2pxl(p.trial.task.rfbarWidth_dva, p);
    p.trial.task.rfbar.pos_pxl      =   ND_cart2ptb(p, p.trial.task.rfbarPos_dva;
    
    


    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.
    
    % Define the different greyscale values at 5% increments
    % 45% gray will be called Gray45 for example
    
    % To faciliate rapid incremental contrast shifting, put all the
    % colornames in order in an array [Black, Gray5, ..., Gray95, White]
    colorArray = cell(1,21); % Preallocate cell array for the strings
    
    ND_DefineCol(p, 'Black', 30, 0);
    colorArray{1} = 'Black';
    
    ND_DefineCol(p, 'White', 50, 1);
    colorArray{21} = 'White';
    
    for i = 5:5:95
        colorName = sprintf('Gray%i',i);
        colorValue = str2double(sprintf('0.%02i',i));
        index = i/5;
        ND_DefineCol(p, colorName, 30 + index, colorValue);
        colorArray{index + 1} = colorName;
    end
    
    % Initial Color is black
    p.trial.task.rfbar.color = p.defaultParameters.display.Black;

    %% define ascii output file
    % call this after ND_InitSession to be sure that output directory exists!
    
    %Trial2Ascii(p, 'init'); TODO: Save bar parameters to file every frame

    % --------------------------------------------------------------------%

% ####################################################################### %
else
    %% Subsequent calls during actual trials
    
    switch state
        
        %################################################################%
        % Done before main trail loop:
        
        case p.trial.pldaps.trialStates.trialSetup
            % Prepare everything for the trial, especially the time
            % demanding stuff
            TaskSetup(p)
            
        case p.trial.pldaps.trialStates.trialPrepare
            % Just prior to acutal trial start
            p.trial.EV.TrialStart = p.trial.CurTime;
            
    end
            
end

end

function TaskSetup(p)
%% main task outline
% Determine everything here that can be specified/calculated before the actual trial start
    p.trial.CurrEpoch = p.trial.epoch.MoveBar;
end

function TaskDesign(p)
%% main task outline
% This defines the behavior of the task. Controls the flow of the state
% machine and determines the next epoch based off of the current epoch and
% incoming data.
    switch p.trial.CurrEpoch
        
        case p.trial.epoch.MoveBar
            
            
        case p.trial.epoch.TaskEnd
            
    end
end

function TaskDraw(p)
%% Draws the appropriate stimuli for each epoch
window = p.trial.display.overlayptr;
rfbar = p.trial.task.rfbar;

    switch p.trial.CurrEpoch
        
        case p.trial.epoch.MoveBar
            % Draw the bar stimuli by creating a custom coordinate frame
            % for it. Then translate and rotate the correct amounts
            Screen('glPushMatrix', window);
            Screen('glTranslate', window, rfbar.pos_pxl(1), rfbar.pos_pxl(2) );
            Screen('glRotate', window, rfbar.angle);
            DrawBar(window,rfbar.width_pxl,rfbar.height_pxl);
            Screen('glPopMatrix',window);
            
        case p.trial.epoch.TaskEnd
    end
end

function DrawBar(window,width,height,color)
    Screen('FillRect', window, color, [-width/2.0, height/2.0, width/2.0, height/2.0])
end
