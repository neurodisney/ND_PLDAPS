function DatapixxAdcAcquireDemo()
% DatapixxAdcAcquireDemo()
%
% Shows how to acquire ADC data synchronized with a video stimulus.
% For demonstration purposes we use the DAC0/1 outputs to simulate an evoked
% potential, which we then acquire on ADC0/1 using internal loopback between
% DACs and ADCs.
% We'll then plot the simulated evoked potential.
%
% Also see: DatapixxAdcBasicDemo, DatapixxAdcStreamDemo
%
% History:
%
% Oct 1, 2009  paa     Written
% Oct 29, 2014 dml     Revised 

AssertOpenGL;   % We use PTB-3

Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('RegWrRd');    % Synchronize Datapixx registers to local register cache

% Fill up a DAC buffer with 2 channels of 1000 samples of simulated visual evoked potential data.
% I guess our 2 simulated neurons will just output sin/cos functions.
% We'll generate a single period of the waveforms, and play them repeatedly.
nDacSamples = 1000;
dacData = [sin([0:nDacSamples-1]/nDacSamples*2*pi) ; cos([0:nDacSamples-1]/nDacSamples*2*pi)];
Datapixx('WriteDacBuffer', dacData);

% Play the downloaded DAC waveform buffers continuously at 100 kSPS,
% resulting in 100 Hz sin/cos waves being output onto DAC0/1.
Datapixx('SetDacSchedule', 0, 1e5, 0, [0 1], 0, nDacSamples);
Datapixx('StartDacSchedule');
Datapixx('RegWrRd');

% Configure ADC to acquire 2 channels (ADC0 and ADC1) at 10 kSPS.
% How much data should we acquire? We'll say 1000 samples, which is 100 milliseconds.
% This will give 10 cycles of our 100 Hz sin/cos simulated evoked potentials.
nAdcSamples = 1000;
Datapixx('SetAdcSchedule', 0, 1e4, nAdcSamples, [0 1]);
Datapixx('EnableDacAdcLoopback');   % Replace this with DisableDacAdcLoopback to collect real data
Datapixx('DisableAdcFreeRunning');  % For microsecond-precise sample windows
Datapixx('RegWrRd');

% Our simulated neuron will be responding to a white flash,
% and we shall start acquisition precisely on the vertical sync preceeding the flash.
try
    oldVerbosity = Screen('Preference', 'Verbosity', 1);   % Don't log the GL stuff
    screenNumber = max(Screen('Screens'));
    window = Screen('OpenWindow', screenNumber, 0, []);
    Screen('Preference', 'Verbosity', oldVerbosity);
    HideCursor;

    % Clear display to black, and wait about a second
    Screen('FillRect',window, [0 0 0]);     % Clear the display to black
    for frame = 0:60
        Screen('Flip', window);
    end

    % Start the analog acquisition on next vertical sync pulse,
    % and show a white flash for one frame.
    Datapixx('StartAdcSchedule');
    Datapixx('RegWrVideoSync');                 % ADC will start at onset of next video VSYNC pulse
    Screen('FillRect',window, [255 255 255]);   % Fill the display with white
    Screen('Flip', window);
    Screen('FillRect',window, [0 0 0]);         % Return the display to black
    Screen('Flip', window);

    % Wait for the ADC to finish acquiring its scheduled dataset
    while 1
        Datapixx('RegWrRd');   % Update registers for GetAdcStatus
        status = Datapixx('GetAdcStatus');
        if (~status.scheduleRunning)
            break;
        end
    end

    % Show final status of ADC scheduler
    fprintf('\nStatus information for ADC scheduler:\n');
    disp(status);

    % Upload our acquired data,
    % and plot our evoked potential (10 periods of sin/cos) as a function of time.
    [adcData, adcTimetags] = Datapixx('ReadAdcBuffer', nAdcSamples);
    plot(adcTimetags, adcData');

    % Job done
    ShowCursor;
    Screen('CloseAll');
    Datapixx('StopAllSchedules');   % Stop the DAC waveform
    Datapixx('RegWrRd');
    Datapixx('Close');
catch
    ShowCursor;
    Screen('CloseAll');
    Datapixx('StopAllSchedules');   % Stop the DAC waveform
    Datapixx('RegWrRd');
    Datapixx('Close');
    psychrethrow(psychlasterror);
end;

 fprintf('\n\nDemo completed\n\n');
