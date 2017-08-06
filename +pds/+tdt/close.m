function p = close(p)
% Closes the UDP connection to TDT
% Nate Faber, August 2017

if p.trial.tdt.use
    % Only close the object if it exists
    if isfield(p.trial.tdt, 'UDP')
        p.trial.tdt.UDP.close;
    end
end