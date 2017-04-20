function timings = strobe2(EV, dur)
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
% nate faber, Apr 2017 (Use schedules)

if(nargin < 2)
    dur = 0.001; % a minimal time delay might be required to be detected by the TDT system
end

% Create the pulse waveform (2 values ON and then OFF again)
waveform = [EV, 0, 0];
Datapixx('WriteDoutBuffer', waveform);

% Now, schedule it. The 3 in [dur 3] means that it plays at dur seconds per
% sample
Datapixx('SetDoutSchedule', 0, [dur 3], size(waveform,2));

% Get the precise timing when the signal is sent
Datapixx('SetMarker');

% Signal to start the schedule on the next RegWrRd
Datapixx('StartDoutSchedule');

% If timings are requested, get them. Otherwise just send the signal
if nargout ~= 0   
    t = nan(2,1);
    t(1) = GetSecs;
     
    % GO
    Datapixx('RegWrRd');
    
    t(2) = GetSecs;
    
    % Get the time when the signal occured
    dpTime = Datapixx('GetMarker');
    
    timings = [mean(t) dpTime diff(t)];
    
else
    % GO
    Datapixx('RegWrRd');
end
    
% WaitSecs(dur); 

% Wait for waveform to finish playing before returning control
Datapixx('RegWrRd');
status = Datapixx('GetDoutStatus');
while status.scheduleRunning
    WaitSecs(0.0001);
    Datapixx('RegWrRd');
    status = Datapixx('GetDoutStatus');
end
