function saveSession(p)
% saveSession    save the data from the current session
%                
% moved here from the run function

%% save online plot
if(p.defaultParameters.plot.do_online)
    p.defaultParameters.plot.fig = []; % avoid saving the figure to data
    hgexport(gcf, [p.defaultParameters.session.filestem, '.pdf'], hgexport('factorystyle'), 'Format', 'pdf');
end

%% save data as pds file
if(~p.defaultParameters.pldaps.nosave)
    [structs,structNames] = p.defaultParameters.getAllStructs();

    PDS = struct;
    PDS.initialParameters     = structs(levelsPreTrials);
    PDS.initialParameterNames = structNames(levelsPreTrials);

    if(p.defaultParameters.pldaps.save.initialParametersMerged)
        PDS.initialParametersMerged=mergeToSingleStruct(p.defaultParameters); %too redundant?
    end

    levelsCondition = 1:length(structs);
    levelsCondition(ismember(levelsCondition,levelsPreTrials)) = [];

    PDS.conditions = structs(levelsCondition);
    PDS.conditionNames = structNames(levelsCondition);
    PDS.data = p.data;
    PDS.functionHandles = p.functionHandles;

    if p.defaultParameters.pldaps.save.v73
        save(p.defaultParameters.session.file,'-mat','-v7.3')
    else
        save(p.defaultParameters.session.file,'-mat')
    end
end
    