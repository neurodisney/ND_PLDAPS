classdef Image < pds.stim.BaseStim
% Video stimulus
% John Amodeo, May 2025

    properties
        imagePath
        dispSize
        duration
    end

    properties (SetAccess = private, Hidden = true)
        imageMatrix
        texturePtr
    end
    
    methods 
        function obj = Image(p, imagePath, pos, sizeGain, fixWin, duration)
            if nargin < 2 || isempty(imagePath)
                imagePath = p.trial.stim.IMAGE.imagePath;
            end
            if nargin < 3 || isempty(pos)
                pos = p.trial.stim.IMAGE.pos;
            end
            if nargin < 4 || isempty(sizeGain)
                sizeGain = p.trial.stim.IMAGE.sizeGain;
            end
            if nargin < 5 || isempty(fixWin)
                fixWin = p.trial.stim.IMAGE.fixWin;
            end
            if nargin < 6 || isempty(duration)
                duration = p.trial.stim.IMAGE.duration;
            end

            obj@pds.stim.BaseStim(p, pos, fixWin)
            obj.recordProps = {};

            obj.imagePath = imagePath;
            obj.dispSize = [p.trial.display.winRect(3), p.trial.display.winRect(4)] * sizeGain;
            obj.duration = duration;

            if obj.imagePath
                obj.imageMatrix = imread(obj.imagePath);
                obj.texturePtr = Screen('MakeTexture', p.trial.display.ptr, obj.imageMatrix);
            else
                error('Image not found: %s', obj.imagePath);
            end

        end

        function draw(obj, p)
            if obj.on
                destRect = CenterRectOnPoint([0, 0, obj.dispSize(1), obj.dispSize(2)], obj.pos(1), obj.pos(2));
                Screen('DrawTexture', p.trial.display.ptr, obj.texturePtr, [], destRect, 180);
            end
        end

        function cleanup(obj)
            cleanup@pds.stim.BaseStim(obj);
            Screen('Close', obj.texturePtr);
        end
        
    end
end
   


