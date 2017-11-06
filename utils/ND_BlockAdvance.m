function ND_BlockAdvance(p)
% Advance to the next block

curBLK = p.trial.Block.BlockList(p.trial.pldaps.iTrial);
poslst = 1:length(p.conditions);
cpos   = find(poslst > p.trial.pldaps.iTrial & p.trial.Block.BlockList == curBLK);

p.trial.Block.BlockList(cpos) = [];
p.conditions(cpos) = [];

if(isfinite(p.trial.pldaps.finish)) % predefined list, advancing means reducing number of trials
    p.trial.pldaps.finish = length(p.conditions);
else
    p.trial.Block.GenBlock = 1;
end

ND_CtrlMsg(p, 'Advanced to next Block');