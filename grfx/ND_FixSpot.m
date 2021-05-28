function p = ND_FixSpot(p, bool)
% Turn on/off the fixation spot

if(bool && ~p.trial.stim.fix.on)
    p.trial.stim.fix.on = 1;
    %ND_AddScreenEvent(p, p.trial.event.FIXSPOT_ON, 'FixOn'); (Corey changed on 5/28/21 to prevent duplicate Fixspot On/Off EV codes 

elseif(~bool && p.trial.stim.fix.on)
    p.trial.stim.fix.on = 0;
    %ND_AddScreenEvent(p, p.trial.event.FIXSPOT_OFF, 'FixOff'); (Corey changed on 5/28/21 to prevent duplicate Fixspot On/Off EV codes 

end
