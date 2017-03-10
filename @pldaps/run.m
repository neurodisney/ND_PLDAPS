function p = run(p)
%run    run a new experiment for a previously created pldaps class
% p = run(p)
% PLDAPS (Plexon Datapixx PsychToolbox) version 4.1
%       run is a wrapper for calling PLDAPS package files
%           It opens the PsychImaging pipeline and initializes datapixx for
%           dual color lookup tables.
% 10/2011 jly wrote it (modified from letsgorun.m)
% 12/2013 jly reboot. updated to version 3 format.
% 04/2014 jk  moved into a pldaps class; adapted to new class structure
%
% modified by wolf zinke, Feb. 2017: cleaned for unused hardware options,
%                                    move data file name definition to ND_InitSession
%
%TODO: 
% one unified system for modules, e.g. moduleSetup, moduleUpdate, moduleClose
% make HideCursor optional
% TODO: reset class at end of experiment or mark as recorded, so I don't
% run the same again by mistake

try
    %% Setup and File management
    % Ensure we have an experimentSetupFile set and verify output file
    
    %make sure we are not running an experiment twice
    if isField(p.defaultParameters, 'session.initTime')
        warning('pldaps:run', 'pldaps objects appears to have been run before. A new pldaps object is needed for each run');
        return
    else
        p.defaultParameters.session.initTime=now;
    end
    
    % pick YOUR experiment's main CONDITION file-- this is where all
    % expt-specific stuff emerges from
    if isempty(p.defaultParameters.session.experimentSetupFile)
        [cfile, cpath] = uigetfile('*.m', 'choose condition file', [base '/CONDITION/debugcondition.m']); %#ok<NASGU>
        
        dotm = strfind(cfile, '.m');
        if ~isempty(dotm)
            cfile(dotm:end) = [];
        end
        p.defaultParameters.session.experimentSetupFile = cfile;
    end
    
    %% Open PLDAPS windows
    % Open PsychToolbox Screen
    p = openScreen(p);
    
    % Setup PLDAPS experiment condition
    p.defaultParameters.pldaps.maxFrames = p.defaultParameters.pldaps.maxTrialLength * p.defaultParameters.display.frate;
    feval(p.defaultParameters.session.experimentSetupFile, p);
    
    %-------------------------------------------------------------------------%
    %% Setup Photodiode stimuli
    if(p.trial.pldaps.draw.photodiode.use)
        makePhotodiodeRect(p);
    end

    %-------------------------------------------------------------------------%
    %% Tick Marks
    if(p.trial.pldaps.draw.grid.use)
        p = initTicks(p);
    end
    
    %get and store changes of current code to the git repository
    p = pds.git.setup(p);
    
    %things that were in the conditionFile
    if(p.trial.eyelink.use)
        p = pds.eyelink.setup(p);
    end
    %things that where in the default Trial Structure
    
    %-------------------------------------------------------------------------%
    %% Audio
    if(p.trial.sound.use)
        p = pds.audio.setup(p);
    end
    
    %-------------------------------------------------------------------------%
    %% REWARD
    p = pds.reward.setup(p);
    
    % Initialize Datapixx including dual CLUTS and timestamp logging
    p = pds.datapixx.init(p);
    
    pds.keyboard.setup(p);
    
    if(p.trial.mouse.useLocalCoordinates)
        p.trial.mouse.windowPtr=p.trial.display.ptr;
    end
    
    if(~isempty(p.trial.mouse.initialCoordinates))
        SetMouse(p.trial.mouse.initialCoordinates(1),p.trial.mouse.initialCoordinates(2),p.trial.mouse.windowPtr)
    end
    
    % --------------------------------------------------------------------%
    %% prepare online plots
    if(p.defaultParameters.plot.do_online)
        p = feval(p.defaultParameters.plot.routine,  p);
    end
    
    % --------------------------------------------------------------------%
    %% Last chance to check variables
    if(p.trial.pldaps.pause.type==1 && p.trial.pldaps.pause.preExperiment==true) %0=don't,1 is debugger, 2=pause loop
        p  %#ok<NOPRT>
        disp('Ready to begin trials. Type return to start first trial...')
        keyboard %#ok<MCKBD>
    end
    
    %%%%start recoding on all controlled components this in not currently done here
    % save timing info from all controlled components (datapixx, eyelink, this pc)
    p = ND_BeginExperiment(p);
    
    % disable keyboard
    ListenChar(2)
    HideCursor
    
    p.trial.flagNextTrial  = 0; % flag for ending the trial
    p.trial.iFrame         = 1; % frame index
    
    %save defaultParameters as trial 0
    trialNr = 0;
    
    p.trial.pldaps.iTrial=0;
    p.trial = mergeToSingleStruct(p.defaultParameters);
    result = saveTempFile(p);
    
    if(~isempty(result))
        disp(result.message)
    end
    
    %now setup everything for the first trial
    
    %     dv.defaultParameters.pldaps.iTrial=trialNr;
    
    %we'll have a trialNr counter that the trial function can tamper with?
    %do we need to lock the defaultParameters to prevent tampering there?
    levelsPreTrials = p.defaultParameters.getAllLevels();
    %     dv.defaultParameters.addLevels(dv.conditions(trialNr), {['Trial' num2str(trialNr) 'Parameters']});
    
    %for now all structs will be in the parameters class, first
    %levelsPreTrials, then we'll add the condition struct before each trial.
    %     dv.defaultParameters.setLevels([levelsPreTrials length(levelsPreTrials)+trialNr])
    %     dv.defaultParameters.pldaps.iTrial=trialNr;
    %     dv.trial=mergeToSingleStruct(dv.defaultParameters);
    
    %only use dv.trial from here on!
    
    %% main trial loop %%
    while(p.trial.pldaps.iTrial < p.trial.pldaps.finish && p.trial.pldaps.quit ~= 2)
        
        if(~p.trial.pldaps.quit)
            
            % ----------------------------------------------------------------%
            %% load parameters for next trial
            trialNr = trialNr+1;

            % get information for current condition
            if(~isempty(p.conditions))
                p.defaultParameters.addLevels(p.conditions(trialNr), {['Trial', num2str(trialNr), 'Parameters']});
                p.defaultParameters.setLevels([levelsPreTrials, length(levelsPreTrials)+trialNr]);
            else
                p.defaultParameters.setLevels(levelsPreTrials);
            end
            
            p.defaultParameters.pldaps.iTrial = trialNr;

            %% update trial information
            % Todo: - Maybe create a trial update function for easier control
            %       - define 'editables', either as 2D cell array (variable
            %         name and value) or text file for task parameters that
            %         have to be updated between trials.
            if(trialNr > 1)
                % The old trial struct is still in memory
                if(p.trial.outcome.CurrOutcome == p.trial.outcome.Correct)
                    p.defaultParameters.LastHits = p.defaultParameters.LastHits + 1;     % how many correct trials since last error
                    p.defaultParameters.NHits    = p.defaultParameters.NHits + 1;        % how many correct trials in total
                else
                    p.defaultParameters.LastHits = 0;     % how many correct trials since last error

                    if(p.trial.outcome.CurrOutcome ~= p.trial.outcome.NoStart && ...
                        p.trial.outcome.CurrOutcome ~= p.trial.outcome.PrematStart)
                        p.defaultParameters.NCompleted = p.defaultParameters.NCompleted + 1; % number of started trials (excluding not started trials)
                    end
                end

                p.defaultParameters.blocks = p.trial.blocks;

                % Define a set of variables that should be editable, i.e. pass on information by default
                if(p.trial.datapixx.useJoystick)
                    p.defaultParameters.behavior.joystick.Zero = p.trial.behavior.joystick.Zero;
                end

                if(p.trial.datapixx.useAsEyepos)
                    p.defaultParameters.behavior.fixation.Zero = p.trial.behavior.fixation.Zero;
                end
            end

            % ----------------------------------------------------------------%
            %% create new trial struct
            % create temporary trial struct
            tmpts = mergeToSingleStruct(p.defaultParameters);

            % quick and nasty fix to avoid saving of online plots
            if(p.defaultParameters.plot.do_online)
               tmpts.plot.fig = [];
            end

            %it looks like the trial struct gets really partitioned in
            %memory and this appears to make some get (!) calls slow.
            %We thus need a deep copy. The superclass matlab.mixin.Copyable
            %is supposed to do that, but that is very slow, so we create
            %a manual deep copy by saving the struct to a file and loading it
            %back in.
            save(fullfile(p.defaultParameters.session.tmpdir, 'deepTrialStruct'), 'tmpts');
            clear tmpts
            load(fullfile(p.defaultParameters.session.tmpdir, 'deepTrialStruct'));
            p.trial = tmpts;
            clear tmpts;

            % ----------------------------------------------------------------%
            %% lock defaultsParameters and run current trial
            p.defaultParameters.setLock(true);
            
            % run trial
            p = feval(p.trial.pldaps.trialMasterFunction,  p);
            
            % unlock the defaultParameters
            p.defaultParameters.setLock(false);
            
            % ----------------------------------------------------------------%
            %% complete trial: plot and save data
            % save tmp data
            result = saveTempFile(p);
            if(~isempty(result))
                disp(result.message)
            end
            
            if p.defaultParameters.pldaps.save.mergedData
                %store the complete trial struct to .data
                dTrialStruct = p.trial;
            else
                %store the difference of the trial struct to .data
                dTrialStruct = getDifferenceFromStruct(p.defaultParameters, p.trial);
            end
            p.data{trialNr}=dTrialStruct;
                       
            
            if(~p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay)
                glDeleteTextures(2,glGenTextures(1));
            end

            %% make online plots
            if(p.defaultParameters.plot.do_online)
                feval(p.defaultParameters.plot.routine,  p);
                p.trial.plot.fig = []; % avoid saving the figure to data
            end

        else %dbquit ==1 is meant to be pause. should we halt eyelink, datapixx, etc?

            %create a new level to store all changes in,
            %load only non trial paraeters
            pause = p.trial.pldaps.pause.type;
            p.trial = p.defaultParameters;
            
            p.defaultParameters.addLevels({struct}, {['PauseAfterTrial' num2str(trialNr) 'Parameters']});
            p.defaultParameters.setLevels([levelsPreTrials length(p.defaultParameters.getAllLevels())]);
            
            if pause==1 %0=don't,1 is debugger, 2=pause loop
                ListenChar(0);
                ShowCursor;
                p.trial
                disp('Ready to begin trials. Type return to start first trial...')
                keyboard %#ok<MCKBD>
                p.trial.pldaps.quit = 0;
                ListenChar(2);
                HideCursor;
            elseif pause==2
                pauseLoop(p);
            end
            
            %now I'm assuming that nobody created new levels,
            %but I guess when you know how to do that
            %you should also now how to not screw things up
            allStructs=p.defaultParameters.getAllStructs();
            if(~isequal(struct,allStructs{end}))
                levelsPreTrials=[levelsPreTrials length(allStructs)]; %#ok<AGROW>
            end
            
        end  %  if(~p.trial.pldaps.quit)
    end  %  while(p.trial.pldaps.iTrial < p.trial.pldaps.finish && p.trial.pldaps.quit ~= 2)
    
    %% make the session parameterStruct active
    p.defaultParameters.setLevels(levelsPreTrials);
    p.trial = p.defaultParameters;
    
    %% return cursor and command-line control
    ShowCursor;
    ListenChar(0);
    Priority(0);
    
    %% end datapixx
    if(p.defaultParameters.datapixx.use)
        %start adc data collection if requested
        pds.datapixx.adc.stop(p);
        
        status = PsychDataPixx('GetStatus');
        if(status.timestampLogCount)
            p.defaultParameters.datapixx.timestamplog = PsychDataPixx('GetTimestampLog', 1);
        end
    end
    
    %% shut down audio
    if(p.defaultParameters.sound.use)
        pds.audio.clearBuffer(p);
        % Close the audio device:
        PsychPortAudio('Close', p.defaultParameters.sound.master);
    end
    
    %% save the session data to file
    saveSession(p);

    %% close screens
    if(~p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay)
        glDeleteTextures(2,glGenTextures(1));
    end
    
    Screen('CloseAll');
    
    sca;
    
catch me
    sca
    if(p.trial.sound.use)
        PsychPortAudio('Close', p.defaultParameters.sound.master);
    end
    % return cursor and command-line control
    ShowCursor
    ListenChar(0)
    disp(me.message)
    
    nErr = size(me.stack);
    for iErr = 1:nErr
        fprintf('errors in %s line %d\r', me.stack(iErr).name, me.stack(iErr).line)
    end
    fprintf('\r\r')
    keyboard
end

end


%we are pausing, will create a new defaultParaneters Level where changes
%would go.
function pauseLoop(dv)
ShowCursor;
ListenChar(1);
while(true)
    %the keyboard chechking we only capture ctrl+alt key presses.
    [dv.trial.keyboard.pressedQ,  dv.trial.keyboard.firstPressQ]=KbQueueCheck(); % fast
    
    if(any(p.trial.keyboard.firstPressQ))
        
        qp = find(p.trial.keyboard.firstPressQ); % identify which key was pressed
        
        switch qp
            
            case KbName(p.trial.key.reward)
                % check for manual reward delivery via keyboard
                pds.reward.give(p, p.trial.task.Reward.ManDur);  % per default, output will be channel three.

                %D: Debugger
            case KbName(p.trial.key.debug)
                disp('stepped into debugger. Type return to start first trial...')
                keyboard %#ok<MCKBD>
                
                %P: PAUSE (end the pause)
            case KbName(p.trial.key.pause)
                dv.trial.pldaps.quit = 0;
                ListenChar(2);
                HideCursor;
                break;
                
                %Q: QUIT
            case KbName(p.trial.key.quit)
                dv.trial.pldaps.quit = 2;
                break;
                
                %X: Execute text selected in Matlab editor
            case KbName(p.trial.key.exe)
                activeEditor=matlab.desktop.editor.getActive;
                if isempty(activeEditor)
                    display('No Matlab editor open -> Nothing to execute');
                else
                    if isempty(activeEditor.SelectedText)
                        display('Nothing selected in the active editor Widnow -> Nothing to execute');
                    else
                        try
                            eval(activeEditor.SelectedText)
                        catch ME
                            display(ME);
                        end
                    end
                end
        end  %  switch qp
    end  % if(any(p.trial.keyboard.firstPressQ))
    pause(0.1);
end  %  while(true)
end % function pauseLoop(dv)
