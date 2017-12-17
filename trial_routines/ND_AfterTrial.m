function p = ND_AfterTrial(p)
% extract summary information for all trials.
% 
% Keep relevant information across trial for visualization purposes as well
% as for outcome based selection of future trials.
%
% ToDo: - move condition and block update here
%       - provide interface for Palamedes toolbox
%
% wolf zinke, May 2017

Tnr = p.trial.pldaps.iTrial;
p.data.NumTrial = Tnr;

p.data.Condition(Tnr, 1) = p.trial.Nr;
p.data.Good(     Tnr, 1) = p.trial.task.Good;

% --------------------------------------------------------------------%
%% keep outcomes
p.data.Outcomes(Tnr, 1) = p.trial.outcome.CurrOutcome;
p.data.Good(    Tnr, 1) = p.trial.task.Good;

% --------------------------------------------------------------------%
%% Keep basic timings
p.data.TrialStart(Tnr, 1) = p.trial.EV.TrialStart;
p.data.TaskStart( Tnr, 1) = p.trial.EV.TaskStart;
p.data.TaskEnd(   Tnr, 1) = p.trial.EV.TaskEnd;

if(p.defaultParameters.behavior.fixation.use)
    p.data.FixStart(  Tnr, 1) = p.trial.EV.FixStart;
    p.data.FixBreak(  Tnr, 1) = p.trial.EV.FixBreak;
end

% --------------------------------------------------------------------%
%% execute user after trial function
if(isfield(p.trial.task, 'AfterTrial') )
    if(exist(p.trial.task.AfterTrial,'file'))
        feval(p.trial.task.AfterTrial,  p);
    end
end

% --------------------------------------------------------------------%
%% save trial overview
cdata = p.data;

save(fullfile(p.trial.session.trialdir, ...
             [p.trial.session.filestem, '_TrialData.pds']), ...
             '-struct', 'cdata', '-mat', '-v7.3');


 
