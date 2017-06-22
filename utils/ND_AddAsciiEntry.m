function p = ND_AddAsciiEntry(p, Label, VarNm, FRMT)
% generate a template for an ASCII trial table
%
% This template is a string cell array where each row corresponds to an
% entry for each column in the SCII table. It is defined as label that is
% used in the header, as vaiable name and as format string. This format
% will be used to write later on data after each trial.

if(~isfield(p.trial.session, 'asciifmt'))
    p.trial.session.asciifmt = {};
end

pos = size(p.trial.session.asciifmt, 1) + 1; 

p.trial.session.asciifmt(pos,:) = {Label, VarNm, FRMT};

