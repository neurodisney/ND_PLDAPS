function subfields = searchForFigure(s)
% Searches for a figure in struct s

allFields = fields(s);
nFields = length(allFields);

% Store subfields that are figures in cell aray
subfields = {};

if length(s) > 1
    return
end

for i=1:nFields
    thisField = allFields{i};
    
    switch class(s.(thisField))
        
        case 'struct'
            % Recurse
            disp(['searching ' thisField])
            subsubfields = searchForFigure(s.(thisField));
            if ~isempty(subsubfields)
                for j=1:length(subsubfields)
                    subfields{end+1} = [thisField '.' subsubfields{j}];
                end
            end
            
        case {'matlab.ui.Figure','Figure'}
            % Return this
            subfields{end+1} = thisField;
            
        otherwise
            % ignore everything else
            
    end
end
