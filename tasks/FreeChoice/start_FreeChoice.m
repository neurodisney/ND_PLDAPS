% Function to run experiment
function p = start_FreeChoice(subjectname, rig)

    % Checking for subject name and filling if empty
    if(~exist('subjectname', 'var') || isempty(subjectname))
        subjectname = 'test';
    end

    % Checking for rig name and filling if empty
    if(~exist('rig', 'var') || isempty(rig)) 
        [~,rigname] = system('hostname');
        rig = str2num(rigname);
    end

    % Creating pldaps matrix to store task information, and loading it with 
    % default rig settings
    SS = ND_RigDefaults(rig); 

    % Specifying task: calling AttendGrat.m file
    exp_fun = 'FreeChoice'; 

    % Loading task information into pldaps matrix
    SS.pladaps.trialFunction = exp_fun; 

    % Loading task-specific parameters: calling AttendGrat_taskdef.m file 
    SS.task.TaskDef = 'FreeChoice_taskdef';
    
    % Loading actions for post-trial: calling AttendGrat_aftertrial.m file
    % SS.task.AfterTrial = 'PercEqui_aftertrial';

    % Specifying which matrix variables can be edited for future trials
    SS.editable = {};

        % Loading non-default rig settings into pldaps matrix
    SS.pldaps.draw.eyepos.use = 1;
    SS.pldaps.draw.grid.use = 1;
    SS.datapixx.useAsEyepos = 1;
    SS.datapixx.adc.srate = 1000;

    % Creating pldaps object
    p = pldaps(subjectname, SS, exp_fun);

    % Command to run experimemt
    p.run;

    % Closing DataPixx when experiment complete
    if(Datapixx('IsReady'))
        Datapixx('Close');
    end

