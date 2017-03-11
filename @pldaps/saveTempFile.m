function result = saveTempFile(p)
%saveTempFile    save the data from a single Trial to a file in a TEMP
%                folder
% result = saveTempFile(p)
result= [];

if(~p.trial.pldaps.nosave && p.trial.pldaps.save.trialTempfiles)
    
	evalc(['trial' num2str(p.trial.pldaps.iTrial) '= p.trial']);
        
    try  
        save(fullfile(p.defaultParameters.session.tmpdir, ...
                     [p.defaultParameters.session.filestem, '_T', num2str(p.trial.pldaps.iTrial, '%5.d'), '.pds']),  ...
                     ['trial', num2str(p.trial.pldaps.iTrial)]);
    catch result
         warning('pldaps:saveTempFile','Failed to save temp file in %s',[p.trial.session.dir filesep 'TEMP'])
    end
end
