function p = move(p)
% pds.fixation.move(p)  move fixation spot to new location

%% displace fixation window and fixation target
p.trial.behavior.fixation.FixWinRect = ND_GetRect(p.trial.behavior.fixation.FixPos, ...
                                                  p.trial.behavior.fixation.FixWin);  
                                                  
% get dva values into psychtoolbox pixel values/coordinates
p.trial.task.TargetPos  = p.trial.behavior.fixation.FixPos;
p.trial.task.TargetRect = ND_GetRect(p.trial.task.TargetPos, p.trial.task.TargetSz);

