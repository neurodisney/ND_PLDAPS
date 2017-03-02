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
    %% Set initial parameters for bar
    

    %ND_CtrlMsg(p, 'Experimental SETUP');
    % --------------------------------------------------------------------%
    %% define ascii output file
    % call this after ND_InitSession to be sure that output directory exists!
    
    %Trial2Ascii(p, 'init'); TODO: Save bar parameters to file every frame

    % --------------------------------------------------------------------%
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


    
end

end

% function Trial2Ascii(p, act)
% %% Save trial progress in an ASCII table
% % 'init' creates the file with a header defining all columns
% % 'save' adds a line with the information for the current trial
% %
% % make sure that number of header names is the same as the number of entries
% % to write, also that the position matches.
% 
%     switch act
%         case 'init'
%             p.trial.session.asciitbl = [datestr(now,'yyyy_mm_dd_HHMM'),'.dat'];
%             tblptr = fopen(fullfile(p.trial.pldaps.dirs.data, p.trial.session.asciitbl) , 'w');
% 
%             fprintf(tblptr, ['Date  Time  Secs  Subject  Experiment  Tcnt  Cond  Tstart  JPress  GoCue  JRelease  Reward  RewDur  ',...
%                              'Result  Outcome  StartRT  RT  ChangeTime \n']);
%             fclose(tblptr);
% 
%         case 'save'
%             if(p.trial.pldaps.quit == 0 && p.trial.outcome.CurrOutcome ~= p.trial.outcome.NoStart)  % we might loose the last trial when pressing esc.
%                 trltm = p.trial.task.EV.TaskStart - p.trial.timing.datapixxSessionStart;
% 
%                 cOutCome = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};
% 
%                 tblptr = fopen(fullfile(p.trial.pldaps.dirs.data, p.trial.session.asciitbl) , 'a');
% 
%                 fprintf(tblptr, '%s  %s  %.4f  %s  %s  %d  %d  %.5f %.5f  %.5f  %.5f  %.5f  %.5f  %d  %s  %.5f  %.5f  %.5f\n' , ...
%                                 datestr(p.trial.session.initTime,'yyyy_mm_dd'), p.trial.task.EV.TaskStartTime, ...
%                                 p.trial.task.EV.TaskStart, p.trial.session.subject, ...
%                                 p.trial.session.experimentSetupFile, p.trial.pldaps.iTrial, p.trial.Nr, ...
%                                 trltm, p.trial.task.EV.JoyPress, ...
%                                 p.trial.task.EV.GoCue, p.trial.task.EV.JoyRelease, p.trial.task.EV.Reward, ...
%                                 p.trial.task.Reward.Curr, p.trial.outcome.CurrOutcome, cOutCome, ...
%                                 p.trial.task.EV.StartRT, p.trial.task.EV.RespRT, p.trial.task.Timing.HoldTime);
%                fclose(tblptr);
%             end
%     end