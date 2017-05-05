function [xScreen, yScreen] = px2screen(p,xPx,yPx)
% px2screen uses the screen's coordinate frame to transform pixel values into screen coordinates
% a single [x,y] point can be specified as the second argument alternatively
% Output will detect whether to return one or two things as well
% Nate Faber, May 2017

if nargin == 2
    if size(xPx) == [1 2]
        yPx = xPx(2);
        xPx = xPx(1);
    else
        error('Bad Arguments')
    end
end

coordFrame = p.trial.display.coordMatrix;

transformedPoint = coordFrame \ [xPx; yPx; 1];

if nargout == 2
    xScreen = transformedPoint(1);
    yScreen = transformedPoint(2);
else
    xScreen = transformedPoint(1:2);
end