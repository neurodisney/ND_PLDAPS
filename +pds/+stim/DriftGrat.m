classdef DriftGrat < pds.stim.BaseStim
% Drifting grating stimulus
% John Amodeo, Apr 2023
    
    properties
        
        size
        cycles_per_sec
        temp_f
        angle
        draw_mask

        visible_size
        grating_tex
        masktex

    end
    

    methods
                 
        function obj = DriftGrat(p, pos, fixWin, size, cycles_per_sec, temp_f, angle, draw_mask)
           
            if nargin < 2 || isempty(pos)
                pos = p.trial.stim.DRIFTGRAT.pos;
            end

            if nargin < 3 || isempty(fixWin)
                fixWin = p.trial.stim.DRIFTGRAT.fixWin;
            end
          
            if nargin < 4 || isempty(size)
                size = p.trial.stim.DRIFTGRAT.size;
            end
            
            if nargin < 5 || isempty(cycles_per_sec)
                cycles_per_sec = p.trial.stim.DRIFTGRAT.cycles_per_sec;
            end
            
            if nargin < 6 || isempty(temp_f)
                temp_f = p.trial.stim.DRIFTGRAT.temp_f;
            end
            
            if nargin < 7 || isempty(angle)
                angle = p.trial.stim.DRIFTGRAT.angle;
            end

            if nargin < 8 || isempty(draw_mask)
                draw_mask = p.trial.stim.DRIFTGRAT.draw_mask;
            end
               
            % Load the BaseStim superclass
            obj@pds.stim.BaseStim(p, pos, fixWin)
            
            % Integer to define object (for sending event code)
            obj.classCode = p.trial.event.STIM.DriftGrat;

            % This cell array determines the order of properties when the propertyArray attribute is calculated
            obj.recordProps = {};

            obj.size           = size;
            obj.cycles_per_sec = cycles_per_sec;
            obj.temp_f         = temp_f;
            obj.angle          = angle;
            obj.draw_mask      = draw_mask;

            % Preparing drifting grating texture using DriftDemo2 in
            % Psychtoolbox3.
            % 'w' equates to 'p.trial.display.ptr' and 'screenRect' equates
            % to 'p.trial.display.winRect'.
            try
                AssertOpenGL;
    
                screens = Screen('Screens');
                screenNumber = max(screens);
    
                white = WhiteIndex(screenNumber);
                black = BlackIndex(screenNumber);
                gray = round((white+black)/2);
                if gray == white
                    gray = white/2;
                end
                increment = white-gray;

                if draw_mask
                    Screen('BlendFunction', obj.w, GL_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                end

                pix_per_cycle = ceil(1/temp_f);
                freq_in_radians = temp_f*2*pi;
                
                tex_size = size/2;
                obj.visible_size = 2*tex_size+1;

                x = meshgrid(-1*tex_size:1*tex_size + pix_per_cycle, 1);
                grating = gray + increment*cos(freq_in_radians*x);
                obj.grating_tex = Screen('MakeTexture', p.trial.display.ptr, grating);

                mask = ones(2*tex_size+1, 2*tex_size+1, 2) * gray;
                [x,y] = meshgrid(-1*tex_size:1*tex_size, -1*tex_size:1*tex_size);
                mask(:, :, 2) = round(white*(1-exp(-((x/90).^2)-((y/90).^2))));
                obj.masktex = Screen('MakeTexture', p.trial.display.ptr, mask);

            catch
                sca;
                psychrethrow(psychlasterror);
            end

        end
        
        % Function to present cue and distractor rings on screen
        function draw(obj, p)

            try
                if obj.on 
                    % Draw  texture on screen
                    priorityLevel = MaxPriority(p.trial.display.ptr);
    
                    dstRect = [0 0 obj.visible_size obj.visible_size];
                    dstRect = CenterRect(dstRect, p.trial.display.winRect);
    
                    ifi = Screen('GetFlipInterval', p.trial.display.ptr);
                    disp(1);

                end

            catch
                sca;
                psychrethrow(psychlasterror);      
            end
            
        end

    end

end

