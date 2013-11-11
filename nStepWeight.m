%% Infinite Steps connection strength:
%
% Return the multiple step connection strength, in absence of time delay
% this is the correct matrix to consider when looking at region
% interactions. Should extend to return cumulative time delay, plot
% multi step weight contributions vs multistep delays => temporal response
% of region???
%
% ARGUMENTS:
%        X -- weights matrix
%        tolerance -- Contribution of subsequent steps below which we'll
%                     consider ourselves "close enough".
%        max_steps -- a fixed upper limit on the number of steps taken.
%
% OUTPUT: 
%        nX -- The n-steps weight matrix
%        steps -- how many steps we took
%
% REQUIRES: 
%        none
%
% USAGE:
%{
    Connectivity.WhichMatrix = 'RM_AC';
    Connectivity = GetConnectivity(Connectivity);
    X = Connectivity.weights / max(sum(Connectivity.weights, 2));
    [nX, steps] = nStepWeight(X);

    figure, imagesc(X); daspect([1 1 1]); title('Original'); colorbar
    figure, imagesc(nX); daspect([1 1 1]); title('n-step'); colorbar
%}
%

%TODO: Consider including optional normalisation...

function [nX, steps] = nStepWeight(X, tolerance, max_steps)
  if nargin < 2,
    tolerance = 2^-18;
  end
  if nargin < 3,
    max_steps = Inf;
  end

  %Guestimate criterion, needs validation...
  if max(sum(X, 2)) >= 1.0,
    msg = 'Welcome to the infinite loop...';
    warning(['BrainNetworkModels:' mfilename ':InfLoop'], msg)
    if max_steps == Inf,
      msg = 'You''ll need to specify a finite max_steps... bailing.';
      error(['BrainNetworkModels:' mfilename ':InfLoop'], msg)
    end
  end

  % Sum of product for multiple steps...
  nX = X;
  next_step = X;
  steps = 1;
  while (steps < max_steps) && (max(next_step(:)) > tolerance),
    steps = steps + 1;
    next_step = next_step * X;
    nX = nX + next_step;
  end
  
end %function nStepsWeight()
