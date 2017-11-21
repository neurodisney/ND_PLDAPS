function new_dp = ND_AlterSubStruct(dp, c)
% Recurses through all the subfields in c to modify specific subparts of dp
% This allows selective modifications of a struct via another struct.
%
% Originally designed to modify the defaultParameters struct for individual conditions
% Nate Faber, Oct 2017


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
      
        if isfield(dp, field)
            dp.(field) = ND_AlterSubStruct(dp.(field), c.(field));
        else
            % If this branch doesn't exist create it in dp
            dp.(field) = c.(field);
        end
    end
    
    % Now return dp with all the appropriate subfields changed
    new_dp = dp;
    
end