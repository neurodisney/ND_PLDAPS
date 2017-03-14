function p = ND_TrialSetup(p)
% prepare data collection and initialise everything needed
% in part taken from trialSetup in the PLDAPS pldapsDefaultTrialFunction
%
%
% wolf zinke, Dec. 2016

p.trial.timing.flipTimes           = zeros(4,p.trial.pldaps.maxFrames);
p.trial.timing.frameStateChangeTimes = nan(9,p.trial.pldaps.maxFrames);


% --------------------------------------------------------------------%
%% get task parameters
if(isfield(p.trial.task, 'TaskDef'))
    if(~isempty(p.trial.task.TaskDef))
        clear(p.trial.task.TaskDef); % make sure content gets updated
        p = feval(p.trial.task.TaskDef,  p);
    end
end

% ------------------------------------------------------------------------%
%% Photo Diode
if(p.trial.pldaps.draw.photodiode.use)
    p.trial.timing.photodiodeTimes         = nan(2,p.trial.pldaps.maxFrames);
    p.trial.pldaps.draw.photodiode.dataEnd = 1;
end

% ------------------------------------------------------------------------%
%% DataPixx
pds.datapixx.adc.trialSetup(p); % setup analog data collection from Datapixx

% call PsychDataPixx('GetPreciseTime') to make sure the clocks stay synced
if(p.trial.datapixx.use)
    [getsecs, boxsecs, confidence]          = PsychDataPixx('GetPreciseTime');
    p.trial.timing.datapixxPreciseTime(1:3) = [getsecs, boxsecs, confidence];
    p.trial.timing.datapixxTrialStart       = getsecs;
end

% ------------------------------------------------------------------------%
%% Reward    
%%% prepare reward system and pre-allocate variables for reward timings
p.trial.reward.iReward     = 0; % counter for reward times
% p.trial.reward.timeReward  = nan(2,p.trial.pldaps.maxTrialLength*2); %preallocate for a reward up to every 0.5 s

% ------------------------------------------------------------------------%
%% eye position

if(p.trial.pldaps.draw.eyepos.use)
    p.trial.eyeXY_draw = nan(1, 2);
    
    p.trial.eyeX_hist = nan(1, p.trial.pldaps.draw.eyepos.history);
    p.trial.eyeY_hist = nan(1, p.trial.pldaps.draw.eyepos.history);
end

% ------------------------------------------------------------------------%
%% Keyboard
% setup a fields for the keyboard data
p.trial.keyboard.samples             = 0;
p.trial.keyboard.pressedSamples      = false(1, round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.samplesTimes        = zeros(1, round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.samplesFrames       = zeros(1, round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.firstPressSamples   = zeros(p.trial.keyboard.nCodes, round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.firstReleaseSamples = zeros(p.trial.keyboard.nCodes, round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.lastPressSamples    = zeros(p.trial.keyboard.nCodes, round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.lastReleaseSamples  = zeros(p.trial.keyboard.nCodes, round(p.trial.pldaps.maxFrames*1.1));

% ------------------------------------------------------------------------%
%% Mouse
% setup a fields for the mouse data
if(p.trial.mouse.use)
    [~,~,isMouseButtonDown]          = GetMouse(); 
    p.trial.mouse.cursorSamples      = zeros(2, round(round(p.trial.pldaps.maxFrames*1.1)));
    p.trial.mouse.buttonPressSamples = zeros(length(isMouseButtonDown), round(round(p.trial.pldaps.maxFrames*1.1)));
    p.trial.mouse.samplesTimes       = zeros(1, round(round(p.trial.pldaps.maxFrames*1.1)));
    p.trial.mouse.samples            = 0;
end

% ------------------------------------------------------------------------%
%% Spike Server
% TODO: integrate Tucker Davis system 

% ------------------------------------------------------------------------%
%% Update summary information for preceding trials
p.trial.SmryStr = sprintf('Condition: %d  Block: %d -- %d/%d correct trials (%.2f)', ...
                   p.trial.Nr, p.trial.blocks(p.trial.pldaps.iTrial), p.trial.NHits, ...
                   p.trial.pldaps.iTrial, p.trial.cPerf);

ND_CtrlMsg(p, p.trial.SmryStr);

% ------------------------------------------------------------------------%
%% frame rate history
%%% prepare to plot frame rate history on screen
% TODO: what exactly is this doing? Is it needed? 
if(p.trial.pldaps.draw.framerate.use)           
    p.trial.pldaps.draw.framerate.nFrames = round(p.trial.pldaps.draw.framerate.nSeconds / p.trial.display.ifi);
    p.trial.pldaps.draw.framerate.data    = zeros(p.trial.pldaps.draw.framerate.nFrames, 1); %holds the data
    sf.startPos  = round(p.trial.display.w2px' .* p.trial.pldaps.draw.framerate.location + [p.trial.display.pWidth/2, p.trial.display.pHeight/2]);
    sf.size      =       p.trial.display.w2px' .* p.trial.pldaps.draw.framerate.size;    
    sf.window    =       p.trial.display.overlayptr;
    sf.xlims     =   [1, p.trial.pldaps.draw.framerate.nFrames];
    sf.ylims     = [0, 2*p.trial.display.ifi];
    sf.linetype='-';
    p.trial.pldaps.draw.framerate.sf = sf;
end

% ------------------------------------------------------------------------%
%% Initialize default trial control variables
p.trial.CurrEpoch             = NaN;  % keep track of task epochs
p.trial.task.Timing.WaitTimer = NaN;  % Initialize variable that contains a timer  # TODO: WZ: make it p.trial.WaitTimer, p.trial.Timer.WaitTimer?
p.trial.CurTime               = NaN;  % keep track of current time


