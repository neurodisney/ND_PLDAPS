function Ovec = ND_DoubleSpace(From, To, Nele)
% ND_HalfSpace - create a vector by doubling initial value
%
% DESCRIPTION 
%   Creates a vector of with values ranging between <From> and <To>
%   By taking the half distance between the first two elements until it 
%   has a length of <Nele> elements. 
% 
% SYNTAX 
% Ovec = ND_HalfSpace(From, To, Nele)
%
%   Input:
%         <From>  Start value of the vector, has the shortest distance to the
%                 next value
%
%         <To>    End value of the vector, has the longest distance to the
%                 previous value
%        
%         <Nele>  Number of elements, length of output vector
%
% wolf zinke, Dec 2017

% ____________________________________________________________________________ %
%% define default parameters
if(~exist('From','var') || isempty(From))
   From = 2;
end

if(~exist('To','var'))
   To = [];
end

if(~exist('Nele','var') || isempty(Nele))
   Nele = 10;
elseif(Nele < 2)
    error('Seriously? Think again about what you are doing here!');
end

% ____________________________________________________________________________ %
%% Init output vector
Ovec = nan(Nele,1);
Ovec(1) = From;

for(i=2:Nele)
    Ovec(i) = 2*Ovec(i-1);
end

if(~isempty(To))
    Ovec(Ovec>To) = [];
end

if(Ovec(end) < To)
    Ovec(end+1) = To;
end

