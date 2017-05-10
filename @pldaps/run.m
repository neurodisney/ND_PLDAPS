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
    if(p.trial.pldaps.pause.type==1 && p.trial.pldaps.pause.preExperiment==true) %0=don't,1 is debugger, 2=pause loop
        p  %#ok<NOPRT>
        disp('Ready to begin trials. Type return to start first trial...')
        keyboard %#ok<MCKBD>
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

            % ----------------------------------------------------------------%
            %% create new trial struct

            % create temporary trial struct
            tmpts = mergeToSingleStruct(p.defaultParameters);

            % quick and nasty fix to avoid saving of online plots
            if(p.defaultParameters.plot.do_online)
               tmpts.plot.fig = [];
            end

            % save default parameters to trial data directory
            if(trialNr == 1)
                save(fullfile(p.defaultParameters.session.trialdir, ...
                             [p.defaultParameters.session.filestem, '_InitialDefaultParameters.pds']), ...
                             '-struct','-mat','-v7.3', 'tmpts');
            end

            % easiest (and quickest) way to create a deep copy is to save it as mat file and load it again
            tmp_ptrial = fullfile(p.defaultParameters.session.tmpdir, 'deepTrialStruct');
            save(tmp_ptrial, 'tmpts');
            clear tmpts
            load(tmp_ptrial);
            p.trial = tmpts;
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
            %% processes after trial
            p = ND_UpdateTrial(p);
            p = ND_AfterTrial(p);

            % ----------------------------------------------------------------%
            %% make online plots
            if(p.defaultParameters.plot.do_online)
                feval(p.defaultParameters.plot.routine,  p);
                p.trial.plot.fig = []; % avoid saving the figure to data
            end
            
            % ----------------------------------------------------------------%
            %% complete trial: save trial data
            result = saveTrialFile(p);

            if(~isempty(result))
                disp(result.message)
            end
            
        else %dbquit == 1 is meant to be pause. should we halt datapixx?

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
    %% save the session data to file

    % save online plot
    if(p.defaultParameters.plot.do_online)
        ND_fig2pdf(p.defaultParameters.plot.fig, [p.defaultParameters.session.dir, filesep, p.defaultParameters.session.filestem, '.pdf']);
        p.defaultParameters.plot.fig = []; % avoid saving the figure to data
        %hgexport(gcf, [p.defaultParameters.session.filestem, '.pdf'], hgexport('factorystyle'), 'Format', 'pdf');
    end

    % save defaultParameters as they are at the end of the session
    tmpts = mergeToSingleStruct(p.defaultParameters);

    save(fullfile(p.defaultParameters.session.trialdir, ...
             [p.defaultParameters.session.filestem, '_FinalDefaultParameters.pds']), ...
             '-struct','-mat','-v7.3', 'tmpts');

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

end

% ----------------------------------------------------------------%
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
                pds.reward.give(p, p.trial.reward.ManDur);  % per default, output will be channel three.

                %D: Debugger
%             case KbName(p.trial.key.debug)
%                 disp('stepped into debugger. Type return to start first trial...')
%                 keyboard %#ok<MCKBD>
%
%                 %P: PAUSE (end the pause)
%             case KbName(p.trial.key.pause)
%                 dv.trial.pldaps.quit = 0;
%                 ListenChar(2);
%                 HideCursor;
%                 break;

                %Q: QUIT
            case KbName(p.trial.key.quit)
                dv.trial.pldaps.quit = 2;
                break;

                %X: Execute text selected in Matlab editor
%             case KbName(p.trial.key.exe)
%                 activeEditor=matlab.desktop.editor.getActive;
%                 if isempty(activeEditor)
%                     display('No Matlab editor open -> Nothing to execute');
%                 else
%                     if isempty(activeEditor.SelectedText)
%                         display('Nothing selected in the active editor Widnow -> Nothing to execute');
%                     else
%                         try
%                             eval(activeEditor.SelectedText)
%                         catch ME
%                             display(ME);
%                         end
%                     end
%                 end
        end  %  switch qp
    end  % if(any(p.trial.keyboard.firstPressQ))
    pause(0.1);
end  %  while(true)
end % function pauseLoop(dv)
