function p = ND_CheckMouse(p)
%% read in mouse information
% code based on pldap's default trial function.
% check for mouse actions and act accordingly.
%
%
% wolf zinke, Feb 2017
% Nate Faber, May 2017

[cursorX, cursorY,buttons] = GetMouse();

iSamples =    p.trial.mouse.samples+1;
p.trial.mouse.samples = iSamples;
p.trial.mouse.samplesTimes(iSamples) = GetSecs;

% Store the pixel mouse position
p.trial.mouse.cursorPxSamples(:, iSamples) = [cursorX; cursorY];

% Also get the mouse position in screen coordinates (if transformed with a coordinate frame)
coordFrame = p.trial.display.coordMatrix;
transformedMouse = (coordFrame \ [cursorX; cursorY; 1])';
p.trial.mouse.cursorSamples(:, iSamples) = transformedMouse(1:2);

%% Process Mouse buttons

% First get the state of the current buttons, and store it in the history
p.trial.mouse.buttons = buttons;
p.trial.mouse.buttonPressSamples( :, iSamples) = buttons';

% Then, check whether the button being down is new for this frame
% Store this in mouse.newButtons. 1 = newly pressed, 0 = no change, -1 = newly released
lastButtons = p.trial.mouse.buttonPressSamples(:, max(iSamples - 1, 1));
p.trial.mouse.newButtons = buttons' - lastButtons;
