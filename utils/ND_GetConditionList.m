function p = ND_GetConditionList(p, cnd, maxTrials_per_BlockCond, maxBlocks)
% generate sequence of blocks and conditions
% 
% TODO: add more flexibility for the randomization
%
% wolf zinke, Dec. 2016

    Ncond               = length(cnd);
    maxTrials_per_Block = maxTrials_per_BlockCond * Ncond;
    maxTrials           = maxTrials_per_Block * maxBlocks;
    
    BlockCondSet = repmat(1:Ncond, 1, maxTrials_per_BlockCond);
    CNDlst = nan(1, maxTrials);
    BLKlst = nan(1, maxTrials);
    
    % pre-define order of conditions
    for(cblk = 1:maxBlocks)
        Blk = ((cblk-1) * maxTrials_per_Block) + 1;
        CNDlst(Blk:Blk+maxTrials_per_Block-1) = BlockCondSet(randperm(maxTrials_per_Block));
        BLKlst(Blk:Blk+maxTrials_per_Block-1) = cblk;
    end
    
    p.conditions   = cnd(CNDlst);
    p.trial.blocks = BLKlst; % WZ: added this to pldaps, seems that they do not use the concept of blocks
        
    p.defaultParameters.pldaps.finish = maxTrials; 
