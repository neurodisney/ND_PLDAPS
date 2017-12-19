function Ovec = ND_LinSpace(From, To, Nele)
% ND_HalfSpace - create a vector with equal spacing between elements
%
% DESCRIPTION 
%   Creates a vector with <Nele> elements equally spaced between the range 
%   of <From> and <To> by calling Matlab's linspace function. This is
%   a convenience wrapper to ensure consistency in function arguments.
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
%% call matlab function
Ovec = linspace(From, To, Nele);



