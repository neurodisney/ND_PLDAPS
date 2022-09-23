% Main function to run task
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

% Initializing big matrix in which to store task information, then loading it with default settings for rig
SS = ND_RigDefaults(rig); 

% Specifying task
exp_task = 'AttendGrat'; 

% Loading task information into big matrix
SS.pladaps.trialFunction = exp_task; 

% SS.task.TaskDef = 'AttendGrat_taskdef'; % Loading additional, more specific task parameters into big matrix 
% SS.task.AfterTrial = 'AttendGrat_aftertrial'; % Loading actions that will be run post-trial into big matrix 
% SS.editable = {}; % Specifying which variables can be edited from trial to trial


