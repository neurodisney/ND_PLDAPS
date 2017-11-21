function dva = ND_pxl2dva(pxl, p)
% convert dva to pixel
%
%
% wolf zinke, Jan. 2017

if(isnumeric(p))
    ppdva = p;
else
    ppdva = p.defaultParameters.display.ppd;
end

dva = pxl ./ ppdva;

