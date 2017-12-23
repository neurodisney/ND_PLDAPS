function Ovec = ND_LogSpace(From, To, Nele)
% ND_HalfSpace - create a vector with a log spacing between elements
%
% DESCRIPTION 
%   Creates a vector with <Nele> elements of with values ranging 
%   between <From> and <To> by calling Matlab's logspace function. This is
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
   From = 1;
end

if(~exist('To','var') || isempty(To))
   To = 10;
end

if(To == 0 || From == 0)
    CorrZero = 0.0000001;
else
    CorrZero = 0;
end

if(~exist('Nele','var') || isempty(Nele))
   Nele = 10;
elseif(Nele < 2)
    error('Seriously? Think again about what you are doing here!');
end

% ____________________________________________________________________________ %
%% call matlab function
Ovec = logspace(log10(From+CorrZero), log10(To+CorrZero), Nele) - CorrZero;

if(From > To)
    Ovec = flip(From -(Ovec - To));
end


