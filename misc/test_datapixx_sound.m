buffer = 16e6;

[rewardSound, fs] = audioread('./beepsounds/reward.wav');
nSamples = size(rewardSound, 1);
Datapixx('Open');
Datapixx('SetAudioVolume', 1);
[nextBuf,underflow,overflow] = Datapixx('WriteAudioBuffer', rewardSound', buffer);

% Setup to play the sound
Datapixx('SetAudioSchedule', 0, fs, nSamples, 0, buffer, []);

strIn = input('Press q to quit, Enter to play sound file:','s');
while isempty(strIn)
    % Start playback
    Datapixx('StartAudioSchedule');
    Datapixx('RegWrRd');
    strIn = input('Press q to quit, Enter to play sound file:','s');
end

Datapixx('Close');