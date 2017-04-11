function timings = strobe(EV, dur)
% pds.tdt.strobe   strobes 16 bit integer event marker to the Tucker Davis system.
%
% This function is a modification of the pds.datapixx.strobe function included in PLDAPS
% (moved to pds.plexon.strobe) to make it work with the Tucker Davis system.
%
% To work properly, the digital output from DataPixx needs to be wired
% correctly to the digital input of the RZ5.
%
% This function uses the first 16 bits of the DataPixx digital output
% and feeds them into port A and B of the TDT system.
% Both ports will be paired and read out as 16 bit code.
%
%  Wiring scheme:
%
%     First Byte     |   Second Byte
%  ==================|==================
%  DataPixx    TDT   |  DataPixx    TDT
%      1    ->  18   |      5    ->  22
%     14    ->   6   |     18    ->  10
%      2    ->  19   |      6    ->  23
%     15    ->   7   |     19    ->  11
%      3    ->  20   |      7    ->  24
%     16    ->   8   |     20    ->  12
%      4    ->  21   |      8    ->  25
%     17    ->   9   |     21    ->  13
%
%          GND
%     13    ->   5
%
%
% wolf zinke & Kia Banaie, Feb 2017

if(nargin < 2)
    dur = 0.001; % a minimal time delay might be required to be detected by the TDT system
end

TwoByte = hex2dec('000FFFF'); % mask first 16 bits, do not address the the remaining 8 bits

if(nargout == 0)
    % just send event one-way for efficiency 
    Datapixx('SetDoutValues', EV, TwoByte);
    Datapixx('RegWr');
else
    % get time stamp back, might impair performance
    t = nan(2,1);

    oldPriority = Priority;

    if(oldPriority < MaxPriority('GetSecs'))
        Priority(MaxPriority('GetSecs'));
    end

    Datapixx('SetDoutValues', EV, TwoByte);
    Datapixx('SetMarker');

    t(1)=GetSecs;
    Datapixx('RegWrRd');
    t(2)=GetSecs;

    dpTime = Datapixx('GetMarker');

    if(Priority ~= oldPriority)
        Priority(oldPriority);
    end

    timings = [mean(t), dpTime, diff(t)];
end

% a minimal time delay might be required to be detected by the TDT system:
% check the sampling rate of the RZ unit.
WaitSecs(dur); 

% need to reset, otherwise if the same event follows it will not be captured
Datapixx('SetDoutValues', 0, TwoByte);
Datapixx('RegWr');

WaitSecs(dur); 

