function timings = ND_TTLout(chan, duration)
% sends a TTL pulse over one of the last 8 bits of the digital output
% of the DataPixx DB25 connector.
%
%    chan   pin
%      1  -   9
%      2  -  22
%      3  -  10
%      4  -  23
%      5  -  11
%      6  -  24
%      7  -  12
%      8  -  25
%
%
% wolf zinke & Kia Banaie, Feb 2017

chanmask = hex2dec('000FFFF'); % mask first 16 bits, do not address the the remaining 8 bits

% mask only the single channel

if(nargin ==1)
    Datapixx('SetDoutValues', 1, chanmask);
    Datapixx('RegWr');
    Datapixx('SetDoutValues', 0, chanmask);
    Datapixx('RegWr');
else
    %  Datapixx('SetDoutSchedule', scheduleOnset, scheduleRate, maxScheduleFrames [, bufferBaseAddress=8e6] [, numBufferFrames=maxScheduleFrames]);

end




