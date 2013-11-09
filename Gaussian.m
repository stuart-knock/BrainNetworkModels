%% Evaluates Gaussian or normal distribution function
%
% ARGUMENTS:
%            X -- point or vector of points at which to evaluate the
%                 function
%            Sigma -- standard deviation: defaults to 1
%            Amplitude -- of distribution peak: defaults to give unit area under curve
%
% OUTPUT: 
%           X -- function evaluated at arg 'X'
%
% REQUIRES:
%          none
%
% USAGE:
%{
      X=-3:0.1:3;
      g=Gaussian(X);
      figure, plot(X,g)
%}
%
% MODIFICATION HISTORY:
%     SAK(16-03-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function X=Gaussian(X, Sigma, Amplitude)
%% Set any argument that weren't specified
 if nargin < 2,
   Sigma = 1; %standard deviation 
 end
 if nargin < 3,
   Amplitude = 1./sqrt(2*pi*Sigma.^2); %Normalise to unit area
 end
 
%%
  X = Amplitude.*exp(-(X.^2)./(2*Sigma.^2));

%% 

end %function Gaussian()