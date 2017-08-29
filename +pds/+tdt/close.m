function p = close(p)
% Closes the UDP connection to TDT
% Nate Faber, August 2017

if p.trial.tdt.use
    % Only close the object if it exists
    if isfield(p.trial.tdt, 'UDP')
        delete(p.trial.tdt.UDP);
    end
end