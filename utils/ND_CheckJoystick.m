function p = ND_CheckJoystick(p)
% Read in the joystick signal, calculate the 
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
    
    sIdx = (p.trial.datapixx.adc.dataSampleCount - p.trial.behavior.joystick.Sample) : p.trial.datapixx.adc.dataSampleCount;  % determine the position of the sample. If this causes problems with negative values in the first trial, make sure to use only positive indices.

    % calculate a moving average of the joystick position for display reasons
    p.trial.joyX = mean((p.trial.AI.Joy.X(sIdx) - p.trial.behavior.joystick.Zero(1)));
    p.trial.joyY = mean((p.trial.AI.Joy.Y(sIdx) - p.trial.behavior.joystick.Zero(2)));

    % if relevant for task determine joystick state
    if(p.trial.behavior.joystick.use)

        % calculate amplitude for each time point in the current sample
        cAmp = sqrt((p.trial.AI.Joy.X(sIdx) - p.trial.behavior.joystick.Zero(1))^2 + ...
                    (p.trial.AI.Joy.Y(sIdx) - p.trial.behavior.joystick.Zero(2)).^2);

        switch p.trial.pldaps.JoyState.Current
            %% wait for release
            case p.trial.pldaps.JoyState.JoyHold
                jchk = cAmp > p.trial.behavior.joystick.RelThr; % invert selection to just use 'any'

                % all below threshold?
                if(~any(jchk))
                    p.trial.pldaps.JoyState.Current = p.trial.pldaps.JoyState.JoyRest;
                end

            %% wait for press
            case p.trial.pldaps.JoyState.JoyRest
                jchk = cAmp < p.trial.behavior.joystick.PullThr; % invert selection to just use 'any'

                % all above threshold?
                if(~any(jchk))
                    p.trial.pldaps.JoyState.Current = p.trial.pldaps.JoyState.JoyHold;
                end

            %% if it is nan, so just get the current state
            otherwise
                if(isnan(p.trial.pldaps.JoyState.Current))
                    if(cAmp(end) >= p.trial.behavior.joystick.PullThr)
                        p.trial.pldaps.JoyState.Current = p.trial.pldaps.JoyState.JoyHold;

                        % ToDo: define rect for threshold representation

                    elseif(cAmp(end) <= p.trial.behavior.joystick.RelThr)
                        p.trial.pldaps.JoyState.Current = p.trial.pldaps.JoyState.JoyRest;
                        % ToDo: define rect for threshold representation
                    else
                        p.trial.pldaps.JoyState.Current = NaN;
                    end
                else
                    error('Unknown joystick state!');
                end
        end % switch p.pldaps.JoyState.Current
   end  % if(p.trial.behavior.joystick.use)
end  % if(p.trial.datapixx.useJoystick)

