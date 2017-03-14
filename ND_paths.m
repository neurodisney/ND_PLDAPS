% ND_paths
% set paths to run experiments and develop PLDAPS code in the Disney-Lab.

%% Add PLDAPS paths to matlab
%loadPLDAPS;  % make sure file exists, otherwise modify from PLDAPS template and copy to a known location, e.g. ~/Documents/MATLAB/

%% Get the directory where this script resides to add the paths relatively
[pathStr,~,~] = fileparts(mfilename('fullpath'));


    dirs{1}=pathStr;

    for j=1:length(dirs)
        a=genpath(dirs{j});
        b=textscan(a,'%s','delimiter',':');
        b=b{1};
        b(~cellfun(@isempty,strfind(b,'.git')))=[];
        addpath(b{:})
        display([dirs{j} ' added to the path']);
    end


%  %% general paths required to run the code
%  addpath(fullfile(pathStr,'utils'));
%  addpath(fullfile(pathStr,'grfx'));
%  addpath(fullfile(pathStr,'trial_routines'));
%  addpath(fullfile(pathStr,'flow'));
%  
%  addpath(fullfile(pathStr,'defaults'));
%  addpath(fullfile(pathStr,'misc'));
%  
%  %% task specific sub-directories
%  addpath(fullfile(pathStr,'tasks/get_joy'));
%  addpath(fullfile(pathStr,'tasks/joy_train'));
