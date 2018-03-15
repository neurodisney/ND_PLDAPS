function rV = ND_RandSample(V, N, rnd)
% ND_RandSample - sample with replacement but maximize unique events
%
% DESCRIPTION 
%   Create a vector with <N> random samples from the input vector <V> and
%   minimize replication of the same values
% 
% SYNTAX 
% 	rV = ND_RandSample(V, N, mx)
%
%   Input:
%         <V>    Input vector 
%
%         <N>    Number of elements for output
%        
%         <rnd>  set to 1 if randomization with full replication is desired 
%                This will just call the datasample function.
%
% wolf zinke, Mar 2018


% ____________________________________________________________________________ %
%% define default parameters
if(~exist('V','var') || isempty(V))
   error('Specify the data that needs to be shuffled!');
end

if(~exist('N','var') || isempty(N))
   N = length(V);
end

if(~exist('rnd','var') || isempty(rnd))
   rnd = 0;
end

nV = length(V);

% ____________________________________________________________________________ %
%% shuffle input vector
if(rnd == 1)
    rV = V(randi(nV,1, N));
    
elseif(N <= nV)
    rV = V(randperm(nV, N)); 
else
    Nrep = floor(N/nV);
    
    rV = [];
    
    for(i=1:Nrep+1)
        if(i>Nrep)
            Nsmpl = N-length(rV);
        else
            Nsmpl = nV;
        end

        for(j=1:1000)
           csmpl = V(randperm(nV, Nsmpl));
            
            % quick and dirty hack to avoid duplicates at transitions
            if(i==1)
                break
            elseif(rV(end) ~= csmpl(1))
                break;
            end
        end
        
        rV = [rV, csmpl];

    end
end


