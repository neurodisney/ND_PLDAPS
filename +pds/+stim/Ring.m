classdef Ring < pds.stim.BaseStim
% Ring stimulus
% John Amodeo, Oct 2022

properties
    radius
    lineWeight
    flashing    
    color
    displayRect
  
end

methods
             
    function obj = Ring(p, radius, pos, lineWeight, color, fixWin)
       
        if nargin < 2 || isempty(radius)
            radius = p.trial.stim.RING.radius;
        end
      
        if nargin < 3 || isempty(pos)
            pos = p.trial.stim.RING.pos;
        end
        
        if nargin < 4 || isempty(lineWeight)
            lineWeight = p.trial.stim.RING.lineWeight;
        end
        
        if nargin < 5 || isempty(color)
            color = p.trial.stim.RING.color;
        end
        
        if nargin < 6 || isempty(fixWin)
            fixWin = p.trial.stim.RING.fixWin;
        end
           
        % Load the BaseStim superclass
        obj@pds.stim.BaseStim(p, pos, fixWin)
        
        % Integer to define object (for sending event code)
        obj.classCode = p.trial.event.STIM.Ring;
        
        % Fixspot is not counted as a stimulus, so it should not record its properties
        obj.recordProps = {};
        obj.color         = p.trial.display.clut.(color);
        obj.radius        = radius;
        obj.displayRect   = [pos - [radius, radius], pos + [radius, radius]];
        obj.lineWeight    = lineWeight;
        
        % Save a reference to this object in a dependable place in the p struct
        p.trial.behavior.cue.ring = obj;

   end
    
    % Function to present cue and distractor rings on screen
    function draw(obj, p)
        if obj.on 
            % Draw cue ring texture on screen
            Screen('FrameOval', p.trial.display.overlayptr, obj.color, obj.displayRect, obj.lineWeight(1), obj.lineWeight(2));
    
            % Flashing stimuli if flashing turned on
            if p.trial.stim.RING.flashing
                Screen('Flip', p.trial.display.ptr);
            end

        end
    end
end
    
end

