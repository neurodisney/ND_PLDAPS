function p = RGBcalibration_aftertrial(p)
% this function is executed after a trial for example to save task specific 
% information across trials or to make decicicions about future trials
% based of the previous trials (i.e. utilizing the Palamedes Toolbox)
%
%
% Nate Faber & wolf zinke, Sep 2017

% ------------------------------------------------------------------------%
%% Add information to the data struct

% ------------------------------------------------------------------------%
%% utilize previous trials for selection of next condition
