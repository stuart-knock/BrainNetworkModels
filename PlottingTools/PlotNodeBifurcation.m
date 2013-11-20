%% Plot Node-wise "bifurcation" diagrams
% 
% NOTE: IN OCTAVE, THIS IS EXCRUCIATINGLY SLOW(GNUPLOT), AND NOT REALLY FUNCTIONAL(FLTK)...
%       BEST TO USE GNUPLOT AND SET options.Plotting.OnlyNodes TO A SMALL SET...
%
% ARGUMENTS:
%           UniqueExtrema -- 
%           options -- 
%   options.BifurcationOptions -- same as fhn_net_rk, plus:
%                             .MaxContinuations -- number of times to run the 
%                                                  integration fhn_net_rk in
%                                                  search of asymptotically stable
%                                                  behaviour...
%                             .ErrorTolerance   -- Value below which peak to peak
%                                                  variability must be for us to
%                                                  consider it "Stable behaviour"
%                             .BifurcationParameter    -- 
%                             .BifurcationParameterIncrement    --  
%                             .TargetControlValue
%                      
%
% OUTPUT: 
%          
%          FigureHandles -- cell array of figure handles, there is one figure
%                           produced per state-variable.
%
%
% REQUIRES: 
%          none
%
%
% USAGE:
%{
    % Run one of the bifurcation demo scripts then:
    %Just pick a few nodes
    options.Plotting.OnlyNodes = {'FEF', 'PFCORB', 'V1', 'V2'};
    % plot them
    FigureHandles = PlotNodeBifurcation(ForwardFxdPts, options)
    %Optionally over plot the Extrema found by back tracking
    options.Plotting.FigureHandles = FigureHandles;
    FigureHandles = PlotNodeBifurcation(BackwardFxdPts, options)
%}
%
% MODIFICATION HISTORY:
%     SAK(21-09-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function FigureHandles = PlotNodeBifurcation(UniqueExtrema, options)

  [NumberOfNodes NumberOfModes NumberOfbifurcationSteps] = size(UniqueExtrema.(options.Dynamics.StateVariables{1}));
 
  %Plot only a subset of nodes if specified...
  if isfield(options, 'Plotting') && isfield(options.Plotting, 'OnlyNodes'),
    NumberOfNodes = length(options.Plotting.OnlyNodes);
    TheseNodes = zeros(1, NumberOfNodes);
    for n = 1:NumberOfNodes,
      TheseNodes(1,n) = find(strcmp(options.Plotting.OnlyNodes{n}, options.Connectivity.NodeStr));
    end
  else
    if NumberOfNodes > 38,
      warning(['BrainNetworkModels:PlottingTools:' mfilename ':TooManyNodes'], 'Plotting so many nodes at once doesn''t work well. Try setting options.PlotOnlyNode...');
    end
    TheseNodes = 1:NumberOfNodes;
  end
  
  NumberOfRows = floor(sqrt(NumberOfNodes));
  NumberOfColumns = ceil(sqrt(NumberOfNodes));
  if (NumberOfRows*NumberOfColumns < NumberOfNodes),
    NumberOfColumns = NumberOfColumns+1;
  end
  
  %If plotting forward then backward: Fwd => '+'; Bckwd => 'x'; overlapping => '*'
  if isfield(options, 'Plotting') && isfield(options.Plotting, 'FigureHandles'),
    glyph = 'x';
  else
    glyph = '+';
  end
  
  %
  for tsv = 1:length(options.Dynamics.StateVariables),
    LowerBound = min([UniqueExtrema.(options.Dynamics.StateVariables{tsv}){:}]);
    UpperBound = max([UniqueExtrema.(options.Dynamics.StateVariables{tsv}){:}]);
    %
    if isfield(options, 'Plotting') && isfield(options.Plotting, 'FigureHandles'),
      FigureHandles{tsv} = figure(options.Plotting.FigureHandles{tsv}); %
    else
      FigureHandles{tsv} = figure('Name', options.Dynamics.StateVariables{tsv});
    end
    
    for n=1:NumberOfNodes,
      subplot(NumberOfRows, NumberOfColumns, n), hold on
      for tm = 1:NumberOfModes,
        BifV = cell2mat(squeeze(UniqueExtrema.(options.Dynamics.StateVariables{tsv})(TheseNodes(n),tm,:)).');
        c = [];
        for j = 1:NumberOfbifurcationSteps,
          c = [c (options.Bifurcation.InitialControlValue+(j-1)*options.Bifurcation.BifurcationParameterIncrement)*ones(1,length(UniqueExtrema.(options.Dynamics.StateVariables{tsv}){TheseNodes(n),tm,j}))];
        end
        plot(c, BifV, glyph, 'markersize', 2), hold all
      end
      if ((options.Bifurcation.TargetControlValue-options.Bifurcation.InitialControlValue)>0) && ((UpperBound-LowerBound)>0),
        axis([options.Bifurcation.InitialControlValue options.Bifurcation.TargetControlValue LowerBound UpperBound]),%
      end
      title(options.Connectivity.NodeStr{TheseNodes(n)})
      if (NumberOfNodes-TheseNodes(n))<NumberOfColumns,
        set(gca,'xtickMode', 'auto')
        xlabel(options.Bifurcation.BifurcationParameter);
      else
        set(gca,'xtick',[])
      end
      if ~mod((n-1),NumberOfColumns),
        set(gca,'ytickMode', 'auto')
        ylabel(options.Dynamics.StateVariables{tsv});
      else
        set(gca,'ytick',[])
      end
      hold off
    end
  end

end % function PlotNodeBifurcation()
