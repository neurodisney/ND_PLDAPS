function Ovec = ND_HalfSpace(From, To, Nele)
% ND_HalfSpace - create a vector by halfing spaces between elements
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
   From = 0;
end

if(~exist('To','var') || isempty(To))
   To = 10;
end

if(~exist('Nele','var') || isempty(Nele))
   Nele = 10;
elseif(Nele < 2)
    error('Seriously? Think again about what you are doing here!');
end

% ____________________________________________________________________________ %
%% Init output vector
Ovec = [From, To];

% ____________________________________________________________________________ %
%% Create the vector
while(length(Ovec) < Nele)
    Ovec = [Ovec(1), mean(Ovec(1:2)), Ovec(2:end)];
end

