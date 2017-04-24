function p = openScreen(p)
%openScreen    opens PsychImaging Window with preferences set for special
%              devices like datapixx.
%
% required fields
% p.defaultParameters.display.
%   stereoMode      [double] -  0 is no stereo
%   normalizeColor  [boolean] - 1 normalized color range on PTB screen
%   useOverlay      [double]  - 0,1,2 opens different overlay windows
%                             - 0=no overlay, 1=datapixx, 2=software
%   stereoFlip      [string]  - 'left', 'right', or [] flips one stereo
%                               image for the planar screen
%   colorclamp      [boolean] - 1 clamps color between 0 and 1
%   scrnNum         [double]  - number of screen to open
%   sourceFactorNew [string]  - see Screen Blendfunction?
%   destinationFactorNew      - see Screen Blendfunction?
%   widthcm
%   heightcm
%   viewdist
%   bgColor

% 12/12/2013 jly wrote it   Mostly taken from Init_StereoDispPI without any
%                           of the switch-case in the front for each rig.
%                           This assumes you have set up your display
%                           struct before calling.
% 01/20/2014 jly update     Updated help text and added default arguments.
%                           Created a distinct variable to separate
%                           colorclamp and normalize color.
% 05/2015    jk  update     changed for use with version 4.1
%                           moved default parameters to the
%                           pldapsClassDefaultParameters


InitializeMatlabOpenGL(0,0); %second 0: debug level =0 for speed
% prevent splash screen
Screen('Preference','VisualDebugLevel',3);
% Initiate Psych Imaging screen configs
PsychImaging('PrepareConfiguration');

%% Setup Psych Imaging
% Add appropriate tasks to psych imaging pipeline

% set the size of the screen
if p.defaultParameters.display.stereoMode >= 6 || p.defaultParameters.display.stereoMode <=1
    p.defaultParameters.display.width = 2*atand(p.defaultParameters.display.widthcm/2/p.defaultParameters.display.viewdist);
else
    p.defaultParameters.display.width = 2*atand((p.defaultParameters.display.widthcm/4)/p.defaultParameters.display.viewdist);
end

if p.defaultParameters.display.normalizeColor == 1
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Turning on Normalized High res Color Range')
    disp('Sets all displays to use color range from 0-1 (e.g. NOT 0-255)')
    disp('Potential danger: this fxn sets color range to unclamped...don''t')
    disp('know if this will cause issue. TBC 12-18-2012')
    disp('****************************************************************')
    PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
end

if p.defaultParameters.datapixx.use
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Adds flags for UseDataPixx')
    disp('****************************************************************')
    % Tell PTB we are using Datapixx
    PsychImaging('AddTask', 'General', 'UseDataPixx');
    PsychImaging('AddTask', 'General', 'FloatingPoint32Bit','disableDithering',1);
    
    if p.defaultParameters.display.useOverlay==1
        % Turn on the overlay
        disp('Using overlay window (EnableDataPixxM16OutputWithOverlay)')
        disp('****************************************************************')
        PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
    end
else
%     disp('****************************************************************')
%     disp('****************************************************************')
%     disp('No overlay window')
%     disp('****************************************************************')
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
end

if strcmp(p.defaultParameters.display.stereoFlip,'right');
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Setting stereo mode for use with planar')
    disp('Flipping the RIGHT monitor to be a mirror image')
    disp('****************************************************************')
    PsychImaging('AddTask', 'RightView', 'FlipHorizontal');
elseif strcmp(p.defaultParameters.display.stereoFlip,'left')
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Setting stereo mode for use with planar')
    disp('Flipping the LEFT monitor to be a mirror image')
    disp('****************************************************************')
    PsychImaging('AddTask', 'LeftView', 'FlipHorizontal');
end

% fancy gamma table for each screen
% if 2 gamma tables
% PsychImaging('AddTask', 'LeftView', 'DisplayColorCorrection', 'LookupTable');
% PsychImaging('AddTask', 'RightView', 'DisplayColorCorrection', 'LookupTable');
% end
disp('****************************************************************')
disp('****************************************************************')
disp('Adding DisplayColorCorrection to FinalFormatting')
disp('****************************************************************')
if isField(p.defaultParameters, 'display.gamma.power')
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
else
	PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'LookupTable');
end


%% Open double-buffered onscreen window with the requested stereo mode
disp('****************************************************************')
disp('****************************************************************')
fprintf('Opening screen %d with background %02.2f in stereo mode %d\r', p.defaultParameters.display.scrnNum, p.defaultParameters.display.bgColor(1), p.defaultParameters.display.stereoMode)
disp('****************************************************************')
[ptr, winRect]=PsychImaging('OpenWindow', p.defaultParameters.display.scrnNum, p.defaultParameters.display.bgColor, p.defaultParameters.display.screenSize, [], [], p.defaultParameters.display.stereoMode, 0);
p.defaultParameters.display.ptr=ptr;
p.defaultParameters.display.winRect=winRect;
if p.defaultParameters.display.useOverlay==2
    p.defaultParameters.display.winRect(3)=p.defaultParameters.display.winRect(3)/2;
end

%% Set some basic variables about the display
p.defaultParameters.display.ppd   = p.defaultParameters.display.winRect(3)/p.defaultParameters.display.width; % calculate pixels per degree
p.defaultParameters.display.frate = round(1/Screen('GetFlipInterval',p.defaultParameters.display.ptr));   % frame rate (in Hz)
p.defaultParameters.display.ifi   = Screen('GetFlipInterval', p.defaultParameters.display.ptr);               % Inter-frame interval (frame rate in seconds)
p.defaultParameters.display.ctr   = [p.defaultParameters.display.winRect(3:4),p.defaultParameters.display.winRect(3:4)]./2 - 0.5;          % Rect defining screen center
p.defaultParameters.display.info  = Screen('GetWindowInfo', p.defaultParameters.display.ptr);              % Record a bunch of general display settings

%% some more
p.defaultParameters.display.pWidth=p.defaultParameters.display.winRect(3)-p.defaultParameters.display.winRect(1);
p.defaultParameters.display.pHeight=p.defaultParameters.display.winRect(4)-p.defaultParameters.display.winRect(2);
p.defaultParameters.display.wWidth=p.defaultParameters.display.widthcm;
p.defaultParameters.display.wHeight=p.defaultParameters.display.heightcm;
p.defaultParameters.display.dWidth = atand(p.defaultParameters.display.wWidth/2 / p.defaultParameters.display.viewdist)*2;
p.defaultParameters.display.dHeight = atand(p.defaultParameters.display.wHeight/2 / p.defaultParameters.display.viewdist)*2;
p.defaultParameters.display.w2px=[p.defaultParameters.display.pWidth/p.defaultParameters.display.wWidth; p.defaultParameters.display.pHeight/p.defaultParameters.display.wHeight];
p.defaultParameters.display.px2w=[p.defaultParameters.display.wWidth/p.defaultParameters.display.pWidth; p.defaultParameters.display.wHeight/p.defaultParameters.display.pHeight];

% Set screen rotation
p.defaultParameters.display.ltheta = 0.00*pi;                                    % Screen rotation to adjust for mirrors
p.defaultParameters.display.rtheta = -p.defaultParameters.display.ltheta;
p.defaultParameters.display.scr_rot = 0;                                         % Screen Rotation for opponency conditions

% Make text clean
Screen('TextFont',p.defaultParameters.display.ptr,'Helvetica');
Screen('TextSize',p.defaultParameters.display.ptr,16);
Screen('TextStyle',p.defaultParameters.display.ptr,1);

%% Push transformation matrices onto the graphics stack to change the origin and scale coordinates to degrees

% Get the pixels per degree at the center of the screen
p.defaultParameters.display.ppdCentral = tand(1) * p.defaultParameters.display.viewdist * p.defaultParameters.display.w2px; 

% Translate the origin
if isfield(p.defaultParameters.display, 'useCustomOrigin') && p.defaultParameters.display.useCustomOrigin ~= 0
    
    % If useCustomOrigin == 1, use a central origin
    if p.defaultParameters.display.useCustomOrigin == 1
        xTrans = p.defaultParameters.display.ctr(1); % p.defaultParameters.display.pWidth / 2;
        yTrans = p.defaultParameters.display.ctr(2); %p.defaultParameters.display.pHeight / 2;
    
    % If useCustomOrigin == [x,y], set the origin to x,y expressed in pixels
    elseif size(p.defaultParameters.display.useCustomOrigin) == 2
        xTrans = p.defaultParameters.display.useCustomOrigin(1);
        yTrans = p.defaultParameters.display.useCustomOrigin(2);
        
    % Otherwise give an error
    else
        error('pldaps:openScreen', 'Bad origin specified in p.defaultParameters.display.useCustomOrigin')
    end
    
    Screen('glTranslate', p.defaultParameters.display.ptr, xTrans, yTrans)
    p.defaultParameters.display.winRect = p.defaultParameters.display.winRect - [xTrans, yTrans, xTrans, yTrans];
end

% Scale the units to degrees of visual angle
if isfield(p.defaultParameters.display, 'useDegreeUnits') && p.defaultParameters.display.useDegreeUnits ~= 0
    
    % If useDegreeUnits == 1, scale uniformly prioritizing accuracy in center of screen (may be slightly inaccurate)
    if p.defaultParameters.display.useDegreeUnits == 1
        xScaleFactor = p.defaultParameters.display.ppdCentral(1);
        yScaleFactor = -p.defaultParameters.display.ppdCentral(2); % minus because we want + to be up
        
        Screen('glScale', p.defaultParameters.display.ptr, xScaleFactor, yScaleFactor)
        p.defaultParameters.display.winRect = p.defaultParameters.display.winRect ./ [xScaleFactor, yScaleFactor, xScaleFactor, yScaleFactor];
        
        % FillRect (and possibly other PTB functions) requires that a rect [x1 y1 x2 y2] satisfy x1 < x2 and y1 < y2. Therfore, flip the y values to satisfy this condition
        p.defaultParameters.display.winRect = p.defaultParameters.display.winRect([1 4 3 2]);
        
    % Otherwise give an error
    else
        error('pldaps:openScreen', 'Bad value for p.defaultParameters.display.useDegreeUnits')
    end

end

%% Assign overlay pointer
if p.defaultParameters.display.useOverlay==1
    if p.defaultParameters.datapixx.use
        p.defaultParameters.display.overlayptr = PsychImaging('GetOverlayWindow', p.defaultParameters.display.ptr); % , dv.params.bgColor);
    else
        warning('pldaps:openScreen', 'Datapixx Overlay requested but datapixx disabled. No Dual head overlay availiable!')
        p.defaultParameters.display.overlayptr = p.defaultParameters.display.ptr;
    end
elseif p.defaultParameters.display.useOverlay==2
    % if using a software overlay, adjust the window size to be half
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Using software overlay window')
    disp('****************************************************************')
    Screen('ColorRange', p.defaultParameters.display.ptr, 255)
    p.defaultParameters.display.overlayptr=Screen('OpenOffscreenWindow', p.defaultParameters.display.ptr, 0, [0 0 p.defaultParameters.display.pWidth p.defaultParameters.display.pHeight], 8, 32);
    Screen('ColorRange', p.defaultParameters.display.ptr, 1);
    
    % Retrieve low-level OpenGl texture handle to the window:
    p.defaultParameters.display.overlaytex = Screen('GetOpenGLTexture', p.defaultParameters.display.ptr, p.defaultParameters.display.overlayptr);
    
    % Disable bilinear filtering on this texture - always use
    % nearest neighbour sampling to avoid interpolation artifacts
    % in color index image for clut indexing:
    glBindTexture(GL.TEXTURE_RECTANGLE_EXT, p.defaultParameters.display.overlaytex);
    glTexParameteri(GL.TEXTURE_RECTANGLE_EXT, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    glTexParameteri(GL.TEXTURE_RECTANGLE_EXT, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    glBindTexture(GL.TEXTURE_RECTANGLE_EXT, 0);

    %% get information of current processing chain
    debuglevel = 1;
    [icmShaders, icmIdString, icmConfig] = PsychColorCorrection('GetCompiledShaders', p.defaultParameters.display.ptr, debuglevel);

    pathtopldaps=which('pldaps.m');
    p.defaultParameters.display.shader = LoadGLSLProgramFromFiles(fullfile(pathtopldaps, '..', '..', 'SupportFunctions', 'Utils', 'overlay_shader.frag'),2,icmShaders);

    if p.defaultParameters.display.info.GLSupportsTexturesUpToBpc >= 32
        % Full 32 bits single precision float:
        p.defaultParameters.display.internalFormat = GL.LUMINANCE_FLOAT32_APPLE;
    elseif p.defaultParameters.display.info.GLSupportsTexturesUpToBpc >= 16
        % No float32 textures:
        % Choose 16 bpc float textures:
        p.defaultParameters.display.internalFormat = GL.LUMINANCE_FLOAT16_APPLE;
    else
        % No support for > 8 bpc textures at all and/or no need for
        % more than 8 bpc precision or range. Choose 8 bpc texture:
        p.defaultParameters.display.internalFormat = GL.LUMINANCE;
    end

    %create look up textures
    p.defaultParameters.display.lookupstexs=glGenTextures(2);
    %% set variables in the shader
    glUseProgram(p.defaultParameters.display.shader);
    glUniform1i(glGetUniformLocation(p.defaultParameters.display.shader,'lookup1'),3);
    glUniform1i(glGetUniformLocation(p.defaultParameters.display.shader,'lookup2'),4);

    glUniform2f(glGetUniformLocation(p.defaultParameters.display.shader, 'res'), p.defaultParameters.display.pWidth, p.defaultParameters.display.pHeight);
    bgColor=p.defaultParameters.display.bgColor;
    glUniform3f(glGetUniformLocation(p.defaultParameters.display.shader, 'transparencycolor'), bgColor(1), bgColor(2), bgColor(3));
    glUniform1i(glGetUniformLocation(p.defaultParameters.display.shader, 'overlayImage'), 1);
    glUniform1i(glGetUniformLocation(p.defaultParameters.display.shader, 'Image'), 0);
    glUseProgram(0);

    %% assign the overlay texture as the input 1 (which maps to 'overlayImage' as set above)
    % It gets passed to the HookFunction call.
    % Input 0 is the main pointer by default.
    pString = sprintf('TEXTURERECT2D(1)=%i ', p.defaultParameters.display.overlaytex);
    pString = [pString sprintf('TEXTURERECT2D(3)=%i ', p.defaultParameters.display.lookupstexs(1))];
    pString = [pString sprintf('TEXTURERECT2D(4)=%i ', p.defaultParameters.display.lookupstexs(2))];
    
    %add information to the current processing chain
    idString = sprintf('Overlay Shader : %s', icmIdString);
    pString  = [ pString icmConfig ];
    Screen('HookFunction', p.defaultParameters.display.ptr, 'Reset', 'FinalOutputFormattingBlit');
    Screen('HookFunction', p.defaultParameters.display.ptr, 'AppendShader', 'FinalOutputFormattingBlit', idString, p.defaultParameters.display.shader, pString);
    PsychColorCorrection('ApplyPostGLSLLinkSetup', p.defaultParameters.display.ptr, 'FinalFormatting');
else
    p.defaultParameters.display.overlayptr = p.defaultParameters.display.ptr;
end

% % Set gamma lookup table
if isField(p.defaultParameters, 'display.gamma')
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Loading gamma correction')
    disp('****************************************************************')
    if isfield(p.defaultParameters.display.gamma, 'table')
        PsychColorCorrection('SetLookupTable', p.defaultParameters.display.ptr, p.defaultParameters.display.gamma.table, 'FinalFormatting');
    elseif isfield(p.defaultParameters.display.gamma, 'power')
        PsychColorCorrection('SetEncodingGamma', p.defaultParameters.display.ptr, p.defaultParameters.display.gamma.power, 'FinalFormatting');
        if isfield(p.defaultParameters.display.gamma, 'bias') &&isfield(p.defaultParameters.display.gamma, 'minL')...
           && isfield(p.defaultParameters.display.gamma, 'minL') &&  isfield(p.defaultParameters.display.gamma, 'gain')
            bias=p.defaultParameters.display.gamma.bias;
            minL=p.defaultParameters.display.gamma.minL;
            maxL=p.defaultParameters.display.gamma.maxL;
            gain=p.defaultParameters.display.gamma.gain;
            PsychColorCorrection('SetExtendedGammaParameters', p.defaultParameters.display.ptr, minL, maxL, gain, bias);
        end
    end
else
    %set a linear gamma
    PsychColorCorrection('SetLookupTable', ptr, linspace(0,1,256)'*[1, 1, 1], 'FinalFormatting');
end

% % This seems redundant. Is it necessary?
if p.defaultParameters.display.colorclamp == 1
    disp('****************************************************************')
    disp('****************************************************************')
    disp('clamping color range')
    disp('****************************************************************')
    Screen('ColorRange', p.defaultParameters.display.ptr, 1, 0);
end

%% Setup movie creation if desired
if p.defaultParameters.display.movie.create
    movie=p.defaultParameters.display.movie;
    if isempty(movie.file)
        movie.file=p.defaultParameters.session.file(1:end-4);
    end
    if isempty(movie.dir)
        movie.dir=p.defaultParameters.session.dir;
    end
    if isempty(movie.frameRate)
        movie.frameRate = p.defaultParameters.display.frate;
    end
    movie.ptr = Screen('CreateMovie', ptr, [movie.dir filesep movie.file '.avi'], movie.width,movie.height,movie.frameRate,movie.options);
    p.defaultParameters.display.movie=movie;
end

%% Set up alpha-blending for smooth (anti-aliased) drawing
disp('****************************************************************')
disp('****************************************************************')
fprintf('Setting Blend Function to %s,%s\r', p.defaultParameters.display.sourceFactorNew, p.defaultParameters.display.destinationFactorNew);
disp('****************************************************************')
Screen('BlendFunction', p.defaultParameters.display.ptr, p.defaultParameters.display.sourceFactorNew, p.defaultParameters.display.destinationFactorNew);  % alpha blending for anti-aliased dots

if p.defaultParameters.display.forceLinearGamma %does't really belong here, but need it before the first flip....
    LoadIdentityClut(p.defaultParameters.display.ptr);
end

p.defaultParameters.display.t0 = Screen('Flip', p.defaultParameters.display.ptr);
