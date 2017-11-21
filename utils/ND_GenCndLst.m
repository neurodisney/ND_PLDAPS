function p = ND_GenCndLst(p)
% generate sequence of blocks and conditions, update the list during the session
%
%
% wolf zinke, Sep. 2017

if(p.defaultParameters.Block.GenBlock == 1)  
%% generate a new block
    % if there is a desired number of blocks use this to pre-allocate, 
    % otherwise add one block after another
    if(p.defaultParameters.Block.maxBlocks < 0)
        maxBlocks = 1;
    else
        maxBlocks = p.Block.maxBlocks;
    end
    
    % if blocks are added continously check the last block number
    if(isempty(p.defaultParameters.Block.BlockList))
        lastBlock = 0;
    else
        lastBlock = p.defaultParameters.Block.BlockList(end);
    end

    Ncond = length(p.defaultParameters.Block.Conditions); % how many conditions do we have

    maxTrialsCond = p.defaultParameters.Block.maxBlockTrials;
    
    if(length(maxTrialsCond) == 1)
        maxTrialsCond = repmat(maxTrialsCond, 1, Ncond);
    elseif(length(p.defaultParameters.Block.maxBlockTrials) ~= Ncond)
        error('List of number of trials per condition must match number of conditions!');
    end

    maxTrials_per_Block = sum(maxTrialsCond);  % how many trials are defining a block

    % ordered list of conditions for a single block
    BlockCondSet = [];
    for(i = 1:Ncond)
        BlockCondSet = [BlockCondSet, repmat(i, 1, maxTrialsCond(i))]; %#ok<AGROW>
    end

    % is the total number of trials pre-defiend or do we run until experimenter break?
    maxTrials = maxTrials_per_Block * maxBlocks;   % total number of trials for all blocks

    if(p.defaultParameters.Block.maxBlocks > 0)
        p.defaultParameters.pldaps.finish = maxTrials;
    end

    % pre-allocate
    CNDlst = nan(1, maxTrials);
    BLKlst = nan(1, maxTrials);

    % pre-define order of conditions
    for(i = 1:maxBlocks)
        Blk = ((i-1) * maxTrials_per_Block) + 1;
        CNDlst(Blk:Blk+maxTrials_per_Block-1) = BlockCondSet(randperm(maxTrials_per_Block)); % shuffle order
        BLKlst(Blk:Blk+maxTrials_per_Block-1) = i + lastBlock;
    end

    p.conditions   = [p.conditions, p.defaultParameters.Block.Conditions(CNDlst)];
    p.defaultParameters.Block.BlockList = [p.defaultParameters.Block.BlockList, BLKlst]; 

    p.defaultParameters.Block.GenBlock = 0; % just generated a block, so no need to do it again

else
%% update condition/block list

    % do we need to repeat conditions?
    if(p.defaultParameters.Block.EqualCorrect) % need to check if success, repeat if not    
        % if(p.defaultParameters.pldaps.good) % WZ: verify that this is the correct flag to use
        if(p.trial.outcome.CurrOutcome ~= p.defaultParameters.outcome.Correct)    
            curCND = p.conditions{p.defaultParameters.pldaps.iTrial};
            curBLK = p.defaultParameters.Block.BlockList(p.defaultParameters.pldaps.iTrial);

            poslst = 1:length(p.conditions);
            cpos   = find(poslst > p.defaultParameters.pldaps.iTrial & p.defaultParameters.Block.BlockList == curBLK);

            InsPos = cpos(randi(length(cpos))); % determine random position in the current block for repetition

            p.conditions   = [p.conditions(  1:InsPos-1), curCND,  p.conditions(  InsPos:end)];
            p.defaultParameters.Block.BlockList = [p.defaultParameters.Block.BlockList(1:InsPos-1), curBLK,  p.defaultParameters.Block.BlockList(InsPos:end)];

            if(isfinite(p.defaultParameters.pldaps.finish))
                p.defaultParameters.pldaps.finish = p.defaultParameters.pldaps.finish + 1; % added a required trial
            end
        end
    end
    
    % Do we need to generate a new block?
    if(p.defaultParameters.pldaps.iTrial == length(p.conditions) && ~isfinite(p.defaultParameters.pldaps.finish))
         p.defaultParameters.Block.GenBlock = 1;
         p = ND_GenCndLst(p);
         
    elseif(p.defaultParameters.pldaps.iTrial == p.defaultParameters.pldaps.finish)
        p.defaultParameters.pldaps.quit = 1;
    end
end



