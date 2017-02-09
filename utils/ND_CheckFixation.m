% !!! right now just a placeholder !!!
function p = ND_CheckFixation(p)
% Read in the eye position signal and check how much it deviates from a
% defined position.
%
% This currently is a direct take from ND_CheckJoystick and needs to be
% adapted. p.trial.behavior.fixation.FixWin is used wrong right now,
% because it is diameter in dva but needs to be radius and map to the
% voltage.
%
%
% wolf zinke, Jan. 2017

if(p.trial.mouse.useAsEyepos)
    % TODO: Define sample based on a time period.
    sIdx = (p.trial.mouse.samples - p.trial.behavior.fixation.Sample + 1) : p.trial.mouse.samples;  % determine the position of the sample. If this causes problems with negative values in the first trial, make sure to use only positive indices.

    % calculate amplitude for each time point in the current sample
    p.trial.mouse.Amp(sIdx) = sqrt((p.trial.mouse.X(sIdx) - p.trial.behavior.fixation.FixPos(1)).^2 + ...
                                   (p.trial.mouse.Y(sIdx) - p.trial.behavior.fixation.FixPos(2)).^2);

    % calculate a moving average of the joystick position for display reasons
    p.trial.eyeX   = mean(p.trial.mouse.X(  sIdx));
    p.trial.eyeY   = mean(p.trial.mouse.Y(  sIdx));
    p.trial.eyeAmp = mean(p.trial.mouse.Amp(sIdx));
else
    % TODO: Define sample based on a time period.
    sIdx = (p.trial.datapixx.adc.dataSampleCount - p.trial.behavior.fixation.Sample + 1) : p.trial.datapixx.adc.dataSampleCount;  % determine the position of the sample. If this causes problems with negative values in the first trial, make sure to use only positive indices.

    % calculate amplitude for each time point in the current sample
    p.trial.AI.Eye.Amp(sIdx) = sqrt((p.trial.AI.Eye.X(sIdx) - p.trial.behavior.fixation.FixPos(1)).^2 + ...
                                    (p.trial.AI.Eye.Y(sIdx) - p.trial.behavior.fixation.FixPos(2)).^2);

    % calculate a moving average of the joystick position for display reasons
    p.trial.eyeX   = mean(p.trial.AI.Eye.X(sIdx));
    p.trial.eyeY   = mean(p.trial.AI.Eye.Y(sIdx));
    p.trial.eyeAmp = mean(p.trial.AI.Eye.Amp(sIdx));
end

% if relevant for task determine joystick state
if(p.trial.behavior.fixation.use)
    % ND_CtrlMsg(p, ['Joystick State: ',int2str(p.trial.FixState.Current),'; curr Amp: ',num2str(p.trial.joyAmp,'%.4f')]);

    switch p.trial.FixState.Current
        %% wait for release
        case p.trial.FixState.GazeOut
            fixchk = p.trial.AI.Joy.Amp(sIdx) > p.trial.behavior.fixation.FixWin; % invert selection to just use 'any'

            % all below threshold?
            if(~any(fixchk))
                p.trial.FixState.Current = p.trial.FixState.GazeIn;
            end

        %% wait for press
        case p.trial.FixState.GazeIn
            fixchk = p.trial.AI.Joy.Amp(sIdx) < p.trial.behavior.fixation.FixWin; % invert selection to just use 'any'

            % all above threshold?
            if(~any(fixchk))
                p.trial.FixState.Current = p.trial.FixState.GazeOut;
            end

        %% if it is nan, so just get the current state
        otherwise
            if(isnan(p.trial.FixState.Current))
                if(p.trial.AI.Joy.Amp(p.trial.datapixx.adc.dataSampleCount) >= p.trial.behavior.fixation.FixWin)
                    p.trial.FixState.Current = p.trial.FixState.GazeOut;

                elseif(p.trial.AI.Joy.Amp(p.trial.datapixx.adc.dataSampleCount) <= p.trial.behavior.fixation.FixWin)
                    p.trial.FixState.Current = p.trial.FixState.GazeIn;

                else
                    p.trial.FixState.Current = NaN;
                end
            else
                error('Unknown joystick state!');
            end
    end  % switch p.FixState.Current
end  % if(p.trial.behavior.fixation.use)






% function checkFixation(p, sn)
% currentEye=[p.trial.eyeX p.trial.eyeY]; %p.trial.(sn).eyeXYs(1:2,p.trial.iFrame);
% %     fprintf('checking: state ')
% % check if fixation should be shown
% switch p.trial.(sn).state
%     case p.trial.(sn).states.START
%         %             fprintf('START\n')
%
%         % time to turn on fixation
%         if p.trial.ttime > p.trial.(sn).preTrial
%             fixOn(p,sn) % fixation point on
%         end
%
%     case p.trial.(sn).states.FPON
%         %             fprintf('FPON\n')
%         % is fixation held
%         isheld=p.trial.(sn).hFix.isheld(currentEye);
%         if isheld && p.trial.ttime < p.trial.(sn).fixWait + p.trial.(sn).timeFpOn
%             fixHold(p,sn)
%         elseif p.trial.ttime > p.trial.(sn).fixWait + p.trial.(sn).timeFpOn
%             breakFix(p,sn)
%         end
%
%     case p.trial.(sn).states.FPHOLD
%         %             fprintf('FPHOLD\n')
%         % fixation controls motion
%         if ~p.trial.(sn).showMotion && p.trial.iFrame > p.trial.(sn).frameFpEntered + p.trial.(sn).preStim
%             motionOn(p,sn)
%         end
%
%         % is fixation held
%         isheld=p.trial.(sn).hFix.isheld(currentEye);
%         if isheld && p.trial.ttime < p.trial.(sn).maxFixHold + p.trial.(sn).timeFpEntered
%             % do nothing
%         elseif ~isheld && p.trial.ttime > p.trial.(sn).minFixHold + p.trial.(sn).timeFpEntered
%             fixOff(p,sn)
%             motionOff(p,sn)
%         else % break fixation
%             breakFix(p,sn)
%         end
%
%
% end
%
% end
%