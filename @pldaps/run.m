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
    if(isField(p.defaultParameters, 'session.initTime'))
        warning('pldaps:run', 'pldaps objects appears to have been run before. A new pldaps object is needed for each run');
        return
    else
        p.defaultParameters.session.initTime = now;
    end

    %% Setup and File management
    % define dependent parameter checks and check for consistency (needs to be called before openscreen)
    p = ND_PrepSession(p);  %

    %-------------------------------------------------------------------------%
    %% Setup PLDAPS experiment
    % this still acts on defaultParameters
    if(~isfield(p.defaultParameters.session, 'experimentSetupFile') || ...
        isempty(p.defaultParameters.session.experimentSetupFile)    || ...
        ~exist( p.defaultParameters.session.experimentSetupFile, 'file'))
        error('Need a valid specification for the experimental setup file!');
    else
        feval(p.defaultParameters.session.experimentSetupFile, p); % needs to be called before openscreen
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
    if p.trial.pldaps.pause
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
    p.trial.iFrame         = 1; % frame index

    trialNr = 0;
    p.trial.pldaps.iTrial = 0;

    % --------------------------------------------------------------------%
    %% prepare first trial
    levelsPreTrials = p.defaultParameters.getAllLevels();

    %% main trial loop %%
    while(p.trial.pldaps.iTrial < p.trial.pldaps.finish && p.trial.pldaps.quit ~= 2)

        if(~p.trial.pldaps.quit && ~p.trial.pldaps.pause)

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
            
            % ----------------------------------------------------------------%
            %% Update information between trials
            % This is right now a very dirty and unsatisfying solution.
            % PLDAPS seems to overwrite the defaultParameters in the
            % previous blocks, therefore a bunch of variables are created
            % that will be passed from p.trial to p.trial by modifying
            % temporarily the defaultParameters. However, defaultParameters
            % will be reset every new iteration of this trial loop.
            % TODO: make the code more flexible to allow changes to the
            % defaultParameters and maybe keep some additonal information
            % in other sub-structs.
            if(trialNr > 1) % this actually is supposed to happen after a trial, hence skip first in loop
 
                % processes after trial
                p = ND_AfterTrial(p);
                
                % make online plots
                if(p.trial.plot.do_online)
                    feval(p.trial.plot.routine, p);
                end
                
               % pass some information from the previous trial to the next trial
                p = ND_UpdateTrial(p);
                
            end
            
            % ----------------------------------------------------------------%
            %% create new trial struct

            % create temporary trial struct
            if(p.defaultParameters.plot.do_online)
                figh = p.defaultParameters.plot.fig;
                p.defaultParameters.plot.fig = []; % avoid saving the figure to data
            end
            
            tmpts = mergeToSingleStruct(p.defaultParameters);


            % save default parameters to trial data directory
            if(trialNr == 1)
                save(fullfile(p.defaultParameters.session.trialdir, ...
                             [p.defaultParameters.session.filestem, '_InitialDefaultParameters.pds']), ...
                             '-struct', 'tmpts', '-mat', '-v7.3');
            end

            % easiest (and quickest) way to create a deep copy is to save it as mat file and load it again
            tmp_ptrial = fullfile(p.defaultParameters.session.tmpdir, 'deepTrialStruct.mat');
            save(tmp_ptrial, 'tmpts');
            clear tmpts;
            load(tmp_ptrial);
            p.trial = tmpts;
            
            if(p.defaultParameters.plot.do_online)
                p.trial.plot.fig = figh; %dirty ad hoc fix to keep figure handle available
            end
            
            clear tmpts;
            delete(tmp_ptrial);

            % ----------------------------------------------------------------%
            %% lock defaultsParameters and run current trial
            p.defaultParameters.setLock(true);

            % run trial
            p = feval(p.trial.pldaps.trialMasterFunction,  p);

            % unlock the defaultParameters
            p.defaultParameters.setLock(false);
            
            % ----------------------------------------------------------------%
            %% complete trial: save trial data
            result = saveTrialFile(p);

            if(~isempty(result))
                disp(result.message)
            end
            
        elseif p.trial.pldaps.pause
        %% interupt experiment    
            if(p.trial.pldaps.pause == 1)
                pds.datapixx.strobe(p.trial.event.PAUSE);
%                 p.trial.EV.Pause = p.trial.CurTime;
            elseif(p.trial.pldaps.pause == 2)
                % set screen to break color
                Screen('FillRect', p.trial.display.ptr, p.trial.display.breakColor);
                %Screen('FillRect', p.trial.display.overlayptr, p.trial.display.breakColor);
                Screen('Flip', p.trial.display.ptr, 0);
                pds.datapixx.strobe(p.trial.event.BREAK);
%                 p.trial.EV.Break = p.trial.CurTime;
            end
            
            pauseLoop(p);

        end
    end  %  while(p.trial.pldaps.iTrial < p.trial.pldaps.finish && p.trial.pldaps.quit ~= 2)

    
    % final update of trial information
    p = ND_AfterTrial(p);
    
    %% save online plot
    if(p.defaultParameters.plot.do_online)
        ND_fig2pdf(p.trial.plot.fig, ...
                  [p.defaultParameters.session.dir, filesep, p.defaultParameters.session.filestem, '.pdf']);
        p.defaultParameters.plot.fig = []; % avoid saving the figure to data
    end
    
    % ----------------------------------------------------------------%
    %% make the session parameterStruct active
    p.defaultParameters.setLevels(levelsPreTrials);
    p.trial = p.defaultParameters;

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
    if(p.defaultParameters.sound.use)
        % Close the audio device:
        PsychPortAudio('Close', p.defaultParameters.sound.master);
    end

    % ----------------------------------------------------------------%
    %% Shut down TDT UDP connection
    if p.defaultParameters.tdt.use
        pds.tdt.close(p);
    end
    
    % ----------------------------------------------------------------%
    %% save the session data to file
    
    % save defaultParameters as they are at the end of the session
    tmpts = mergeToSingleStruct(p.defaultParameters);

    save(fullfile(p.defaultParameters.session.trialdir, ...
             [p.defaultParameters.session.filestem, '_FinalDefaultParameters.pds']), ...
             '-struct', 'tmpts', '-mat', '-v7.3');

% ----------------------------------------------------------------%
    %% close screens
    if(~p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay)
        glDeleteTextures(2,glGenTextures(1));
    end

    Screen('CloseAll');

    sca;

catch me
    sca
    if(isfield(p, 'trial.sound.use'))
        if(p.trial.sound.use)
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

% ----------------------------------------------------------------%
%%  Pausing of experiment
function pauseLoop(p)
    KbQueueStart;
    
    while(true)
        %the keyboard chechking we only capture ctrl+alt key presses.
        [p.trial.keyboard.pressedQ,  p.trial.keyboard.firstPressQ]=KbQueueCheck(); % fast

        if(any(p.trial.keyboard.firstPressQ))

            qp = find(p.trial.keyboard.firstPressQ); % identify which key was pressed

            switch qp

                % ----------------------------------------------------------------%
                case p.trial.key.reward
                % reward
                % check for manual reward delivery via keyboard
                    pds.reward.give(p, p.trial.reward.ManDur);  % per default, output will be channel three.

                % ----------------------------------------------------------------%
                case p.trial.key.pause
                % un-pause trial
                    p.trial.pldaps.pause = 0;
                    ND_CtrlMsg(p,'Pause cancelled.');
                    pds.datapixx.strobe(p.trial.event.UNPAUSE);
    %                 p.trial.EV.Unpause = GetSecs;
                    break;

                % ----------------------------------------------------------------%
                case p.trial.key.break
                % un-break trial
                    p.trial.pldaps.pause = 0;
                    ND_CtrlMsg(p,'Break cancelled.');
                    pds.datapixx.strobe(p.trial.event.UNBREAK);
    %                 p.trial.EV.Unpause = GetSecs;
                    break;

                % ----------------------------------------------------------------%
                case p.trial.key.quit
                % quit experiment
                    p.trial.pldaps.quit = 2;
                    ShowCursor;
                    break;
                    
                % ----------------------------------------------------------------%
                case p.trial.key.spritz
                % Send a TTL pulse to the picospritzer to trigger drug release
                    ND_PulseSeries(p.trial.datapixx.TTL_spritzerChan,      ...
                                   p.trial.datapixx.TTL_spritzerDur,       ...
                                   p.trial.datapixx.TTL_spritzerNpulse,    ...
                                   p.trial.datapixx.TTL_spritzerPulseGap,  ...
                                   p.trial.datapixx.TTL_spritzerNseries,   ...
                                   p.trial.datapixx.TTL_spritzerSeriesGap, ...
                                   p.defaultParameters.event.INJECT);
            end  %  switch qp
        end  % if(any(p.trial.keyboard.firstPressQ))
        
        pause(0.1);
    end  %  while(true)
