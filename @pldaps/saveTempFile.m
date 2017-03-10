function result = saveTempFile(p)
%saveTempFile    save the data from a single Trial to a file in a TEMP
%                folder
% result = saveTempFile(p)
result= [];

if(~p.trial.pldaps.nosave && p.trial.pldaps.save.trialTempfiles)
    
	evalc(['trial' num2str(p.trial.pldaps.iTrial) '= p.trial']);
        
    try  
        save(fullfile(p.defaultParameters.session.tmpdir, ...
                     [p.trial.session.file(1:end-4), num2str(p.trial.pldaps.iTrial), ...
                      p.trial.session.file(end-3:end)]),  ...
                     ['trial', num2str(p.trial.pldaps.iTrial)]);
    catch result
         warning('pldaps:saveTempFile','Failed to save temp file in %s',[p.trial.session.dir filesep 'TEMP'])
    end
end
