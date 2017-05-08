function result = saveTempFile(p)
%saveTempFile    save the data from a single Trial to a file in a TEMP
%                folder
% result = saveTempFile(p)
result= [];

if(~p.trial.pldaps.nosave && p.trial.pldaps.save.trialTempfiles)
    
	%evalc(['trial' num2str(p.trial.pldaps.iTrial) '= p.trial']);
    
    try  
        ctrial = p.trial;    
        save(fullfile(p.defaultParameters.session.tmpdir, ...
                     [p.defaultParameters.session.filestem, '_T', num2str(p.trial.pldaps.iTrial, '%.5d'), '.pds']),  ...
                     '-struct', 'ctrial');
    catch result
         warning('pldaps:saveTempFile','Failed to save temp file in %s', p.defaultParameters.session.tmpdir)
    end
end
