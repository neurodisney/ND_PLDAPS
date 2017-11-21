function ND_Trial2Ascii(p, act, tbl)
% generate a formated ASCII table that summarizes trial data.
%
% This function needs an entry p.trial.session.asciifmt that must be created 
% prior the first call with ND_AddAsciiEntry. It takes the information from
% this cell array to write data to the file specified in p.trial.session.asciitbl.
%
% ToDo: - Var2Str might be modified to recognize the format of the variable
%         automatically so that the format entry could be removed in the future
%       - check that format and variable content match, and ensure that it
%         is one entry per variable.

if(nargin < 3)
    tbl = 'session';
end

switch act
    case 'init'
        
        if(~isfield(p.defaultParameters.asciitbl, tbl))
            p.defaultParameters.asciitbl.(tbl) = struct;
        end
        
        table = p.defaultParameters.asciitbl.(tbl);
        
        if(~isfield(table, 'fmt'))
            error('No ascii format defined yet');
        end
        
        Ndt = size(table.fmt, 1);
        
        % Generate the table file name
        tbldir = p.defaultParameters.session.dir;
        
        if(~isfield(table, 'file'))
            if strcmp(tbl,'session')
                % Default file for the session table
                table.file = fullfile(tbldir, [p.defaultParameters.session.filestem,'.dat']);
            else
                table.file = fullfile(tbldir, [p.defaultParameters.session.filestem, '_', tbl, '.dat']);
            end
            p.trial.asciitbl.(tbl).file = table.file;
        end
        
        if(Ndt > 0)
            HDstr = table.fmt{1,1};

            for(i=2:Ndt)
                HDstr = sprintf('%s  %s', HDstr, table.fmt{i,1});
            end
            
            tblptr = fopen(table.file , 'w');
            fprintf(tblptr, '%s \n', HDstr);
            fclose(tblptr);
        end
        
    case 'save'
        
        if(~isfield(p.trial.asciitbl, tbl))
            p.trial.asciitbl.(tbl) = struct;
        end
        
        table = p.trial.asciitbl.(tbl);
        
        Ndt = size(table.fmt, 1);
        
        if(Ndt > 0)
            LNstr = sprintf(table.fmt{1,3}, eval(table.fmt{1,2}));

            for(i=2:Ndt)
                LNstr = sprintf(['%s  ', table.fmt{i,3}] , LNstr, eval(table.fmt{i,2}));
            end
            
            tblptr = fopen(table.file , 'a');
            fprintf(tblptr, '%s \n', LNstr);
            fclose(tblptr);
        end
end

    