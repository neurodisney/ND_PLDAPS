function p = ND_AddAsciiEntry(p, Label, VarNm, FRMT, tbl)
% generate a template for an ASCII trial table
%
% This template is a string cell array where each row corresponds to an
% entry for each column in the SCII table. It is defined as label that is
% used in the header, as vaiable name and as format string. This format
% will be used to write later on data after each trial.

if nargin < 5
    tbl = 'session';
end

if ~isfield(p.defaultParameters.asciitbl, tbl)
    p.defaultParameters.asciitbl.(tbl) = struct;
end

if(~isfield(p.defaultParameters.asciitbl.(tbl), 'fmt'))
    p.defaultParameters.asciitbl.(tbl).fmt = {};
end

pos = size(p.defaultParameters.asciitbl.(tbl).fmt, 1) + 1; 

p.defaultParameters.asciitbl.(tbl).fmt(pos,:) = {Label, VarNm, FRMT};

