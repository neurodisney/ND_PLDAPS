function p = ND_GenCndLst(p)
% generate sequence of blocks and conditions, update the list during the session
%
%
% wolf zinke, Sep. 2017

if(p.trial.Block.GenBlock == 1)  
%% generate a new block
    % if there is a desired number of blocks use this to pre-allocate, 
    % otherwise add one block after another
    if(p.trial.Block.maxBlocks < 0)
        maxBlocks = 1;
    else
        maxBlocks = p.Block.maxBlocks;
    end

    Ncond = length(p.trial.Block.Conditions); % how many conditions do we have

    if(length(p.trial.Block.maxBlockTrials) == 1)
        maxTrialsCond = repmat(p.trial.Block.maxBlockTrials, 1, Ncond);
    elseif(length(p.trial.Block.maxBlockTrials) ~= Ncond)
        error('List of number of trials per condition must match number of conditions!');
    end

    maxTrials_per_Block = sum(maxTrialsCond);  % how many trials are defining a block

    % ordered list of conditions for a single block
    BlockCondSet = [];
    for(i = 1:Ncond)
        BlockCondSet = [BlockCondSet, repmat(i, 1, maxTrialsCond(i))];
    end

    % is the total number of trials pre-defiend or do we run until experimenter break?
    maxTrials = maxTrials_per_Block * maxBlocks;   % total number of trials for all blocks

    if(p.trial.Block.maxBlocks > 0)
        p.trial.pldaps.finish = maxTrials;
    end

    % pre-allocate
    CNDlst = nan(1, maxTrials);
    BLKlst = nan(1, maxTrials);

    % pre-define order of conditions
    for(i = 1:maxBlocks)
        Blk = ((i-1) * maxTrials_per_Block) + 1;
        CNDlst(Blk:Blk+maxTrials_per_Block-1) = BlockCondSet(randperm(maxTrials_per_Block)); % shuffle order
        BLKlst(Blk:Blk+maxTrials_per_Block-1) = i;
    end

    p.conditions   = [p.conditions, cnd(CNDlst)];
    p.trial.blocks = [p.trial.blocks, BLKlst]; 

    p.Block.GenBlock = 0; % just generated a block, so no need to do it again

else
%% update condition/block list

    % do we need to repeat conditions?
    if(p.trial.task.EqualCorrect && ~p.trial.pldaps.goodtrial) % need to check if success, repeat if not    
        curCND = p.conditions{p.trial.pldaps.iTrial};
        curBLK = p.trial.blocks(p.trial.pldaps.iTrial);

        poslst = 1:length(p.conditions);
        cpos   = find(poslst > p.trial.pldaps.iTrial & p.trial.blocks == curBLK);

        InsPos = cpos(randi(length(cpos))); % determine random position in the current block for repetition

        p.conditions   = [p.conditions(  1:InsPos-1), curCND,  p.conditions(  InsPos:end)];
        p.trial.blocks = [p.trial.blocks(1:InsPos-1), curBLK,  p.trial.blocks(InsPos:end)];

        if(isfinite(p.trial.pldaps.finish))
            p.trial.pldaps.finish = p.trial.pldaps.finish + 1; % added a required trial
        end
    end
    
    % Do we need to generate a new block?
    if(p.trial.pldaps.iTrial == length(p.conditions) && ~isfinite(p.trial.pldaps.finish))
         p.Block.GenBlock = 1;
         p = ND_GenCndLst(p);
    elseif(p.trial.pldaps.iTrial == p.trial.pldaps.finish)
        p.trial.pldaps.quit = 1;
    end
end


