% ND_paths
% set paths to run experiments and develop PLDAPS code in the Disney-Lab.
%
% Add root path to ND_PLDAPS to matlab

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
