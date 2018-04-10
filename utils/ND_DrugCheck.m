function p = ND_DrugCheck(p)
%% check if it is time to trigger a drug stimulation
%
% This module controls the timing to start a drug injection (or any other kind of stimulation 
% triggered by a TTL pulse).
%
% wolf zinke, April 2018

if(p.trial.Drug.TrialBased)
% Drug delivery is relative to trials


else
% drug delivery is pure time based and ignores the trial structure
    if(p.trial.task.LastDrugFlash > p.trial.Drug.FlashSeriesLength)
        if(p.trial.task.DrugGiven == 0)
            if(p.trial.CurTime > p.trial.task.NextModulation + p.trial.Drug.PeriFlashTime)
                ND_PulseSeries(p.trial.datapixx.TTL_spritzerChan,      ...
                               p.trial.datapixx.TTL_spritzerDur,       ...
                               p.trial.datapixx.TTL_spritzerNpulse,    ...
                               p.trial.datapixx.TTL_spritzerPulseGap,  ...
                               p.trial.datapixx.TTL_spritzerNseries,   ...
                               p.trial.datapixx.TTL_spritzerSeriesGap, ...
                               p.trial.event.INJECT);

                p.trial.task.LastDrugFlash = 0;
                p.trial.task.DrugCount     = p.trial.task.DrugCount + 1;
                p.trial.task.DrugGiven     = 1;
            end
        end
    else
        p.trial.task.DrugGiven = 0;
    end
    
end
