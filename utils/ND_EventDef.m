function p = ND_EventDef(p)
% Defines numeric values for 16 bit codes of trial events
%
%
% wolf zinke, Feb. 2017


disp('****************************************************************')
disp('>>>>  ND:  Defining Event Codes <<<<')
disp('****************************************************************')
disp('');

p.defaultParameters.event.TRIALSTART = 7;
p.defaultParameters.event.TRIALEND   = 6;

p.defaultParameters.event.REWARD     = 4;
p.defaultParameters.event.MANREWARD  = 4;

p.defaultParameters.event.FIXATION   = 1;
p.defaultParameters.event.FIXBREAK   = 5;

p.defaultParameters.event.STIMULUS   = 2;

p.defaultParameters.event.GOCUE      = 2;

p.defaultParameters.event.JOYPRESS   = 2;
p.defaultParameters.event.JOYRELEASE = 2;

p.defaultParameters.event.PDFLASH    = 2;

p.defaultParameters.event.DIO_TTL1   = 2;
p.defaultParameters.event.DIO_TTL2   = 2;
p.defaultParameters.event.DIO_TTL3   = 2;
p.defaultParameters.event.DIO_TTL4   = 2;
p.defaultParameters.event.DIO_TTL5   = 2;
p.defaultParameters.event.DIO_TTL6   = 2;
p.defaultParameters.event.DIO_TTL7   = 2;
p.defaultParameters.event.DIO_TTL8   = 2;

