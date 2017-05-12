function p = move(p)
% pds.fixation.move(p)  move fixation spot to new location

%% define fixation window
p.trial.behavior.fixation.FixWinRect = ND_GetRect(p.trial.behavior.fixation.fixPos, ...
                                                  p.trial.behavior.fixation.FixWin);  
% %% define fixation target
% p.trial.behavior.fixation.FixRect    = ND_GetRect(p.trial.behavior.fixation.fixPos, ...
%                                                   p.trial.behavior.fixation.FixSz);

