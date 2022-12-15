 % Function to run task for experiment
function p = ReportChange(p, state)

    % Checking for task name and filling if empty
    if(~exist('state','var'))
        state = [];
    end
    
     % Initializing task
    if(isempty(state))
        % Populating pldaps object with elements needed to begin task if empty
        p = AttendGrat_init(p);

    else
        % If pldaps object is populated, standard trial routines run
        p = ND_GeneralTrialRoutines(p, state);

        % Executing events/epochs that make up trial
        switch state
            % Gathing information to start trial
            case p.trial.pldaps.trialStates.trialSetup
                %TaskSetUp(p);  

            % Perparing gathered information before trial launch to ensure precise timing    
            case p.trial.pldaps.trialStates.trialPrepare
                p.trial.EV.TrialStart = p.trial.CurTime;

            % Launching trial    
            case p.trial.pldaps.trialStates.framePrepareDrawing 
                % Function for doing task-specific actions using keyboard
                % commands--not set up, look at DetectGrat for reference 
                %if(~isempty(p.trial.LastKeyPress))
                    %KeyAction(p);
                %end
                %TaskDesign(p);
            
            % Cleaning up items used for trial and saving data
            case p.trial.pldaps.trialStates.trialCleanUpandSave
                %TaskCleanAndSave(p);
                
        end
    end