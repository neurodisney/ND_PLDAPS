function p = ScreenFlash_aftertrial(p)
% this function is executed after a trial for example to save task specific 
% information across trials or to make decicicions about future trials
% based of the previous trials (i.e. utilizing the Palamedes Toolbox)
%
%
% Nate Faber & wolf zinke, Sep 2017

% ------------------------------------------------------------------------%
%% Add information to the data struct
p.defaultParameters.data.RewDelay = p.trial.task.CurRewDelay;
p.defaultParameters.data.RewCnt   = p.trial.reward.iReward;

% ------------------------------------------------------------------------%
%% utilize previous trials for selection of next condition
