function p = ND_CheckCondRepeat(p)
% Check if a condition needs to be repeated in order to ensure the same
% number of correct trials for each condition.
%
%
% wolf zinke, Dec. 2016

% TODO: debug!!!

if(p.trial.task.EqualCorrect && ~p.trial.pldaps.goodtrial) % need to check if success, repeat if not    
    curCND = p.conditions{p.trial.pldaps.iTrial};
    curBLK = p.trial.Block.BlockList(p.trial.pldaps.iTrial);

    poslst = 1:length(p.conditions);
    cpos   = find(poslst > p.trial.pldaps.iTrial & p.trial.Block.BlockList == curBLK);

    InsPos = cpos(randi(length(cpos))); % determine random position in the current block for repetition

    p.conditions   = [p.conditions(  1:InsPos-1), curCND,  p.conditions(  InsPos:end)];
    p.trial.blocks = [p.trial.Block.BlockList(1:InsPos-1), curBLK,  p.trial.Block.BlockList(InsPos:end)];

    p.trial.pldaps.finish = p.trial.pldaps.finish + 1; % added a required trial
end
