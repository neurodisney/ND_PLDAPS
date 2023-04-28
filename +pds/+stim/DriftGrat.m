classdef DriftGrat < pds.stim.BaseStim
% Drifting grating stimulus
% John Amodeo, Apr 2023
    
    properties
        
        res
        radius
        
        cycles_per_sec
        sFreq
        angle
        draw_mask

        visible_size
        grating_tex
        masktex
        
        srcRect

    end
    

    methods
                 
        function obj = DriftGrat(p, pos, fixWin, res, radius, cycles_per_sec, sFreq, angle, draw_mask)
           
            if nargin < 2 || isempty(pos)
                pos = p.trial.stim.DRIFTGRAT.pos;
            end
            
            if nargin < 3 || isempty(fixWin)
                fixWin = p.trial.stim.DRIFTGRAT.fixWin;
            end

            if nargin < 4 || isempty(res)
                res = p.trial.stim.DRIFTGRAT.res;
            end
            
            if nargin < 5 || isempty(radius)
                radius = p.trial.stim.DRIFTGRAT.radius;
            end
            
            if nargin < 6 || isempty(cycles_per_sec)
                cycles_per_sec = p.trial.stim.DRIFTGRAT.cycles_per_sec;
            end
            
            if nargin < 7 || isempty(sFreq)
                sFreq = p.trial.stim.DRIFTGRAT.sFreq;
            end
            
            if nargin < 8 || isempty(angle)
                angle = p.trial.stim.DRIFTGRAT.angle;
            end

            if nargin < 9 || isempty(draw_mask)
                draw_mask = p.trial.stim.DRIFTGRAT.draw_mask;
            end
            
            % Load the BaseStim superclass
            obj@pds.stim.BaseStim(p, pos, fixWin)
            
            % Integer to define object (for sending event code)
            obj.classCode = p.trial.event.STIM.DriftGrat;

            % This cell array determines the order of properties when the propertyArray attribute is calculated
            obj.recordProps = {};

            obj.res            = res;
            obj.radius         = radius;
            
            obj.cycles_per_sec = cycles_per_sec;
            obj.sFreq          = sFreq;
            
            obj.angle          = angle;
            obj.draw_mask      = draw_mask;
            
            obj.srcRect        = [0, 0, 2*obj.res + 1, 2*obj.res + 1];

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
                    Screen('BlendFunction', obj.srcRect, GL_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                end

                pix_per_cycle = ceil(1/sFreq);
                freq_in_radians = sFreq*2*pi;
                
                obj.visible_size = 2*obj.res+1;

                x = meshgrid(-obj.res:obj.res + pix_per_cycle, 1);
                grating = gray + increment*cos(freq_in_radians*x);
                
%                 CoorVec = linspace(-obj.res, obj.res, 2*obj.res);
%                 [x, y]  = meshgrid(CoorVec, CoorVec);                
                
%                 circle = (x.^2 + y.^2 <= obj.res^2);
%                 grating(:,:,2) = 0;
%                 grating(1:2*obj.res, 1:2*obj.res, 2) = circle;
                 
                obj.grating_tex = Screen('MakeTexture', p.trial.display.ptr, grating);

%                 mask = ones(2*tex_size+1, 2*tex_size+1, 2) * gray;
%                 [x,y] = meshgrid(-1*tex_size:1*tex_size, -1*tex_size:1*tex_size);
%                 mask(:, :, 2) = round(white*(1-exp(-((x/90).^2)-((y/90).^2))));
%                 obj.masktex = Screen('MakeTexture', p.trial.display.ptr, mask);

            catch
                sca;
                psychrethrow(psychlasterror);
            end

        end
        
        % Function to present cue and distractor rings on screen
        function draw(obj, p)
            
                if obj.on
                    try
                        % Draw  texture on screen
                        priorityLevel = MaxPriority(p.trial.display.ptr);

                        dstRect = [obj.pos - obj.radius, obj.pos + obj.radius];

                        ifi = p.trial.display.ifi;
                        wait_frames = 1;
                        wait_dur = ifi * wait_frames;

                        pix_per_cycle = 1/obj.sFreq;

                        shifts_per_frame = obj.cycles_per_sec * pix_per_cycle * wait_dur;

                        i = 0;
                        x_offset = mod(i*shifts_per_frame, pix_per_cycle);
                        i = i + 1;

                        %srcRect = [x_offset 0 x_offset + obj.visible_size obj.visible_size];

                        Screen('DrawTexture', p.trial.display.ptr, obj.grating_tex, obj.srcRect, dstRect, obj.angle);
                   
                    catch
                        sca;
                        psychrethrow(psychlasterror);   
                    end
                    
                end
            
        end

    end

end

