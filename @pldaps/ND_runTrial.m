function p = ND_runTrial(p)
% ND_runTrial   runs a single Trial by calling the function defined in 
%               p.trial.pldaps.trialFunction through different states
%
% 03/2013 jly   Wrote hyperflow
% 03/2014 jk    Used jly's code to get the PLDAPS structure and frame it into a class
%               might change to ASYNC buffer flipping. but won't for now.
%
% 02/2017 wolf zinke started cleaning up for neurodisney purposes
% 04/2018 WZ: merged ND_GeneralTrialRoutines into this function

%% the trialFunctionHandle
tfh = str2func(p.trial.pldaps.trialFunction);

%% initial trial setup
p.trial.pldaps.trialStates.Current = p.trial.pldaps.trialStates.trialSetup; 
p = ND_TrialSetup(p);
p = GetCurrentTime(p);
tfh(p, p.trial.pldaps.trialStates.trialSetup);

%% switch to high priority mode
if(p.trial.pldaps.maxPriority)
    oldPriority = Priority;
    maxPriority = MaxPriority('GetSecs');
    if(oldPriority < maxPriority)
            Priority(maxPriority);
    end
end

%% will be called just before the trial starts for time critical calls to start data acquisition
p.trial.pldaps.trialStates.Current = p.trial.pldaps.trialStates.trialPrepare; 
p = ND_TrialPrepare(p);
p = GetCurrentTime(p);
tfh(p, p.trial.pldaps.trialStates.trialPrepare);

%%% MAIN WHILE LOOP %%%
while(~p.trial.flagNextTrial && ~p.trial.pldaps.quit)
    %g o through one frame by calling tfh with the different states.
    % Save the times each state is finished.

    % iterate through trial states
    for(ts = 1:length(p.trial.pldaps.trialStates.InTrialList))

        cTS = p.trial.pldaps.trialStates.InTrialList(ts);
        p.trial.pldaps.trialStates.Current = cTS; 

        if(p.trial.pldaps.GetTrialStateTimes)
           setTimeAndFrameState(p, cTS);  
        end

        %% check default trial states
        switch cTS
            case p.trial.pldaps.trialStates.frameUpdate
            % collect data (i.e. a hardware module) and store it
                ND_FrameUpdate(p);

            case p.trial.pldaps.trialStates.frameDraw
            % Display stuff on the screen
            % Just call graphic routines, avoid any computations
                ND_FrameDraw(p);

            case p.trial.pldaps.trialStates.frameFlip;
            % Flip the graphic buffer and show next frame
                ND_FrameFlip(p);
        end  

        %% get the current time
        % Define it here at a clear time point and use it later on whenever the 
        % current time is needed instead of calling GetSecs every time.
        p = GetCurrentTime(p);

        % call the main trial function and pass the current trial state on to it
        tfh(p, cTS);  
    end

    %advance to next frame        
    p.trial.iFrame = p.trial.iFrame + 1;  % update frame index

end %while Trial running

%% reset high priority mode
if(p.trial.pldaps.maxPriority)
    
    newPriority = Priority;
    
    if(round(oldPriority) ~= round(newPriority))
        Priority(oldPriority);
    end
    
    if(round(newPriority) < maxPriority)
        warning('pldaps:runTrial','Thread priority was degraded by operating system during the trial.')
    end
end

p.trial.pldaps.trialStates.Current = p.trial.pldaps.trialStates.trialCleanUpandSave; 
p = ND_TrialCleanUpandSave(p); % end all trial related processes
p = GetCurrentTime(p);
tfh(p, p.trial.pldaps.trialStates.trialCleanUpandSave);

p = ND_AfterTrial(p); %Currently not used

p.trial.pldaps.trialStates.Current = NaN; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% helper functions

function p = GetCurrentTime(p)
    p.trial.CurTime = GetSecs;
    p.trial.AllCurTimes(p.trial.iFrame) = p.trial.CurTime; % WZ: make this optional for debugging/profiling purpose only?
    p.trial.remainingFrameTime = p.trial.nextFrameTime - p.trial.CurTime;

%%
function p = setTimeAndFrameState(p, state)
        p.trial.ttime = GetSecs - p.trial.trstart;
        p.trial.timing.frameStateChangeTimes(state, p.trial.iFrame) = ...
                           p.trial.ttime - p.trial.nextFrameTime + p.trial.display.ifi;
