function [ptb_x, ptb_y] = ND_cart2ptb(p, xc, yc, scrctr, scres)
% convert cartesian pixel coordinates (origin is screen center) into coordinates used by the psychtoolbox,
% see http://docs.psychtoolbox.org/Screen : "All screen and window coordinates
% follow Apple Macintosh conventions".
%
%
% wolf zinke, Jan. 2017

% allow specification of xy coordinate array (not recommended use)
if (~exist('yc','var')  )
    yc = [];
end

if(min(size(xc)) > 1 || isempty(yc))
    if(exist('yc','var') && ~isempty(yc) )
        warning('ARGUMENT CONFLICT: Two dimensional matrix supplied as coordinates, but also y coordinate specified!');
    end
    yc = xc(:,2);
    xc = xc(:,1);
end

if (~exist('scres','var') || isempty(scres) )
    scres = [p.trial.display.pWidth, p.trial.display.pHeight];
end

if (~exist('scrctr','var') || isempty(scrctr) )
    scrctr = p.trial.display.ctr;
end

ptb_x = round(scres(1)/2 + xc(:) + scrctr(1) - scres(1)/2 );
ptb_y = round(scres(2)/2 - yc(:) + scrctr(2) - scres(2)/2 );


if(nargout < 2)
    ptb_x = [ptb_x(:), ptb_y(:)];
end
