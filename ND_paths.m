% ND_paths
% set paths to run experiments and develop PLDAPS code in the Disney-Lab.

%% Add PLDAPS paths to matlab
loadPLDAPS;  % make sure file exists, otherwise modify from PLDAPS template and copy to a known location, e.g. ~/Documents/MATLAB/

%% Get the directory where this script resides to add the paths relatively
[pathStr,~,~] = fileparts(mfilename('fullpath'));

%% general paths required to run the code
addpath(fullfile(pathStr,'utils'));
addpath(fullfile(pathStr,'grfx'));
addpath(fullfile(pathStr,'trial_routines'));
addpath(fullfile(pathStr,'misc'));
addpath(fullfile(pathStr,'defaults'));
addpath(fullfile(pathStr,'flow'));


%% task specific sub-directories
addpath(fullfile(pathStr,'tasks/get_joy'));
addpath(fullfile(pathStr,'tasks/joy_train'));
