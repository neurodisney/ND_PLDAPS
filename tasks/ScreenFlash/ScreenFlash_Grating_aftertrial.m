function p = ScreenFlash_Grating_aftertrial(p)
% this function is executed after a trial for example to save task specific 
% information across trials or to make decicicions about future trials
% based of the previous trials (i.e. utilizing the Palamedes Toolbox)
%
%
% Veronica Galvin, Sept. 2021

% ------------------------------------------------------------------------%
%% Add information to the data struct
%p.defaultParameters.data.RewDelay = p.trial.task.CurRewDelay;
%p.defaultParameters.data.RewCnt   = p.trial.reward.iReward;

% ------------------------------------------------------------------------%
%% utilize previous trials for selection of next condition
