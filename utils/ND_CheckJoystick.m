function p = ND_CheckJoystick(p)
% Read in the joystick signal, calculate the elevation level and compare to
% thresolds defining Pull/Release state of the joystick.
%
% The current implementation checks the general amplitude of the joystick deflection
% irrespective of direction. Future ToDo might be to add an option to identify and
% utilize the direction of deflection as well.
%
% In the current form this relies on a clear naming convention where the analog
% joystick signal and joystick parameters are stored.
%
% wolf zinke, Jan. 2017

if(p.trial.datapixx.useJoystick)
    
    sIdx = (p.trial.datapixx.adc.dataSampleCount - p.trial.behavior.joystick.Sample + 1) : p.trial.datapixx.adc.dataSampleCount;  % determine the position of the sample. If this causes problems with negative values in the first trial, make sure to use only positive indices.

    % calculate amplitude for each time point in the current sample
    p.trial.AI.Joy.Amp(sIdx) = sqrt((p.trial.AI.Joy.X(sIdx) - p.trial.behavior.joystick.Zero(1)).^2 + ...
                                    (p.trial.AI.Joy.Y(sIdx) - p.trial.behavior.joystick.Zero(2)).^2);
    
    % calculate a moving average of the joystick position for display reasons
    p.trial.joyX   = mean(p.trial.AI.Joy.X(sIdx) - p.trial.behavior.joystick.Zero(1));
    p.trial.joyY   = mean(p.trial.AI.Joy.Y(sIdx) - p.trial.behavior.joystick.Zero(2));
    p.trial.joyAmp = mean(p.trial.AI.Joy.Amp(sIdx));
    
    % if relevant for task determine joystick state
    if(p.trial.behavior.joystick.use)
        % ND_CtrlMsg(p, ['Joystick State: ',int2str(p.trial.JoyState.Current),'; curr Amp: ',num2str(p.trial.joyAmp,'%.4f')]);

        switch p.trial.JoyState.Current
            %% wait for release
            case p.trial.JoyState.JoyHold
                jchk = p.trial.AI.Joy.Amp(sIdx) > p.trial.behavior.joystick.RelThr; % invert selection to just use 'any'

                % all below threshold?
                if(~any(jchk))
                    p.trial.JoyState.Current = p.trial.JoyState.JoyRest;
                    ND_CtrlMsg(p, 'Joystick Released...');
                end

            %% wait for press
            case p.trial.JoyState.JoyRest
                jchk = p.trial.AI.Joy.Amp(sIdx) < p.trial.behavior.joystick.PullThr; % invert selection to just use 'any'

                % all above threshold?
                if(~any(jchk))
                    p.trial.JoyState.Current = p.trial.JoyState.JoyHold;
                    ND_CtrlMsg(p, 'Joystick Pressed...');
                end

            %% if it is nan, so just get the current state
            otherwise
                if(isnan(p.trial.JoyState.Current))
                    if(p.trial.AI.Joy.Amp(p.trial.datapixx.adc.dataSampleCount) >= p.trial.behavior.joystick.PullThr)
                        p.trial.JoyState.Current = p.trial.JoyState.JoyHold;

                    elseif(p.trial.AI.Joy.Amp(p.trial.datapixx.adc.dataSampleCount) <= p.trial.behavior.joystick.RelThr)
                        p.trial.JoyState.Current = p.trial.JoyState.JoyRest;
                        
                    else
                        p.trial.JoyState.Current = NaN;
                    end
                else
                    error('Unknown joystick state!');
                end
        end  % switch p.JoyState.Current
   end  % if(p.trial.behavior.joystick.use)
   
   if(p.trial.pldaps.draw.joystick.use)
       %% update joystick representation
       % show current elevation
       cjpos = [p.trial.pldaps.draw.joystick.pos(1), ...
                p.trial.pldaps.draw.joystick.rect(4) - p.trial.joyAmp * p.trial.pldaps.draw.joystick.sclfac];

        p.trial.pldaps.draw.joystick.levelrect = ND_GetRect(cjpos, p.trial.pldaps.draw.joystick.levelsz);

        % get a representation of the current threshold to recognize pull/release
        p.trial.pldaps.draw.joystick.threct = p.trial.pldaps.draw.joystick.rect;

        switch p.trial.JoyState.Current

            % wait for press
            case p.trial.JoyState.JoyRest
                p.trial.pldaps.draw.joystick.threct(2) = p.trial.pldaps.draw.joystick.threct(2) + ...
                                                        (p.trial.pldaps.draw.joystick.size(2)   - ...
                                                         p.trial.behavior.joystick.PullThr * p.trial.pldaps.draw.joystick.sclfac);
            % wait for release
            case p.trial.JoyState.JoyHold
                p.trial.pldaps.draw.joystick.threct(2) = p.trial.pldaps.draw.joystick.threct(2) + ...
                                                        (p.trial.pldaps.draw.joystick.size(2)   - ...
                                                         p.trial.behavior.joystick.RelThr * p.trial.pldaps.draw.joystick.sclfac);
        end       
   end
end  % if(p.trial.datapixx.useJoystick)

