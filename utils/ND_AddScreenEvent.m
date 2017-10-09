function p = ND_AddScreenEvent(p, EVcode, EVname)
% queue a list of screen events associated with intended changes of the animal screen
%
% This function should be called after issuing a command that draws stuff on 
% the animal screen in order to send a corresponding event code just after that 
% to the DAQ and store the event time of the actual screen change (flip).
        
p.trial.pldaps.draw.ScreenEvent(end+1) = EVcode;       

if(nargin > 2)
    p.trial.pldaps.draw.ScreenEventName{end+1} = EVname;  
else
    p.trial.pldaps.draw.ScreenEventName{end+1} = [];  
end


