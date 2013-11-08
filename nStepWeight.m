%% Infinite Steps connection strength:
%
% Return the multiple step connection strength, in absence of time delay
% this is the correct matrix to consider when looking at region
% interactions. Should extend to return cumulative time delay, plot
% multi step weight contributions vs multistep delays => temporal response
% of region???
%
%
%

function [nX, steps] = nStepWeight(X, tolerance, max_steps)
  if nargin < 2,
    tolerance = 2^-18;
  end
  if nargin < 3,
    max_steps = Inf;
  end

  %Guestimate criterion, needs validation...
  if max(sum(X, 2)) >= 1.0,
    disp('Welcome to the infinite loop...')
    if max_steps == Inf,
      disp('You''ll need to specify a finite max_steps... bailing.')
      return
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
