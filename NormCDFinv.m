%% Inverse cumulative distribution function for the Normal distribution.
% Analytic equivalent of sorting a realisation of N Normally distributed
% random variables.
%
% ARGUMENTS:
%           X -- vector of points at which to evaluate the distribution (0-1)
%           mu(default=0)    -- mean of the distribution
%           sigma(default=1) -- standard deviation of the distribution
%
% OUTPUT: 
%           G -- Inverse CDF for a Normal probability distribution function
%                evaluated at the points specified by X, normailised to unit area.
%
% USAGE:
%{
      N = 200;
      step = (1-(1/N))/N
      X = step:step:(1-step); %
      G = NormCDFinv(X);
      figure, plot(X,G)
%}
%
% MODIFICATION HISTORY:
%     SAK(09-09-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CDFinv = NormCDFinv(X,mu,sigma)
  % Set defaults if all arguments not supplied...
  if nargin < 2,
    mu = 0;      % default to mean zero
  end
  if nargin < 3,
    sigma = 1;   % default to standard deviation 1
  end
  
  %
  CDFinv = mu + sigma*sqrt(2)*erfinv(2*X-1);

end %function NormCDFinv()
