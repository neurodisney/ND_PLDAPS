% John Amodeo, 2023


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

    % Specifying task: calling FreeChoice.m file
    exp_fun = 'FreeChoice'; 

    % Loading task information into pldaps matrix
    SS.pladaps.trialFunction = exp_fun; 

    % Loading task-specific parameters: calling FreeChoice_taskdef.m file 
    SS.task.TaskDef = 'FreeChoice_taskdef';

    % Specifying which matrix variables can be edited for future trials
    SS.editable = {};

    % Loading non-default rig settings into pldaps matrix
    SS.pldaps.draw.eyepos.use = 1;
    SS.pldaps.draw.grid.use = 1;
    SS.datapixx.useAsEyepos = 1;
    %SS.pldaps.draw.joystick.use   = 0; % 9/19/2025 - MJH joystick drawing seems to be the default, need to suppress.
    SS.datapixx.adc.srate = 1000;

    SS.datapixx.TTL_trialOn       = 0; % 10/8/2025, MJH - w/o this flag, an error emerges due to missing Communications toolbox which our scripts are using a deprecated function that is no longer in the toolbox....this may require an update to the TTL script at some point in the future...



    % Creating pldaps object
    p = pldaps(subjectname, SS, exp_fun);

    % Command to run experimemt
    p.run;


    % Closing DataPixx when experiment complete
    if(Datapixx('IsReady'))
        Datapixx('Close');
    end

