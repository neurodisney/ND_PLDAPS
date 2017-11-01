function p = init(p)
% Initializes PLDAPS to use the TDT port by loading an instance of the TDTUDP class
% Nate Faber, August 2017

if(p.trial.tdt.use)
    % Only instantiate if the object does not exist
    if(~isfield(p.defaultParameters.tdt, 'UDP'))
        p.trial.tdt.UDP = pds.tdt.TDTUDP(p.trial.tdt.ip, 'TYPE', 'uint32');
    end
end