function R = ND_GetITI(minval, maxval, rndmeth, mu, n, step)
% Create a vector of n numbers following a random distribution specified by rndmeth with a mean at mu.
% The range of random numbers could be restricted to a lower and upper bound by minval and maxval.
% If step is specified, resulting numbers are no longer continuous, but show a minimum difference of step.
%
%
%
% wolf zinke, Jan. 2017

%% define defaults
if ( ~exist('n','var') || isempty(n))
    n = 1;
elseif(numel(n) == 1 && n > 1)
    n = ones(n,1);
end

if (~exist('minval','var') || isempty(minval))
    minval = 0;
end

if(~exist('maxval','var') || isempty(maxval))
    maxval = 10;
end

if (~exist('mu','var') || isempty(mu))
    mu = (maxval + minval) /2;
end

if(~exist('rndmeth','var') || isempty(rndmeth))
    rndmeth = 'uni';
end

if(~exist('step','var') || isempty(step))
    step = 0;
end

%% check arguments

if (mu > maxval)
    error('Maximum ITI tme can not exceed mean ITI time!');
end

if (mu < minval)
    error('Minimum ITI tme can not exceed mean ITI time!');
end
mu = mu - minval;

%% get values
if(minval == maxval)
    R = maxval;
    return;
end

switch lower(rndmeth)
    % --------------------------------------------------------------------%
    %% exponential
    case 'exp'
        max_range = exp(-(minval/mu));
        min_range = exp(-(maxval/mu));

        R = -mu * reallog((max_range-min_range) * rand(size(n))+minval);

    % --------------------------------------------------------------------%
    %% chi-sqiuare
    case 'chi' % See Hagberg et al, NeuroImage 2001

        R = pptb_randChi2(mu, size(n)) + minval;
        pos = find(R > maxval);

        for(i=1:length(pos))
            while(R(pos) > maxval)
                R(pos) = pptb_randChi2(mu,1,1) + minval;
            end
        end

    % --------------------------------------------------------------------%
    %% gamma
    case 'gamma'
       R = randg(mu,size(n)) + minval;
       pos = find(R > maxval);

        for(i=1:length(pos))
            while(R(pos) > maxval)
                R(pos) = randg(mu,1,1) + minval;
            end
        end

    % --------------------------------------------------------------------%
    %% poisson
    case  'poisson'
        if(step==0)
            rfac = 1;
        else
            rfac = 1/step;
            step = 0;
        end
       R = poissrnd(rfac*mu,size(n));
       pos = find(R > maxval);

        for(i=1:length(pos))
            while(R(pos) > maxval)
                R(pos) = poissrnd(rfac*mu,1,1);
            end
        end

        R = R./rfac + minval;

    % --------------------------------------------------------------------%
    %% uniform
    case 'uni'
        R = randrng(size(n), minval, maxval);

    % --------------------------------------------------------------------%
    otherwise
      disp(['ERROR: Unknown method: ',rndmeth, '!']);
end


%% discretize values
if(step > 0)
    R = round(R./step).*step;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = randrng(n,m, x)
%% draw random uniform number within a given range

rng = x-m;

r = m + (rand(n) .* rng);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function R = pptb_randChi2(mu, n, n2)
%% 

if (exist('n2','var') == 1)
    n = [n,n2];
elseif (exist('n','var') == 0)
    n = ones(1,1);
elseif(isempty(n) == 1)
    n = ones(1,1);
elseif(numel(n) == 1 && n > 1)
    n = ones(n,1);
end

R = rchisq(n,mu);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = rchisq(n, a)
%% Random numbers from the chisquare distribution
%
%         x = rchisq(n,DegreesOfFreedom)

%        Anders Holtsberg, 18-11-93
%        Copyright (c) Anders Holtsberg

if any(any(a<=0))
   error('DegreesOfFreedom is wrong')
end

x = rgamma(n,a*0.5)*2;


function x = rgamma(nn, a)
% Random numbers from the gamma distribution
%
%         x = rgamma(n,a)

% GNU Public Licence Copyright (c) Anders Holtsberg 10-05-2000.

% This consumes about a third of the execution time compared to 
% the Mathworks function GAMRND in a third the number of
% codelines. Yihaaa! (But it does not work with different parameters)
%
% The algorithm is a rejection method. The logarithm of the gamma 
% variable is simulated by dominating it with a double exponential.
% The proof is easy since the log density is convex!
% 


if any(any(a<=0))
   error('Parameter a is wrong')
end

n = prod(nn);
if length(nn) == 1
   nn(2) = 1;
end

y0 = log(a)-1/sqrt(a);
c = a - exp(y0);
m = ceil(n*(1.7 + 0.6*(min(min(a))<2)));

y = log(rand(m,1)).*sign(rand(m,1)-0.5)/c + log(a);
f = a*y-exp(y) - (a*y0 - exp(y0));
g = c*(abs((y0-log(a))) - abs(y-log(a)));
reject = (log(rand(m,1)) + g) > f;
y(reject) = [];
if length(y) >= n
   x = exp(y(1:n));
else
   x = [exp(y); rgamma(n - length(y), a)];
end
x = reshape(x, n/nn(2), nn(2));
