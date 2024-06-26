% Function to run experiment
function p = start_AttendGrat(subjectname, rig)

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
    exp_fun = 'AttendGrat'; 

    % Loading task information into pldaps matrix
    SS.pladaps.trialFunction = exp_fun; 

    % Loading task-specific parameters: calling AttendGrat_taskdef.m file 
    SS.task.TaskDef = 'AttendGrat_taskdef';

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
    
    % Collecting receptive field (RF) coordinates from user for stimulus display
    RFpos = input('What are the mapped RF [x,y] coordinates, as an array? (press enter for default values): ');
    if isempty(RFpos)
        RFpos = [-4,4];
    end
    p.trial.task.RFpos = RFpos;
    
    % Collecting receptive field (RF) size from user, and scaling grating size with it 
    RFsize = input('What is the radius of the mapped RF? (press enter for default value): ');
    if isempty(RFsize)
       RFsize = 1; 
    end
    p.trial.stim.RING.radius = RFsize + 0.5;
    p.trial.stim.DRIFTGABOR.radius = RFsize;
    
    % Collecting contrast value based on response threshold from user for rings
    cStep = input('What is a contrast step number near response threshold? (press enter for default value): ');
    if isempty(cStep)
        cStep = 2;
    end
    p.trial.task.cStep = cStep;
    
    % Collecting orientations 0.5 standard deviation (SD) from peak on tuning curve for grating assignment
    oriRange = input('What orienations are + and -0.5 SD from preferred, as an array? (press enter for default values): ');
    if isempty(oriRange)
        oriRange = [0, 176];
    end   
    p.trial.task.oriRange = oriRange;

    % Collecting orientation change detection threshold
    oriThreshold = input('What orientation change magnitude, in degrees, is at detection threshold? (press enter for default value): '); 
    if isempty(oriThreshold)
        oriThreshold = 50;
    end
    p.trial.task.oriThreshold = oriThreshold;
    
    % Command to run experimemt
    p.run;

    % Closing DataPixx when experiment complete
    if(Datapixx('IsReady'))
        Datapixx('Close');
    end


