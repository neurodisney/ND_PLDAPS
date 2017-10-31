function p = init(p)
% Initializes PLDAPS to use the TDT port by loading an instance of the TDTUDP class
% Nate Faber, August 2017

if(p.defaultParameters.tdt.use)
    % Only instantiate if the object does not exist
    if(~isfield(p.defaultParameters.tdt, 'UDP'))
        p.defaultParameters.tdt.UDP = pds.tdt.TDTUDP(p.defaultParameters.tdt.ip, 'TYPE', 'uint32');
    end
end