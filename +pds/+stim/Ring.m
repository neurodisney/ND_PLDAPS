% Ring stimulus
% John Amodeo, Oct 2022

classdef Ring < pds.stim.BaseStim

    
    properties

        radius
        displayRect 
        lineWeight  
        color
        contrast
        
        flash_screen

    end
    
    
    methods
            
        
        function obj = Ring(p, pos, fixWin, radius, lineWeight, color, contrast, flash_screen)
            
            if nargin < 2 || isempty(pos)
                pos = p.trial.stim.RING.pos;
            end
            
            if nargin < 3 || isempty(fixWin)
                fixWin = p.trial.stim.RING.fixWin;
            end
            
            if nargin < 4 || isempty(radius)
                radius = p.trial.stim.RING.radius;
            end
            
            if nargin < 5 || isempty(lineWeight)
                lineWeight = p.trial.stim.RING.lineWeight;
            end
            
            if nargin < 6 || isempty(color)
                color = p.trial.stim.RING.color;
            end

            if nargin < 7 || isempty(contrast)
                contrast = p.trial.stim.RING.contrast;
            end
            
            if nargin < 8 || isempty(flash_screen)
                flash_screen = p.trial.stim.RING.flash_screen;
            end
            
            
            % Load the BaseStim superclass
            obj@pds.stim.BaseStim(p, pos, fixWin)
            
            % Integer to define object (for sending event code)
            obj.classCode = p.trial.event.STIM.Ring;
            
            % This cell array determines the order of properties when the propertyArray attribute is calculated
            obj.recordProps = {'xpos', 'ypos', 'radius', 'contrast'};
  
            obj.radius        = radius;
            obj.displayRect   = [pos - [radius, radius], pos + [radius, radius]];
            obj.lineWeight    = lineWeight;
            obj.color = p.trial.display.clut.(color);
            obj.contrast = contrast;
            obj.flash_screen  = flash_screen;
    
       end
        
       % Function to present cue and distractor rings on screen
       function draw(obj, p)

            if obj.on 
                
                % Flickering screen if screen_flash is set to on
                if obj.flash_screen
               
                    Screen('Flip', p.trial.display.ptr);
                    Screen('Flip', p.trial.display.ptr);
                    Screen('Flip', p.trial.display.ptr);
                    
                end
                
                % Drawing cue ring texture on screen
                Screen('FrameOval', p.trial.display.overlayptr, obj.color, obj.displayRect, obj.lineWeight(1), obj.lineWeight(2));
                
            end
            
       end
       

    end
    
    
end

