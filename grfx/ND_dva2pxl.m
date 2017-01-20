function [pxl, realdva] = ND_dva2pxl(dva, p)
% convert dva to pixel
%
%
% wolf zinke, Jan. 2017

if(isnumeric(p))
    ppdva = p;
else
    ppdva = p.trial.display.ppd;
end

pxl     = floor(dva .* ppdva + 0.5);
realdva = numpxl ./ ppdva;  % what size is actually achieved (i.e. coping with rounding issues in raster grafics)

