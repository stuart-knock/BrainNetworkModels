%% Create plot of time-series, with vertical space between lines, one window 
% for each mode, like typical EEG view.
%
% ARGUMENTS:
%           TimeSeries -- As output from a simulation, ie with 
%                         shape = [tpts, nodes, modes]
%           time -- vector of time values, with length = tpts
%           labels -- node labels, eg options.Connectivity.NodeStr 
%
% OUTPUT: 
%           figure_handles -- cell array of figure handles.
%
% USAGE:
%{
      %Having run, for example, reduced_fhn_demo:
      PlotTimeSeries(store_Alfa, store_t, options.Connectivity.NodeStr)
%}
%
% MODIFICATION HISTORY:
%     SAK(16-02-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function figure_handles = PlotTimeSeries(TimeSeries, time, labels)

 ThisStateVariable = inputname(1);
 [TimeSteps NumberOfNodes NumberOfModes ] = size(TimeSeries);
 
 if nargin < 2,
   time = 1:TimeSteps;
 else
   if length(time) == 1, % assume it's dt
     time = time .* (1:TimeSteps);
   end
 end
 
 if nargin < 3,
   labels = {};
 end
 
 SeparateBy = zeros(1,NumberOfModes);
 for nom=1:NumberOfModes,
   TimeSeries(:,:,nom) = detrend(TimeSeries(:,:,nom));
   SeparateBy(1,nom) = 0.42*(max(max(TimeSeries(:,:,nom))) - min(min(TimeSeries(:,:,nom))));
 end


  for nom=1:NumberOfModes,
    figure_handles{nom} = figure,
    plot(time, TimeSeries(:,:,nom) + SeparateBy(1,nom)*repmat((1:NumberOfNodes),[TimeSteps,1]));
    title([ThisStateVariable '    Mode ' num2str(nom) ' of ' num2str(NumberOfModes)], 'interpreter', 'none');
    xlabel('Time()');
    set(gca,'ylim',[0 SeparateBy(1,nom)*(NumberOfNodes+1)]);
    set(gca,'YTick', SeparateBy(1,nom)*(1:NumberOfNodes));
    set(gca,'YTickLabel', labels);
  end

end  %PlotTimeSeries()
