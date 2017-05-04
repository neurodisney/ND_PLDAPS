function p = keycheck(p)
% pds.fixation.keycheck. Change fixation related parameters such as
% fixation spot position, etc.
%
% Nate Faber, May 2017
% Adapted from wolf zinke, 2017

if(~isempty(p.trial.LastKeyPress))
    
    fixPos = p.trial.behavior.fixation.fixPos;
    
    switch p.trial.LastKeyPress(1)
        
        
        %% move target to grid positions
        case p.trial.key.GridKeyCell
            
            gpos = find(p.trial.key.GridKey == p.trial.LastKeyPress(1));
            p.trial.behavior.fixation.GridPos = gpos;
            
            fixPos = p.trial.eyeCalib.Grid_XY(gpos, :);
            
            %% move target by steps
        case KbName('RightArrow')
            fixPos(1) = fixPos(1) +  p.trial.behavior.fixation.FixWinStp;
            
        case KbName('LeftArrow')
            fixPos(1) = fixPos(1) - p.trial.behavior.fixation.FixWinStp;
            
        case KbName('UpArrow')
            fixPos(2) = fixPos(2) + p.trial.behavior.fixation.FixWinStp;
            
        case KbName('DownArrow')
            fixPos(2) = fixPos(2) - p.trial.behavior.fixation.FixWinStp;
            
    end
    
    %% Update fixation position if it has changed
    if any(p.trial.behavior.fixation.fixPos ~= fixPos)
        p.trial.behavior.fixation.fixPos = fixPos;
        pds.fixation.move(p);
    end
end
