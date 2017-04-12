function p = ND_BeginExperiment(p)
%beginExperiment    initialize an Exeriment
% p = beginExperiment(p)
% initialize the beginning of time for this experiment
% beginExperiment checks which devices are connected to PLDAPS and gets
% timestamps from each of them and stores them in the devives substructures
% of p.defeaultParameters

% 12/2013 jly   wrote it
% 01/2014 jly   make sure Eyelink is connected before trying to get time
%               from it
% 05/2015 jk    adapted it to pldaps 4.1
% 10/2016 jk    bumped version to 4.2
%
% 03/2017 wz    removed eyelink related stuff
%               make git information more flexible by reading out actual version
%
%
% WZ TODO: get git hash/version for PsychToolbox as well
%

%% keep git version control
pathStr = fileparts(mfilename('fullpath'));
pathStr = fileparts(pathStr);

cwd = pwd;

cd(pathStr)

gitnfo = getGitInfo;

p.defaultParameters.pldaps.git.hash   = gitnfo.hash;
p.defaultParameters.pldaps.git.branch = gitnfo.branch;
p.defaultParameters.pldaps.git.dir    = pathStr;

cd(cwd);

%% get session time
% multiple sessions not supported for now
p.defaultParameters.session.experimentStart = GetSecs;

if(Datapixx('IsReady'))
    p.defaultParameters.datapixx.experimentStartDatapixx = Datapixx('GetTime');
end


