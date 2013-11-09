%% Don't have statistics toolbox, so this is a rough implementation that
% should be comparable to the Matlab stats toolbox normpdf() function.
%
% ARGUMENTS:
%           X -- vector of points at which to evaluate the distribution
%           mu(default=0)    -- mean of the distribution
%           sigma(default=1) -- standard deviation of the distribution
%
% OUTPUT: 
%           G -- Normal probability distribution function evaluated at the  
%                points specified by X, normailised to unit area.
%
% USAGE:
%{
      X = -5:0.1:5; %For default call, spans 5 standard deviations of the pdf both above and below the mean. 
      G = NormPDF(X);
      figure, plot(X,G)
%}
%
% MODIFICATION HISTORY:
%     SAK(09-09-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function G = NormPDF(X,mu,sigma)
%% Set defaults if all arguments not supplied...
 if nargin < 2,
   mu = 0;      % default to mean zero
 end
 if nargin < 3,
   sigma = 1;   % default to standard deviation 1
 end

%% 
%Normal pdf at requested 
 G = exp(-(X-mu).^2 / (2*sigma^2))./(sigma*2*pi);
 
%Normalise to unit area
 G = G / trapz(X, G);

%% 

end %function NormPDF()
