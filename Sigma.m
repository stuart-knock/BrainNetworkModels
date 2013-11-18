%% Returns either sigma function, its inverse, or its derivative. 
%
% ARGUMENTS:
%         V     -- Vector of values at which we want to evaluate function. 
%         Qmax  -- Peak value
%         Theta -- Midpoint of transition
%         sigma -- width of transition
%         Variant -- '' || 'inverse' || 'derivative'
%
% OUTPUT: 
%         S -- The 'Variant' of the sigma function evaluated at 'V'
%
% REQUIRES:
%        none
%
% USAGE:
%{
      N = 100;
      SigmaFunction = sigma(Sigma((0:N)./N));
      figure, plot(0:(1./N):1, SigmaFunction); 
%}
%
% MODIFICATION HISTORY:
%     SAK(17-11-2009) -- Original.
%     SAK(04-12-2009) -- Added inverse...
%     SAK(05-01-2010) -- Added derivative...
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function S = Sigma(V,Qmax,Theta,sigma,Variant)
  if nargin<5,
    Variant = '';
  end
  if nargin<4,
     Theta = 2^-1;
  end
  if nargin<3,
    sigma = 2^-3;
  end
  if nargin<2,
    Qmax = 1;
  end

  PiOnSqrt3 = 1.813799364234217836866491779801435768604278564;
%                              ^?
  S = inf(size(V));
  switch lower(Variant),
    case{''}
      S = Qmax ./ (1 + exp(-PiOnSqrt3.*((V-Theta)./sigma)));
    case {'inverse'},
      S(Qmax-V>0) = Theta + (sigma./PiOnSqrt3) .* log(V(Qmax-V>0)./(Qmax-V(Qmax-V>0)));
    case{'derivative'}
      w = exp(-PiOnSqrt3.*((V-Theta)./sigma));
      S = (PiOnSqrt3.*Qmax./sigma) .* w ./ ((1+w).*(1+w));
    otherwise
      error(['BrainNetworkModels:' mfilename ':UnknownVariant'],'Unknown variant of the sigma function requested...');
  end
    
end %function Sigma()
