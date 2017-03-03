function p = finish(p)
%pds.behavior.reward.finish(p)    finishes up after end of experiment.
% This is mostly a wrapper to the other reward modules.
    if(p.trial.newEraSyringePump.use)
        pds.newEraSyringePump.finish(p);
    end
    