function ND_CaliReward(rewtm, nrep, gap)
% function for quick&dirty reward calibration.
%
% rewtm:  duration of reward pulse [in seconds]
%
% nrep:   how often provide reward pulses
%
% gap:    break between subsequent reward [in seconds]
%
%
% wolf zinke, March 2017

if (~exist('rewtm','var') || isempty(rewtm))
    error('What are you doing? You need at least know what reward duration to measure!'); 
end

if (~exist('nrep','var') || isempty(nrep))
    nrep = 100; 
end

if (~exist('gap','var') || isempty(gap))
    gap = 1.0; 
end


% init Datapixx:
if(~Datapixx('IsReady'))
    Datapixx('Open');
    Datapixx('RegWrRd');
    keep_open = 0;
else
    keep_open = 1;
end

for(i=1:nrep) 
    ND_FlushReward(rewtm); 
    WaitSecs(gap); 
end


if(Datapixx('IsReady') && ~keep_open)
    Datapixx('Close');
end

