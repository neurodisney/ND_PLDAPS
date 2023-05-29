function p = ND_FixSpot(p, bool)
% Turn on/off the fixation spot

if(bool && ~p.trial.stim.fix.on)
    p.trial.stim.fix.on = 1;
    ND_AddScreenEvent(p, p.trial.event.FIXSPOT_PRES, 'FixPres');

elseif(~bool && p.trial.stim.fix.on)
    p.trial.stim.fix.on = 0;
    ND_AddScreenEvent(p, p.trial.event.FIXSPOT_REMV, 'FixRemv');
end
