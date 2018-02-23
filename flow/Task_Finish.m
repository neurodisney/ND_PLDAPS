function p = Task_Finish(p)

%p = ND_CheckCondRepeat(p); % ensure all conditions were performed correctly equal often

p.trial.EV.TrialEnd = p.trial.CurTime;

% just as fail safe, make sure to finish when done
%  if(p.trial.pldaps.iTrial == length(p.conditions))
%      p.trial.pldaps.finish = p.trial.pldaps.iTrial;
%  end
