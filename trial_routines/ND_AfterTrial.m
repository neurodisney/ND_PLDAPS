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
p.trial.TrialTrack.NumTrial = Tnr;

p.trial.TrialTrack.Condition(Tnr, 1) = p.trial.Nr;
p.trial.TrialTrack.Good(    Tnr, 1)  = p.trial.task.Good;

% --------------------------------------------------------------------%
%% keep outcomes
p.trial.TrialTrack.Outcomes(Tnr, 1) = p.trial.outcome.CurrOutcome;
p.trial.TrialTrack.Good(    Tnr, 1) = p.trial.task.Good;

% --------------------------------------------------------------------%
%% Keep basic timings
p.trial.TrialTrack.TrialStart(Tnr, 1) = p.trial.EV.TrialStart;
p.trial.TrialTrack.TaskStart( Tnr, 1) = p.trial.EV.TaskStart;
p.trial.TrialTrack.TaskEnd(   Tnr, 1) = p.trial.EV.TaskEnd;
p.trial.TrialTrack.FixStart(  Tnr, 1) = p.trial.EV.FixStart;
p.trial.TrialTrack.FixBreak(  Tnr, 1) = p.trial.EV.FixBreak;

% --------------------------------------------------------------------%
%% execute user after trial function
if ~isfield(p.trial.task, 'AfterTrial') 
    if(exist(p.trial.task.AfterTrial,'file'))
        feval(p.trial.task.AfterTrial,  p);
    end
end

% --------------------------------------------------------------------%
%% save trial overview
ctrial = p.trial.TrialTrack;

save(fullfile(p.trial.session.trialdir, ...
             [p.trial.session.filestem, '_TrialTrack.pds']), ...
             '-struct', 'ctrial', '-mat', '-v7.3');


 
