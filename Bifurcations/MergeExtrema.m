%% Merge two cell arrays containing extrema of the dynamics.
% By default only keeping values that are further apart than ErrorTolerance.
%
% ARGUMENTS:
%        FxdPtsIn1 -- A cell array of extrema.
%        FxdPtsIn2 -- A cell array of extrema.
%        ErrorTolerance -- points further apart than this can be considered
%                unique, closer and they're merged into a single point.
%        OnlyUnique -- If true, return only the unique set between FxdPtsIn1
%                and FxdPtsIn2
%
% OUTPUT: 
%        FxdPtsOut -- the merged extrema of the two inputs.
%
% REQUIRES: 
%        none
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(29-09-2009) -- Original.
%     SAK(04-11-2009) -- modified for general use and naming consistency.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function FxdPtsOut = MergeExtrema(FxdPtsIn1, FxdPtsIn2, ErrorTolerance, OnlyUnique)
  % Set defaults for any optional arguments that weren't specified
  if nargin < 3,
    ErrorTolerance = 1.000e-4;  
  end
  
  if nargin < 4,
    OnlyUnique = 1;
  end
  
  % Count some things and create cell array for output...
  [NumberOfNodes NumberOfModes NumberOfStateVariables] = size(FxdPtsIn1);
  FxdPtsOut = cell(NumberOfNodes, NumberOfModes, NumberOfStateVariables);
  
  % Combine the two structures containing fixed points of the dynamics. 
  for n = 1:NumberOfNodes,
    for tm = 1:NumberOfModes,
      for tsv = 1:NumberOfStateVariables,
        if OnlyUnique, %average over fixed points that are continuously(rel. ErrorTolerance) separated.
%%%keyboard
          Extrema = [FxdPtsIn1{n,tm,tsv} FxdPtsIn2{n,tm,tsv}];
          sExtrema = sort(Extrema,2);
          ExtremaBoundaries = [0 find([((sExtrema(2:end)-sExtrema(1:end-1)) > ErrorTolerance) true])]; %find jumps greater than ErrorTolerance
          FxdPtsOut{n,tm,tsv} = zeros(1,length(ExtremaBoundaries)-1);
          for j=1:(length(ExtremaBoundaries)-1),
            try
              FxdPtsOut{n,tm,tsv}(1,j) = mean(sExtrema((ExtremaBoundaries(j)+1):ExtremaBoundaries(j+1)),2);
            catch ME
              keyboard
            end
          end
        else %just combine them into one big structure...
          FxdPtsOut{n,tm,tsv} = [FxdPtsIn1{n,tm,tsv} FxdPtsIn2{n,tm,tsv}];
        end
      end
    end
  end

end %function MergeExtrema()
