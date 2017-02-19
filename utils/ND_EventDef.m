function p = ND_EventDef(p)
% Defines numeric values for 16 bit codes of trial events
%
%
% wolf zinke, Feb. 2017


p.defaultParameters.event.TRIALSTART = 7;
p.defaultParameters.event.TRIALEND   = 6;

p.defaultParameters.event.REWARD     = 4;
p.defaultParameters.event.MANREWARD  = 4;

p.defaultParameters.event.FIXATION   = 1;
p.defaultParameters.event.BREAKFIX   = 5;

p.defaultParameters.event.STIMULUS   = 2;

p.defaultParameters.event.GoCue      = 2;

p.defaultParameters.event.JOYPRESS   = 2;
p.defaultParameters.event.JOYRELEASE = 2;

p.defaultParameters.event.PDFLASH    = 2;
