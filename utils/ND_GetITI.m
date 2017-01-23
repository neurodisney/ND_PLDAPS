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

        R = -mu*reallog((max_range-min_range)*rand(size(n))+minval);

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
        if(step==0)
            rfac = 1;
        else
            rfac = 1/step;
            step = 0;
        end
        diffval = (maxval - minval) * rfac;
        R = randi([0 diffval],size(n));

        R= R./rfac + minval;

    % --------------------------------------------------------------------%
    otherwise
      disp(['ERROR: Unknown method: ',rndmeth, '!']);
end

if(step > 0)
    R = round(R./step).*step;
end

