function p = ND_CheckJoystick(p, task)
% Read in the joystick signal, calculate the 
%
% The current implementation checks the general amplitude of the joystick deflection
% irrespective of direction. Future ToDo might be to add an option to identify and
% utilize the direction of deflection as well.
%
% In the current form this relies on a clear naming convention where the analog
% joystick signal got stored. Might be generalized in the future.
%
% wolf zinke, Jan. 2017


if(p.trial.datapixx.useJoystick)
    
    sIdx = (p.trial.datapixx.adc.dataSampleCount - p.trial.datapixx.adc.JoySample) : p.trial.datapixx.adc.dataSampleCount;  % determine the position of the sample. If this causes problems with negative values in the first trial, make sure to use only positive indices.

    % calculate amplitude for each time point in the current sample
    cAmp = sqrt((p.trial.AI.Joy.X(sIdx) - p.trial.datapixx.adc.JoyZero(1))^2 + ...
                (p.trial.AI.Joy.Y(sIdx) - p.trial.datapixx.adc.JoyZero(2)).^2);

   switch p.pldaps.JoyState.Current
              
       case p.pldaps.JoyState.JoyHold  % wait for release
            jchk = cAmp < p.trial.(task).Joy.RelThr;
            
       case p.pldaps.JoyState.JoyRest  % wait for press
            jchk = cAmp > p.trial.(task).Joy.PullThr;
           
       otherwise % it is nan, so just get the current state
           if(isnan(p.pldaps.JoyState.Current))
               
           else
               error('Unknown joystick state!');
           end
           
           
   end
           


end