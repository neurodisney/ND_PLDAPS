function DatapixxDoutButtonScheduleDemo()
% DatapixxDoutButtonScheduleDemo()
%
% Demonstrates the use of automatic digital output schedules when user presses digital input buttons.
%
% History:
%
% Apr 30, 2012  paa     Written
% Oct 29, 2014  dml     Revised

AssertOpenGL;   % We use PTB-3

% Open Datapixx, and stop any schedules which might already be running
Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache

% Upload some arbitrary digital output waveforms for the first 5 button
% inputs.  Note that the digital output waveforms must be stored at 4kB
% increments from the DOUT buffer base address.
% Also note that the last value in the digital output waveform will be
% almost immediately replaced with the original contents of the digital
% output port when the schedule terminates.

doutBufferBaseAddr = 0;

doutWaveform = [ 2, 2, 0, 3, 0, 3, 0, 3];
Datapixx('WriteDoutBuffer', doutWaveform, doutBufferBaseAddr); % RESPONSEPixx RED/Din0

doutWaveform = [ 0, 0, 0, 0, 0, 0, 1, 1];
Datapixx('WriteDoutBuffer', doutWaveform, doutBufferBaseAddr + 4096*1); % RESPONSEPixx Yellow/Din1

doutWaveform = [ 0, 0, 0, 0, 0, 1, 1, 1];
Datapixx('WriteDoutBuffer', doutWaveform, doutBufferBaseAddr + 4096*2); % RESPONSEPixx Green/Din2

doutWaveform = [ 0, 0, 0, 0, 1, 1, 1, 1];
Datapixx('WriteDoutBuffer', doutWaveform, doutBufferBaseAddr + 4096*3); % RESPONSEPixx Blue/Din3

doutWaveform = [ 0, 0, 0, 1, 1, 1, 1, 1];
Datapixx('WriteDoutBuffer', doutWaveform, doutBufferBaseAddr + 4096*4); % RESPONSEPixx White/Din4

Datapixx('SetDoutSchedule', 0, 1000, 9, doutBufferBaseAddr); 
% NOTE THE 9 instead of 8, this fixes the problem mentioned above.
Datapixx('SetDinDataDirection', 0);
Datapixx('EnableDinDebounce');      % Filter out button bounce
Datapixx('EnableDoutButtonSchedules'); % This starts the schedules
Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache
Datapixx('Close');
fprintf('\n\nAutomatic buttons schedules running\n\n');


