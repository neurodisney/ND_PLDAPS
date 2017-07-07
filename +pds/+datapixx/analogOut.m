function analogOut(open_time, chan, TTLamp) 
% pds.datapixx.analogOut    Send a TTL pulse through the Analog Out
% Send a [TTLamp] volt signal out the channel [chan], for [open_time] seconds
% 
% Datapixx must be open for this function to work. 
%
% INPUTS:
%	      open_time - seconds to send signal (default = .5)
%              chan - channel on datapixx to send signal 
%                     (you have to map your breakout board [3 on huk rigs])
%            TTLamp - voltage (1 - 5 volts can be output) defaults to 3
% 
%
% written by Kyler Eastman 2011
% modified by JLY 2012 - replaced if~exist with nargin calls for speedup
% modified by JK  2014 - slight adjustments for use with version 4.1
% modified by wolf zinke, Feb. 2017 - put reward defaults into pds.reward.give
%                                   - encode events when analog channel is used

DOUTchannel = chan; % channel -- you have to map your breakout board

sampleRate = 1000; % Hz MAGIC NUMBER??  WZ: This has to be equal to p.trial.datapixx.adc.dataSampleTimes.srate

if(length(open_time) == 1) % only one value with a duratiion is specified
    if(nargin < 3)
        TTLamp = p.trial.datapixx.adc.TTLamp;
    end
    
    bufferData = [TTLamp*ones(1,round(open_time*sampleRate)), 0] ;
    
else % input argument contains buffer data to send to analog out
    bufferData = open_time;
end

maxFrames  = length(bufferData);

Datapixx('WriteDacBuffer', bufferData ,0 ,DOUTchannel);

Datapixx('SetDacSchedule', 0, sampleRate, maxFrames ,DOUTchannel);
Datapixx StartDacSchedule;
Datapixx RegWrRd;

% pds.datapixx.flipBit(p.trial.event.(['AO_',int2str(chan)]));



