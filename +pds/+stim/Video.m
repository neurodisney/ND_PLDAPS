classdef Video < pds.stim.BaseStim
% Video stimulus
% John Amodeo, Jan 2024

    properties
        moviePath
        playRate
        volume
        size
        loop
    end

    properties (SetAccess = private, Hidden = true)
        moviePtr
        texturePtr
        duration
        frameRate
        currentTime
    end
    
    methods 
        function obj = Video(p, moviePath, pos, size, playRate, volume, loop, fixWin)
            if nargin < 2 || isempty(moviePath)
                moviePath = p.trial.stim.VIDEO.moviePath;
            end
            if nargin < 3 || isempty(pos)
                pos = p.trial.stim.VIDEO.pos;
            end
            if nargin < 4 || isempty(size)
                size = [p.trial.display.winRect(3), p.trial.display.winRect(4)];
            end
            if nargin < 5 || isempty(playRate)
                playRate = 1;
            end
            if nargin < 6 || isempty(volume)
                volume = 0;
            end
            if nargin < 7 || isempty(loop)
                loop = false;
            end
            if nargin < 8 || isempty(fixWin)
                fixWin = p.trial.stim.VIDEO.fixWin;
            end

            obj@pds.stim.BaseStim(p, pos, fixWin)
            obj.recordProps = {};

            obj.moviePath = moviePath;
            obj.size = size;
            obj.playRate = playRate;
            obj.volume = volume;
            obj.loop = loop;

            if obj.moviePath
                [obj.moviePtr, obj.duration, fr, w, h, c, ar] = Screen('OpenMovie', p.trial.display.ptr, obj.moviePath);
                Screen('SetMovieTimeIndex', obj.moviePtr, 0)
            end

        end

        function draw(obj, p)
            if obj.moviePath
                if obj.on
                    Screen('PlayMovie', obj.moviePtr, obj.playRate);
                    obj.texturePtr = Screen('GetMovieImage', p.trial.display.ptr, obj.moviePtr);
                    if obj.texturePtr > 0
                        destRect = CenterRectOnPoint([0, 0, obj.size(1), obj.size(2)], obj.pos(1), obj.pos(2));
                        Screen('DrawTexture', p.trial.display.ptr, obj.texturePtr, [], destRect, 180);
                        Screen('Close', obj.texturePtr);
                    end
                else
                    Screen('PlayMovie', obj.moviePtr, 0);
                end
            else
                error('No movie path provided to pds.stim.Video() or set to p.trial.stim.VIDEO.moviePath.')
            end
        end

        function cleanup(obj)
            cleanup@pds.stim.BaseStim(obj);
            Screen('CloseMovie', obj.moviePtr)
        end
        
    end
end
   

