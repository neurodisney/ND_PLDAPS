function p = ND_AfterTrial(p)
% run processes after trial that for example needs to modify information
% that is passed on to the next trial (i.e. number of recent correct trials
% since last error).
%
%
% wolf zinke, Jan. 2017

if(p.trial.task.CurrOutcome == p.trial.outcome.Correct)
    p.trial.LastHits = p.defaultParameters.LastHits + 1;
    p.trial.NHits    = p.defaultParameters.NHits + 1;
else
    p.trial.LastHits = 0; % reset
end


