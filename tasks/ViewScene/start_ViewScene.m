% Function to run experiment
function p = start_ViewScene(subjectname, rig)

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
    SS.display.useC48        = 1; %TEST: color output via C48
    SS.display.useOverlay    = 0; %no overlay in C48 test mode

    % Specifying task: calling ViewScene.m file
    exp_fun = 'ViewScene'; 

    % Loading task information into pldaps matrix
    SS.pladaps.trialFunction = exp_fun; 

    % Loading task-specific parameters: calling ViewScene_taskdef.m file 
    SS.task.TaskDef = 'ViewScene_taskdef';
    
    % Specifying which matrix variables can be edited for future trials
    SS.editable = {};

    % Loading non-default rig settings into pldaps matrix
    SS.pldaps.draw.eyepos.use = 1;
    SS.pldaps.draw.grid.use = 0;
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
