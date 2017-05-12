function p = DelayedSaccade_aftertrial(p)
% this function is executed after a trial for example to save task specific 
% information across trials or to make decicicions about future trials
% based of the previous trials (i.e. utilizing the Palamedes Toolbox)
%
%
% wolf zinke, May. 2017

% ------------------------------------------------------------------------%
%% Add information tot the Trial Track struct
p.defaultParameters.TrialTrack.RewDelay = p.trial.task.CurRewDelay;
p.defaultParameters.TrialTrack.RewCnt   = p.trial.reward.iReward;    

% ------------------------------------------------------------------------%
%% utilize previous trials for selection of next condition
