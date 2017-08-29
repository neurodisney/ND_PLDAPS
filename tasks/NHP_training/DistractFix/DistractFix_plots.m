function p = DistractFix_plots(p)
%% Online analysis for Delayed Saccade

% Get the directory this plot file resides in
filename = mfilename('fullpath');
[directory,~,~] = fileparts(filename);

% R script name
rscript = fullfile(directory,'DistractFix_Behav.r');

% Get the command
command = [rscript ' ' p.defaultParameters.session.dir];

% Run the script
[~,~] = system(command);