function qp = ND_CheckMouse(p)
%% read in mouse information
% code based on pldap's default trial function.
% check for mouse actions and act accordingly.
%
%
% wolf zinke, Feb 2017

[cursorX, cursorY,isMouseButtonDown] = GetMouse();

p.trial.mouse.samples =    p.trial.mouse.samples+1;
p.trial.mouse.samplesTimes(p.trial.mouse.samples) = GetSecs;
p.trial.mouse.X(p.trial.mouse.samples) = cursorX;
p.trial.mouse.Y(p.trial.mouse.samples) = cursorY;
p.trial.mouse.buttonPressSamples( :, p.trial.mouse.samples) = isMouseButtonDown';

%if(p.trial.mouse.useAsEyepos)
%    if(p.trial.pldaps.eyeposMovAv == 1) % just take a single sample
%        p.trial.eyeX = p.trial.mouse.cursorSamples(1,p.trial.mouse.samples);
%        p.trial.eyeY = p.trial.mouse.cursorSamples(2,p.trial.mouse.samples);
%    else % Do moving average:  calculate mean over as many samples as the number in eyeposMovAv specifies
%        mInds = (p.trial.mouse.samples-p.trial.pldaps.eyeposMovAv+1):p.trial.mouse.samples;
%        p.trial.eyeX = mean(p.trial.mouse.cursorSamples(1,mInds));
%        p.trial.eyeY = mean(p.trial.mouse.cursorSamples(2,mInds));
%    end
%end  %/ if(p.trial.mouse.useAsEyepos)
