% ND_paths
% set paths to run experiments and develop PLDAPS code in the Disney-Lab.

%% Add PLDAPS paths to matlab
loadPLDAPS;  % make sure file exists, otherwise modify from PLDAPS template and copy to a known location, e.g. ~/Documents/MATLAB/

%% general paths required to run the code
addpath('~/Experiments/ND_PLDAPS/utils');
addpath('~/Experiments/ND_PLDAPS/grfx');
addpath('~/Experiments/ND_PLDAPS/trial_routines');
addpath('~/Experiments/ND_PLDAPS/misc');


%% task specific sub-directories
addpath('~/Experiments/ND_PLDAPS/tasks/get_joy');
addpath('~/Experiments/ND_PLDAPS/tasks/joy_train');
