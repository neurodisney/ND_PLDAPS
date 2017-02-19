function ND_TTLout(chan)
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

chan = chan + 16; % First 16 bits are used for the strobe, thus shift the output channel accordingly
chanmask = (2^chan)-2^(chan-1); % set the mask for only the selected channel in order to not affect the other digital output

Datapixx('SetDoutValues', 1, chanmask);
Datapixx('RegWr');
Datapixx('SetDoutValues', 0, chanmask);
Datapixx('RegWr');


%  Datapixx('SetDoutSchedule', scheduleOnset, scheduleRate, maxScheduleFrames [, bufferBaseAddress=8e6] [, numBufferFrames=maxScheduleFrames]);
%% TODO: is it feasible to define a duration without affecting other channels?




