function p = ND_GeneralTrialRoutines(p, state)
% This function provides general routines for each trial state that likely
% will be needed in a comparable form in all trials. By keeping these routines
% in a separate file it is possible to separate them from the actual task code.
% This function is the custom variant of pldapsDefaultTrialFunction in the PLDAPS
% package adapted to the needs of the Disney-Lab.
%
%
% wolf zinke, Jan. 2017


% ####################################################################### %
%% Initial call of this function. Use this to define general settings of the experiment/session.
% Here, default parameters of the pldaps class could be adjusted if needed
if(isempty(state))
    % --------------------------------------------------------------------%
    %% Initialise session
    % p = ND_PrepSession(p);  % Do init
    % p.defaultParameters.(task).randomNumberGenerater = 'mt19937ar'; % WZ: just copied from the pldaps plain function, can not find an instance where it is used...

else
% ####################################################################### %
%% Subsequent calls during actual trials
% execute trial specific commands here.

    switch state
% ####################################################################### %
% DONE BEFORE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialSetup
        %% trial set-up
        % prepare everything for the trial, including allocation of stimuli
        % and all other more time demanding stuff.
            p = ND_TrialSetup(p);

        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialPrepare
        %% trial preparation
        % just prior to actual trial start, use it for time sensitive preparations;
            p = ND_TrialPrepare(p); % this defines the actual trial start time

% ####################################################################### %
% DONE DURING THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameUpdate
        %% collect data (i.e. a hardware module) and store it
            ND_FrameUpdate(p);
            
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameDraw
        %% Display stuff on the screen
        % Just call graphic routines, avoid any computations
            ND_FrameDraw(p);

        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameFlip;
        %% Flip the graphic buffer and show next frame
            ND_FrameFlip(p);

% ####################################################################### %
% DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
            p = ND_TrialCleanUpandSave(p); % end all trial related processes

% ####################################################################### %
% DONE BETWEEN SUBSEQUENT TRIALS:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.experimentAfterTrials
        %% AfterTrial
        % pass on information between trials
%              p = ND_AfterTrial(p);

    end  %/ switch state

    %% get the current time
    % Define it here at a clear time point and use it later on whenever the 
    % current time is needed instead of calling GetSecs every time.
    p.trial.CurTime = GetSecs;
    p.trial.AllCurTimes(p.trial.iFrame) = p.trial.CurTime;

end  %/  if(nargin == 1) [...] else [...]
