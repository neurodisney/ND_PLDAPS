function [xPx, yPx] = screen2px(p,xScreen,yScreen)
% screen2px uses the screen's coordinate frame to transform screen coordinates back into pixel values
% a single [x,y] point can be specified as the second argument alternatively
% Output will detect whether to return one or two things as well
% Nate Faber, May 2017

if nargin == 2
    if size(xScreen) == [1 2]
        yScreen = xScreen(2);
        xScreen = xScreen(1);
    else
        error('Bad Arguments')
    end
end

coordFrame = p.trial.display.coordMatrix;

transformedPoint = coordFrame * [xScreen; yScreen; 1];

if nargout == 2
    xPx = transformedPoint(1);
    yPx = transformedPoint(2);
else
    xPx = transformedPoint(1:2);
end