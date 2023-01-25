classdef Rectangle < pds.stim.BaseStim
% Ring stimulus
% John Amodeo, Jan 2023

properties
    coordinates
    contrast
    color
    reward
end



methods
             
   function obj = Rectangle(p, coordinates, contrast, pos, color, reward, fixWin)
       
        if nargin < 2 || isempty(coordinates)
            coordinates = p.trial.stim.RECTANGLE.coordinates;
        end
       
        if nargin < 2 || isempty(contrast)
            contrast = p.trial.stim.RECTANGLE.contrast;
        end
      
        if nargin < 3 || isempty(pos)
            pos = p.trial.stim.RECTANGLE.pos;
        end
        
        if nargin < 5 || isempty(color)
            color = p.trial.stim.RECTANGLE.color;
        end
        
        if nargin < 6 || isempty(reward)
            reward = p.trial.stim.RECTANGLE.reward;
        end
        
        if nargin < 7 || isempty(fixWin)
            fixWin = p.trial.stim.RECTANGLE.fixWin;
        end
           
        % Load the BaseStim superclass
        obj@pds.stim.BaseStim(p, pos, fixWin)
        
        % Integer to define object (for sending event code)
        %obj.classCode = p.trial.event.STIM.Rectangle;
        
        % Fixspot is not counted as a stimulus, so it should not record its properties
        obj.recordProps = {};  
        obj.color       = p.trial.display.clut.(color);
        obj.contrast    = contrast;
        obj.coordinates = coordinates;
        obj.reward      = reward;
        
        % Save a reference to this object in a dependable place in the p struct
        p.trial.behavior.stim.rectangle = obj;
   end



   % Function to present cue and distractor rings on screen
   function draw(obj, p)
        if obj.on
            % Draw cue ring texture on screen
            Screen('FillRect', p.trial.display.overlayptr, obj.color, obj.coordinates);
           
            % Flashing stimuli if flashing turned on
            if p.trial.stim.RECTANGLE.flashing
                Screen('Flip', p.trial.display.ptr);
            end
        end
    end
    
end
end

