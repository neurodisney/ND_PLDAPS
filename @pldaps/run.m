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
%
%
%TODO:
% make HideCursor optional
% TODO: reset class at end of experiment or mark as recorded, so I don't
% run the same again by mistake

try

    %% Setup and File management
    % Ensure we have an experimentSetupFile set and verify output file

    %make sure we are not running an experiment twice
    if(isfield(p.defaultParameters, 'session.initTime'))
        warning('pldaps:run', 'pldaps objects appears to have been run before. A new pldaps object is needed for each run');
        return
    else
        p.defaultParameters.session.initTime = now;
    end

    %% Setup and File management
    % define dependent parameter checks and check for consistency (needs to be called before openscreen)
    p = ND_PrepSession(p); 

    %-------------------------------------------------------------------------%
    %% Setup PLDAPS experiment
    % this still acts on defaultParameters and needs to be called before openscreen
    if(~isfield(p.defaultParameters.session, 'experimentSetupFile') || ...
        isempty(p.defaultParameters.session.experimentSetupFile)    || ...
        ~exist( p.defaultParameters.session.experimentSetupFile, 'file'))
        error('Need a valid specification for the experimental setup file!');
    else
        feval(p.defaultParameters.session.experimentSetupFile, p); 
    end
    
    %-------------------------------------------------------------------------%
    %% Open PLDAPS windows
    % Open PsychToolbox Screen
    p = openScreen(p);

    %-------------------------------------------------------------------------%
    %% Initialize session
    p = ND_InitSession(p); % final itialization, needs to be called after openscreen

    % --------------------------------------------------------------------%
    %% Last chance to check variables
    if(p.defaultParameters.pldaps.pause)
        disp('Ready to begin trials. Type return to start first trial...')
        pause
        p.trial.pldaps.pause = 0;
    end

    % --------------------------------------------------------------------%
    %% start recoding on all controlled components this in not currently done here
    % save timing info from all controlled components (datapixx, eyelink, this pc)
    p = ND_BeginExperiment(p);

    % disable keyboard
    ListenChar(2)
    HideCursor

    p.trial.flagNextTrial  = 0; % flag for ending the trial
    p.trial.pldaps.quit = 0;
    p.trial.pldaps.pause = 0;

    trialNr = 0;
    p.trial.pldaps.iTrial = 0;

    % --------------------------------------------------------------------%
    %% Load any p.trial alterations in p.defaultParameters
    % Assume any thing loaded into p.trial by this point should be kept and load it into defaultParameters
    if ~isempty(p.trial)
        p.defaultParameters = ND_AlterSubStruct(p.defaultParameters, p.trial);
    end
    
    % --------------------------------------------------------------------%
    %% prepare first trial
    preExperimentParameters = p.defaultParameters;
    
    % save default parameters to trial data directory
    save(fullfile(p.defaultParameters.session.trialdir, ...
        [p.defaultParameters.session.filestem, '_InitialDefaultParameters.pds']), ...
        '-struct', 'preExperimentParameters', '-mat', '-v7.3');

    %% main trial loop %%
    while(p.trial.pldaps.quit == 0)

        if(~p.trial.pldaps.quit && ~p.trial.pldaps.pause)
            %% Start setting up trial
            trialNr = trialNr+1;
            p.defaultParameters.pldaps.iTrial = trialNr;
            % --------------------------------------------------------------------%
            
            %% update condition/block list
            % This has to be done before the block with addLevels and setLevels on defaultParameters
            p = ND_GenCndLst(p);

            % ----------------------------------------------------------------%
            %% load parameters for next trial and create new trial struct
            p = ND_LoadCondition(p);
            p.trial = p.defaultParameters;

            % ----------------------------------------------------------------%
            %% Run current trial
            dpPreTrial = p.defaultParameters;

            % run trial
            p = feval(p.trial.pldaps.trialMasterFunction,  p);

            % Make sure defaultParameters do not change during a trial (should be exclusively done in ND_UpdateTrial
            dpPostTrial = p.defaultParameters;
            if ~isequaln(dpPreTrial, dpPostTrial)
                warning('defaultParameters changed within a trial, should only be chaged between trials')
                % Iterate through the two structs to find the differences (for debugging purposes)
                % [~, preDifferent, postDifferent] = ND_CompareStructs(dpPreTrial, dpPostTrial);
                % Display the postDifferent struct
               % disp(postDifferent)
            end
                
            % ----------------------------------------------------------------%            
            %% processes after trial
            p = ND_AfterTrial(p);
            
            % ----------------------------------------------------------------%
            %% Save trial data
            if(~p.trial.pldaps.nosave)
                result = saveTrialFile(p);
                
                if(~isempty(result))
                    disp(result.message)
                end
            end
            
            % ----------------------------------------------------------------%
            %% make online plots
            if(p.trial.plot.do_online)
                feval(p.trial.plot.routine, p);
            end
            
            % ----------------------------------------------------------------%
            %% pass information from this trial to the next trial
            p = ND_UpdateTrial(p);
            
            % completed all desired trial, finish experiment now
            if(p.trial.pldaps.iTrial > p.trial.pldaps.finish)
                p.trial.pldaps.quit = 1;
            end
            
        elseif p.trial.pldaps.pause
        %% pause experiment    
        
            if(p.trial.pldaps.pause == 1)
                pds.datapixx.strobe(p.trial.event.PAUSE);
                
            elseif(p.trial.pldaps.pause == 2)
                % set screen to break color
                Screen('FillRect', p.trial.display.overlayptr, ...
                       p.trial.display.clut.(p.trial.display.breakColor), ...
                       p.defaultParameters.display.winRect);
                   
                Screen('Flip', p.trial.display.ptr, 0);
                
                pds.datapixx.strobe(p.trial.event.BREAK);
            end
        
            KbQueueStart;

            % check for keyboard actions while pausing
            while(p.trial.pldaps.pause > 0 && p.trial.pldaps.quit < 1)
                WaitSecs(0.01);
                ND_CheckKey(p);
            end
            
            pds.datapixx.strobe(p.trial.event.UNPAUSE);
        end
    end  %  while(p.trial.pldaps.iTrial < p.trial.pldaps.finish && p.trial.pldaps.quit ~= 2)
    
    %% save online plot
    if(p.defaultParameters.plot.do_online)
        ND_fig2pdf(p.plotdata.fig, ...
                  [p.defaultParameters.session.dir, filesep, p.defaultParameters.session.filestem, '.pdf']);
    end

    % ----------------------------------------------------------------%
    %% return cursor and command-line control
    ShowCursor;
    ListenChar(0);
    Priority(0);

    % ----------------------------------------------------------------%
    %% end datapixx
    if(p.defaultParameters.datapixx.use)
        %start adc data collection if requested
        pds.datapixx.adc.stop(p);

        status = PsychDataPixx('GetStatus');
        if(status.timestampLogCount)
            p.defaultParameters.datapixx.timestamplog = PsychDataPixx('GetTimestampLog', 1);
        end
    end

    % ----------------------------------------------------------------%
    %% shut down audio
    if p.defaultParameters.sound.use && p.trial.sound.usePsychPortAudio
        % Close the audio device:
        PsychPortAudio('Close', p.defaultParameters.sound.master);
    end
    
    % ----------------------------------------------------------------%
    %% save the session data to file
    
    % save defaultParameters as they are at the end of the session
    postExperimentParameters = p.defaultParameters; %#ok<*NASGU>

    save(fullfile(p.defaultParameters.session.trialdir, ...
                 [p.defaultParameters.session.filestem, '_FinalDefaultParameters.pds']), ...
                 '-struct', 'postExperimentParameters', '-mat', '-v7.3');

% ----------------------------------------------------------------%
    %% close screens
    if(~p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay)
        glDeleteTextures(2, glGenTextures(1));
    end

    Screen('CloseAll');

    sca;

catch me
    sca
    if(isfield(p, 'defaultParameters.sound.use'))
        if(p.defaultParameters.sound.use)
            PsychPortAudio('Close');
        end
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
