%% Merge two structures containing fixed points of the dynamics into a single structure.
% By default only keeping values that are further apart than ErrorTolerance. 
%
% ARGUMENTS:
%        FxdPtsIn1 -- A structure containing cell arrays of extrema.
%        FxdPtsIn2 -- A structure containing cell arrays of extrema.
%        ErrorTolerance -- points further apart than this can be considered
%                unique, closer and they're merged into a single point.
%        OnlyUnique -- If true, return only the unique set between FxdPtsIn1
%                and FxdPtsIn2
%
% OUTPUT: 
%        FxdPtsOut -- structure containing the merged extrema of the two inputs.
%
% REQUIRES: 
%        MergeExtrema() -- Merge two cell arrays containing extrema.
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


function FxdPtsOut = MergeBifStructure(FxdPtsIn1, FxdPtsIn2, ErrorTolerance, OnlyUnique)
  % Set defaults for any optional arguments that weren't specified
  if nargin < 3,
    ErrorTolerance = 1.000e-4;  
  end
  
  if nargin < 4,
    OnlyUnique = 1;
  end
 
  % Count some things...
  StateVariables = fieldnames(FxdPtsIn1);
  NumberOfStateVariables = length(StateVariables);
  [NumberOfNodes NumberOfModes MaxBifSteps] = size(FxdPtsIn1.(StateVariables{1}));

  % Combine the two structures containing fixed points of the dynamics. 
  ThisBifStepFxdpts1 = cell(NumberOfNodes,NumberOfModes,NumberOfStateVariables);
  ThisBifStepFxdpts2 = cell(NumberOfNodes,NumberOfModes,NumberOfStateVariables);
  for cbs = 1:MaxBifSteps,
    %Map this bifurcation value from the structure to a cell array
    for n = 1:NumberOfNodes,
       for m = 1:NumberOfModes,
        for tsv = 1:NumberOfStateVariables,
          ThisBifStepFxdpts1{n,m,tsv} = FxdPtsIn1.(StateVariables{tsv}){n,m,cbs};
          ThisBifStepFxdpts2{n,m,tsv} = FxdPtsIn2.(StateVariables{tsv}){n,m,cbs};
        end
      end
    end
%%%keyboard
    MergedFxdPts = MergeExtrema(ThisBifStepFxdpts1, ThisBifStepFxdpts2, ErrorTolerance, OnlyUnique);
    
    for n = 1:NumberOfNodes,
      for m = 1:NumberOfModes,
        for tsv = 1:NumberOfStateVariables,
          FxdPtsOut.(StateVariables{tsv}){n,m,cbs} = MergedFxdPts{n,m,tsv};
        end
      end
    end
  end


% % %  for tsv = 1:NumberOfStateVariables,
% % %    for n = 1:NumberOfNodes,
% % %      for tm = 1:NumberOfModes,
% % %        for cbs = 1:MaxBifSteps,
% % %          if OnlyUnique, %average over fixed points that are continuously(rel. ErrorTolerance) separated. 
% % % %%%keyboard
% % %            Extrema = [FxdPtsIn1.(StateVariables{tsv}){n,tm,cbs} FxdPtsIn2.(StateVariables{tsv}){n,tm,cbs}];
% % %            sExtrema = sort(Extrema,2); 
% % %            ExtremaBoundaries = [0 find([((sExtrema(2:end)-sExtrema(1:end-1)) > ErrorTolerance) true])]; %find jumps greater than ErrorTolerance 
% % %            FxdPtsOut.(StateVariables{tsv}){n,tm,cbs} = zeros(1,length(ExtremaBoundaries)-1);
% % %            for j=1:(length(ExtremaBoundaries)-1),
% % %              FxdPtsOut.(StateVariables{tsv}){n,tm,cbs}(1,j) = mean(sExtrema((ExtremaBoundaries(j)+1):ExtremaBoundaries(j+1)),2);
% % %            end
% % %          else %just combine them into one big structure...
% % %            FxdPtsOut.(StateVariables{tsv}){n,tm,cbs} = [FxdPtsIn1.(StateVariables{tsv}){n,tm,cbs} FxdPtsIn2.(StateVariables{tsv}){n,tm,cbs}];
% % %          end
% % %        end
% % %      end
% % %    end
% % %  end
 
%% 

end %function MergeBifStructure()
