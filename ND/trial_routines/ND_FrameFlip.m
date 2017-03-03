function ND_FrameFlip(p)
% Flip the graphic buffer and show next frame
%
% in part taken from frameFlip in the PLDAPS pldapsDefaultTrialFunction
%
%
% wolf zinke, Jan. 2017

%-------------------------------------------------------------------------%
%% Flip the screen and keep track of frame timings
p.trial.timing.flipTimes(:, p.trial.iFrame) = deal(Screen('Flip', p.trial.display.ptr, 0));

p.trial.stimulus.timeLastFrame     = p.trial.timing.flipTimes(1, p.trial.iFrame) - p.trial.trstart;
% p.trial.framePreLastDrawIdleCount  = 0;
% p.trial.framePostLastDrawIdleCount = 0;

% TODO: WZ - check if there is a check implemented somewhere that keeps track of the difference between expected flip time and current flip time.

% %-------------------------------------------------------------------------%
% %% Create movie (WZ: do we need this for now?)
%
% if(p.trial.display.movie.create)
%  % we should skip every nth frame depending on the ration of frame rates, 
%  % or increase every nth frame duration by 1 every nth frame
%     if(p.trial.display.frate > p.trial.display.movie.frameRate)
%         thisframe = mod(p.trial.iFrame, p.trial.display.frate / p.trial.display.movie.frameRate) > 0;
%     else
%         thisframe = true;
%     end
% 
%     if thisframe
%         frameDuration = 1;
%         Screen('AddFrameToMovie', p.trial.display.ptr, [], [], p.trial.display.movie.ptr, frameDuration);
%     end
% end

%-------------------------------------------------------------------------%
%% Draw background
% WZ: Is this needed to make sure that each screen is initiated with the same background color?
% TODO: WZ - check what this is actually doing and if this is needed here.

% did the background color change?
% we're doing it here to make sure we don't overwrite anything but this typically causes a one frame delay
% until it's applied, i.e. when it's set in frame n, it changes when frame n+1  flips otherwise
% we could trust users not to draw before frameDraw, but we'll check again at frameDraw to be sure

if(any(p.trial.pldaps.lastBgColor ~= p.trial.display.bgColor))
    Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor);
    p.trial.pldaps.lastBgColor = p.trial.display.bgColor;
end

if(p.trial.display.overlayptr ~= p.trial.display.ptr)
    Screen('FillRect', p.trial.display.overlayptr, 0);
end

%-------------------------------------------------------------------------%


