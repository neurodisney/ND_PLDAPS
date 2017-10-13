function p = ND_LoadCondition(p)
% Iterate through the condition struct for the current trial and change all
% corresponding parameters in defaultParameters

% Nate Faber, Oct 2017
iTrial = p.defaultParameters.pldaps.iTrial;
cond = p.conditions{iTrial};

p.defaultParameters = alterSubStruct(p.defaultParameters, cond);

function new_dp = alterSubStruct(dp, c)
% Recurses through all the subfields in c to modify specific subparts of dp

if ~isstruct(c)
    % if c is not a struct, then reached the bottom of the recursive tree
    % and the value needs to be changed. Reassign dp to be c
    new_dp = c;
 
else
    % If c is a struct, then iterate through all the fields explore further
    % the struct tree
    
    % Get the top level fields in the condition that need to be changed
    allFields = fields(c);
    nFields = length(allFields);
    
    % Iterate through, and call alterSubStruct recursively.
    for iField = 1:nFields
        field = allFields{iField};
        dp.(field) = alterSubStruct(dp.(field), c.(field));
    end
    
    % Now return dp with all the appropriate subfields changed
    new_dp = dp;
    
end
    