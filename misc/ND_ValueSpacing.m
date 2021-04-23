function Ovec = ND_ValueSpacing(From, To, Nele, Spacing)
% ND_HalfSpace - create a vector with a defined spacing between elements
%
% DESCRIPTION 
%   Creates a vector with <Nele> elements that range between <From> and <To>.
%   The spacing between elements is defined by the <Spacing> argument.
% 
% SYNTAX 
% Ovec = ND_HalfSpace(From, To, Nele)
%
%   Input:
%         <From>     Start value of the vector, has the shortest distance to the
%                    next value
%
%         <To>       End value of the vector, has the longest distance to the
%                    previous value
%        
%         <Nele>     Number of elements, length of output vector
%
%         <Spacing>  Function that defines the spacing between elements.
%                    Currently implemented are 'lin' [default], 'log', 'half'.
%                    If 'plot' is chosen it creates a figure giving
%                    examples of the spacing function.
%
% wolf zinke, Dec 2017

% ____________________________________________________________________________ %
%% define default parameters
if(~exist('From','var') || isempty(From))
   From = 1;
end

if(~exist('To','var'))
   To = [];
end

if(~exist('Nele','var') || isempty(Nele))
   Nele = 10;
elseif(Nele < 2)
    error('Seriously? Think again about what you are doing here!');
end

if(~exist('Spacing','var') || isempty(Spacing))
   Spacing = 'lin';
end

% ____________________________________________________________________________ %
%% call matlab functions
Ovec = [];

switch Spacing
    case 'lin'
        Ovec = ND_LinSpace(From, To, Nele);
    case 'log'
        Ovec = ND_LogSpace(From, To, Nele);
    case 'half'
        Ovec = ND_HalfSpace(From, To, Nele);
    case 'double'
         Ovec = ND_DoubleSpace(From, To, Nele);
    case 'plot'
        PlotSpacing(From, To, Nele);
    otherwise
        error('Spacing Function <%s> is unknown or NIY!', Spacing);
end

% ____________________________________________________________________________ %
%% plotting function

function PlotSpacing(From, To, Nele)

figure;
hold on

L1 = plot(ND_LinSpace(   From, To, Nele), '.-');
L2 = plot(ND_LogSpace(   From, To, Nele), '.-');
L3 = plot(ND_HalfSpace(  From, To, Nele), '.-');
L4 = plot(ND_DoubleSpace(From, To, Nele), '.-');

if(From < To)
    Lpos = 'northwest';
else
    Lpos = 'southwest';
end

lgd = legend([L1, L2, L3, L4], 'Linear', 'Log', 'Half', 'Double', 'Location', Lpos);
title(lgd,'Spacing Function')

xlabel('Vector Position')
ylabel('Element Value')
set(gca,'TickDir','out');
title('Comparison of the Different Spacing Functions');


