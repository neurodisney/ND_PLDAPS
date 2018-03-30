% ND_paths
% set paths to run experiments and develop PLDAPS code in the Disney-Lab.
%
% Add root path to ND_PLDAPS to matlab
%
% wolf zinke


%% Get the directory where this script resides to add the paths relatively to it
[pathStr,~,~] = fileparts(mfilename('fullpath'));

% cd to this directory
cd(pathStr);

% generate all paths from this root
a = genpath(pathStr);
b = textscan(a,'%s','delimiter',':');
b = b{1};

% remove git directories
b(~cellfun(@isempty,strfind(b, '.git'))) = [];
b(~cellfun(@isempty,strfind(b, 'tasks/archived'))) = [];
b(~cellfun(@isempty,strfind(b, 'documentation')))  = [];

% add all paths
addpath(b{:})

display([pathStr, ' added to the path']);

