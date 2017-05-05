function [xScreen, yScreen] = px2screen(p,xPx,yPx)
% px2screen uses the screen's coordinate frame to transform pixel values into screen coordinates
% a single [x,y] point can be specified as the second argument alternatively 
% Nate Faber, May 2017

if nargin == 2
    if size(xPx) == [1 2]
        yPx = xPx(2);
        xPx = xPx(1);
    else
        error('Bad Arguments')
    end
end

coordFrame = p.defaultParameters.display.coordMatrix;

transformedPoint = coordFrame \ [xPx; yPx; 1];

xScreen = transformedPoint(1);
yScreen = transformedPoint(2);