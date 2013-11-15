%% Find the amplitude of extrema(maxima, minima, points-of-inflexion),
% useful for limit-cycle ie repetative behaviour...
%
% ARGUMENTS:
%           X(NumberOfTimePoints, N, NumberOfModes) -- <description>
%           ErrorTolerance -- <description>
%
% OUTPUT: 
%           UniqueExtrema -- <description>
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(25-09-2009) -- Original.
%     SAK(28-09-2009) -- replaced binnig via rescale and unique with
%                        iterative solution, which avoids occasional bin
%                        misallignment problems...
%     SAK(22-10-2009) -- Fixed bug where change of slope always ran over
%                        two data points, leading to the possibility of no 
%                        extrema being found.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [varargout] = FindUniqueExtrema(X,ErrorTolerance)
%% Set defaults for any optional arguments that weren't specified
 if nargin < 2,
   ErrorTolerance = 1e-3;
 end
 
 [NumberOfTimePoints NumberOfNodes NumberOfModes] = size(X);

%% 
 ixV = false([NumberOfTimePoints NumberOfNodes NumberOfModes]);
 sdV = sign(X(2:end, :, :) - X(1:(end-1), :, :));             %sign of the 1-step difference
 ixV(2:end-1,:,:) = (sdV(1:end-1, :, :) ~= sdV(2:end, : ,:)); %zero crossings of sdV (ie maxima|minima|inflexions)
 varargout = cell(NumberOfNodes,NumberOfModes);
 for n = 1:NumberOfNodes,
   for tm = 1:NumberOfModes,
     Extrema = X(ixV(:,n,tm),n,tm).';
     if isempty(Extrema),
       varargout{n,tm}(1,1) = X(42,n,tm);
     else
       sExtrema = sort(Extrema,2);
       ExtremaBoundaries = [0 find([((sExtrema(2:end)-sExtrema(1:end-1)) > ErrorTolerance) true])];
       varargout{n,tm} = zeros(1,length(ExtremaBoundaries)-1);
       for j=1:(length(ExtremaBoundaries)-1),
%        try
         varargout{n,tm}(1,j) = mean(sExtrema((ExtremaBoundaries(j)+1):ExtremaBoundaries(j+1)));
%        catch ME
%          figure,
%          plot(X(:,1))
%          hold on
%          plot(find(ixV(:,1)),X(ixV(:,1),1),'r*')
%          keyboard
%        end
       end
     end
   end
 end
%%%keyboard 
%% 

end %function FindUniqueExtrema()
