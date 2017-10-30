function [congruent, nonmatch1, nonmatch2] = ND_CompareStructs(struct1, struct2)
% Compare two structures for differences between them
% Any matching fields will be removed returning only differences between the two
% in nonmatch1 and nonmatch2
% If all fields match, then congruent will be set to true and nonmatch1 = nonmatch2 = empty-struct

if ~isstruct(struct1) || ~isstruct(struct2)
    % If either one of the inputs is not a structure, then the bottom of the tree has been reached
    % Check for equality
    if isequaln(struct1, struct2)
        congruent = true;
        nonmatch1 = struct;
        nonmatch2 = struct;
    else
        congruent = false;
        nonmatch1 = struct1;
        nonmatch2 = struct2;
    end
    
else
    % Assume congruency at begining
    congruent = true;
    nonmatch1 = struct;
    nonmatch2 = struct;
    
    % Get top level fields in the structs
    allFields = union(fields(struct1), fields(struct2));
    nFields = length(allFields);
    
    % Now iterate through the fields and recursively call this function to check for equality
    for iField = 1:nFields
        field = allFields{iField};
        
        % Check if either struct doesn't contain this particular field
        if ~isfield(struct1, field)
            congruent = false;
            nonmatch1.(field) = 'DOES NOT EXIST';
            nonmatch2.(field) = struct2.(field);
            continue;
            
        elseif ~isfield(struct2, field)
            congruent = false;
            nonmatch1.(field) = struct1.(field);
            nonmatch2.(field) = 'DOES NOT EXIST';
            continue;
            
        end
        
        [subcon, sub1, sub2] = ND_CompareStructs(struct1.(field), struct2.(field));
        
        % If there is a mismatch deeper in the tree, report it
        if ~subcon
            congruent = false;
            nonmatch1.(field) = sub1;
            nonmatch2.(field) = sub2;
        end
        
    end
end
    
    
    
    