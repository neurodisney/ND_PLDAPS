function p = ND_runTrial(p)
%runTrial    runs a single Trial by calling the function defined in 
%            p.trial.pldaps.trialFunction through different states
%
% 03/2013 jly   Wrote hyperflow
% 03/2014 jk    Used jly's code to get the PLDAPS structure and frame it into a class
%               might change to ASYNC buffer flipping. but won't for now.
%
% 02/2017 wolf zinke started cleaning up for neurodisney purposes

    %the trialFunctionHandle
    tfh = str2func(p.trial.pldaps.trialFunction);
    
    tfh(p, p.trial.pldaps.trialStates.trialSetup);
    
    % switch to high priority mode
    if(p.trial.pldaps.maxPriority)
        oldPriority = Priority;
        maxPriority = MaxPriority('GetSecs');
        if(oldPriority < maxPriority)
                Priority(maxPriority);
        end
    end

    %w ill be called just before the trial starts for time critical calls to start data acquisition
    tfh(p, p.trial.pldaps.trialStates.trialPrepare);

    %%% MAIN WHILE LOOP %%%
    %-------------------------------------------------------------------------%
    while(~p.trial.flagNextTrial && ~p.trial.pldaps.quit)
        %g o through one frame by calling tfh with the different states.
        % Save the times each state is finished.

        %time of the estimated next flip
        p.trial.nextFrameTime = p.trial.stimulus.timeLastFrame + p.trial.display.ifi;

        % Frame Update
        if(p.trial.pldaps.GetTrialStateTimes)
            setTimeAndFrameState(p,p.trial.pldaps.trialStates.frameUpdate);  
        end
        tfh(p, p.trial.pldaps.trialStates.frameUpdate);
        
        % Frame Prepare Drawing
        if(p.trial.pldaps.GetTrialStateTimes)
            setTimeAndFrameState(p,p.trial.pldaps.trialStates.framePrepareDrawing)
        end
        tfh(p, p.trial.pldaps.trialStates.framePrepareDrawing);
        
        % Frame Draw
        if(p.trial.pldaps.GetTrialStateTimes)
            setTimeAndFrameState(p,p.trial.pldaps.trialStates.frameDraw);
        end
        tfh(p, p.trial.pldaps.trialStates.frameDraw);

        % Frame Flip
        if(p.trial.pldaps.GetTrialStateTimes)
            setTimeAndFrameState(p,p.trial.pldaps.trialStates.frameFlip)
        end
        tfh(p, p.trial.pldaps.trialStates.frameFlip);
        
        %advance to next frame        
        p.trial.iFrame = p.trial.iFrame + 1;  % update frame index
        
    end %while Trial running

    if p.trial.pldaps.maxPriority
        newPriority=Priority;
        if round(oldPriority) ~= round(newPriority)
            Priority(oldPriority);
        end
        if round(newPriority)<maxPriority
            warning('pldaps:runTrial','Thread priority was degraded by operating system during the trial.')
        end
    end
    
    tfh(p, p.trial.pldaps.trialStates.trialCleanUpandSave);

end %runTrial
    
function setTimeAndFrameState(p, state)
        p.trial.ttime = GetSecs - p.trial.trstart;
        p.trial.remainingFrameTime = p.trial.nextFrameTime - p.trial.ttime;
        p.trial.timing.frameStateChangeTimes(state, p.trial.iFrame) = ...
                           p.trial.ttime - p.trial.nextFrameTime + p.trial.display.ifi;
end