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


Tnr = p.defaultParameters.pldaps.iTrial;
p.defaultParameters.TrialTrack.NumTrial = Tnr;

p.defaultParameters.TrialTrack.Condition(Tnr, 1) = p.trial.Nr;
p.defaultParameters.TrialTrack.Good(    Tnr, 1)  = p.trial.task.Good;

% --------------------------------------------------------------------%
%% keep outcomes
p.defaultParameters.TrialTrack.Outcomes(Tnr, 1) = p.trial.outcome.CurrOutcome;
p.defaultParameters.TrialTrack.Good(    Tnr, 1) = p.trial.task.Good;

% --------------------------------------------------------------------%
%% Keep basic timings
p.defaultParameters.TrialTrack.TrialStart(Tnr, 1) = p.trial.EV.TrialStart;
p.defaultParameters.TrialTrack.TaskStart( Tnr, 1) = p.trial.EV.TaskStart;
p.defaultParameters.TrialTrack.TaskEnd(   Tnr, 1) = p.trial.EV.TaskEnd;
p.defaultParameters.TrialTrack.FixStart(  Tnr, 1) = p.trial.EV.FixStart;
p.defaultParameters.TrialTrack.FixBreak(  Tnr, 1) = p.trial.EV.FixBreak;

% --------------------------------------------------------------------%
%% execute user after trial function
if ~isfield(p.trial.task, 'AfterTrial') 
    if(exist(p.trial.task.AfterTrial,'file'))
        feval(p.trial.task.AfterTrial,  p);
    end
end

% --------------------------------------------------------------------%
%% save trial overview
ctrial = p.defaultParameters.TrialTrack;

save(fullfile(p.trial.session.trialdir, ...
             [p.trial.session.filestem, '_TrialTrack.pds']), ...
             '-struct', 'ctrial', '-mat', '-v7.3');


 
