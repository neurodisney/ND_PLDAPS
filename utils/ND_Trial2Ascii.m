function ND_Trial2Ascii(p, act)
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

switch act
    case 'init'
        
        if(~isfield(p.trial.session, 'asciifmt'))
            error('No p.trial.session.asciifmt defined yet');
        end
        
        Ndt = size(p.trial.session.asciifmt, 1);
        
        if(Ndt > 1)
            HDstr = p.trial.session.asciifmt{1,1};

            for(i=2:Ndt)
                HDstr = sprintf('%s  %s', HDstr, p.trial.session.asciifmt{i,1});
            end
            
            tblptr = fopen(p.trial.session.asciitbl , 'w');
            fprintf(tblptr, '%s \n', HDstr);
            fclose(tblptr);
        end
        
    case 'save'
        
        Ndt = size(p.trial.session.asciifmt, 1);
        
        if(Ndt > 1)
            LNstr = sprintf(p.trial.session.asciifmt{1,3}, eval(p.trial.session.asciifmt{1,2}));

            for(i=2:Ndt)
                LNstr = sprintf(['%s  ', p.trial.session.asciifmt{i,3}] , LNstr, eval(p.trial.session.asciifmt{i,2}));
            end
            
            tblptr = fopen(p.trial.session.asciitbl , 'a');
            fprintf(tblptr, '%s \n', LNstr);
            fclose(tblptr);
        end
        
end


function cStr = Var2Str(varnm, frmt)
    eval(['cdt = ', varnm]);
    cStr = sprintf(frmt, cdt);

    