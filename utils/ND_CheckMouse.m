function p = ND_CheckMouse(p)
%% read in mouse information
% code based on pldap's default trial function.
% check for mouse actions and act accordingly.
%
%
% wolf zinke, Feb 2017

[cursorX, cursorY,buttons] = GetMouse();

iSamples =    p.trial.mouse.samples+1;
p.trial.mouse.samples = iSamples;
p.trial.mouse.samplesTimes(iSamples) = GetSecs;
p.trial.mouse.cursorSamples(:, iSamples) = [cursorX; cursorY];

%% Process Mouse buttons

% First get the state of the current buttons, and store it in the history
p.trial.mouse.buttons = buttons;
p.trial.mouse.buttonPressSamples( :, iSamples) = buttons';

% Then, check whether the button being down is new for this frame
% Store this in mouse.newButtons. 1 = newly pressed, 0 = no change, -1 = newly released
lastButtons = p.trial.mouse.buttonPressSamples(:, max(iSamples - 1, 1));
p.trial.mouse.newButtons = buttons' - lastButtons;


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
