function itrMat = ND_VectorCombinatoric(V1, V2)
% ND_VectorCombinatoric - a 2D matrix with all combination of elements if two vectors
%
% DESCRIPTION 
%   Generate a 2D matrix that contains all combinations of the two input vectors <V1> and <V2>
% 
% SYNTAX 
% itrMat = ND_VectorCombinatoric(V1, V2)
%
%   Input:
%         <V1,V2>  Input vectors
%
% wolf zinke, Dec 2017

itrMat = nan(length(V1)*length(V2), 2);

cnt = 0;
for(i=1:length(V1))
    for(j=1:length(V2))
        cnt = cnt + 1;
        itrMat(cnt,:) = [V1(i), V2(j)];
    end
end

