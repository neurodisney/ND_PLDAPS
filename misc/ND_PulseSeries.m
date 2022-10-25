function ND_PulseSeries(chan, PulseDur, Npulse, GapDur, Nseries, SeriesPause, InjStrobe)

% ToDO: detect if pldaps class is passed and derive parameters from there

%% define defaults
if(~exist('chan','var') || isempty(chan))
    chan  = 6; % DIO channel
end

if(~exist('PulseDur','var') || isempty(PulseDur))
    PulseDur = 0.1;  % duration of TTL pulse
end

if(~exist('Npulse','var') || isempty(Npulse))
    Npulse  = 10; % number of pulses in a series
end

if(~exist('Nseries','var') || isempty(Nseries))
    Nseries = 3;  % number of pulse packages
end

if(~exist('GapDur','var') || isempty(GapDur))
    GapDur   = 1.5;  % gap between subsequent pulses
end

if(~exist('SeriesPause','var') || isempty(SeriesPause))
    SeriesPause = 120; % gap between subsequent sieries
end

if(~exist('InjStrobe','var') || isempty(InjStrobe))
    InjStrobe = 667; % gap between subsequent series
end

% check if DataPixx needs to be opened
if(~ Datapixx('IsReady'))
    Datapixx('Open');
    Datapixx('RegWrRd');
    
    closeDPX = 1;
else
    closeDPX = 0;
end

% run pulses
for(j=1:Nseries)
    pds.datapixx.strobe(InjStrobe);
    
    for(i=1:Npulse)
        pds.datapixx.TTL(chan, 1, PulseDur);
        
        if(i < Npulse)
            WaitSecs(GapDur);
        end
    end
    
    if(j < Nseries)
        WaitSecs(SeriesPause);
    end
end

%% finish up

if(closeDPX)
    Datapixx('Close');
end
