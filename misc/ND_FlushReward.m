function ND_FlushReward(opentime, voltage, chan)
% Simple script that helps to flush/clean reward system.
%
%
% TODO: [in case I have time and do not know what else to do) show a
%       bargraph indicating the remaining time
%
%
%
% wolf zinke, Feb 2017

 % opening time (for full flush, cleaning a value of 120 ore more would be better)
if (~exist('opentime','var') || isempty(opentime))
    opentime = 10; 
end

% DAC output voltage
if (~exist('voltage','var') || isempty(voltage))
    voltage = 4.5; 
end

% default reward DAC channel
if (~exist('chan','var') || isempty(chan))
    chan = 3; 
end

% If Control-C is pressed stop flushing the reward
cleanupObj = onCleanup(@cleanUp);

sampleRate = 1000; % Hz 

bufferData = [voltage * ones(1, round(opentime * sampleRate)) 0] ;
maxFrames = length(bufferData);

% init Datapixx:
Datapixx('Open');
Datapixx('RegWrRd');

% generate the reward opening pulse
Datapixx('WriteDacBuffer', bufferData ,0 ,chan);

Datapixx('SetDacSchedule', 0, sampleRate, maxFrames ,chan);
Datapixx StartDacSchedule;
Datapixx RegWrRd;

disp(['Waiting for reward flushing for ', num2str(opentime, '%.3f'), ' seconds ...']);

pause(opentime);
  


function cleanUp
    display('Stopping reward flush')
    buffer = [0];
    Datapixx('WriteDacBuffer', buffer, 0, chan);
    Datapixx('SetDacSchedule', 0, sampleRate, 1, chan);
    Datapixx('StartDacSchedule');
    Datapixx('RegWrRd');

    Datapixx('Close');
    

