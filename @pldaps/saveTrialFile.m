function result = saveTrialFile(p)
%saveTrialFile    save the data from a single Trial to a file in a Trial data folder
% result = saveTrialFile(p)
result= [];

if(~p.trial.pldaps.nosave)
    try
        ctrial = p.trial;

        if(p.trial.pldaps.iTrial == 0)
            flnm = [p.defaultParameters.session.filestem, '_InitialDefaultParameters.pds'];
        else
            flnm = [p.defaultParameters.session.filestem, '_T', num2str(p.trial.pldaps.iTrial, '%.5d'), '.pds'];
        end

        save(fullfile(p.defaultParameters.session.trialdir, flnm), '-struct', 'ctrial','-mat','-v7.3');
        
    catch result
         warning('pldaps:saveTrialFile','Failed to save temp file in %s', p.defaultParameters.session.trialdir)
    end
end