%% Plot a surface with colour and elevation based on the time-series values. 
%
% ARGUMENTS:
%        TimeSeries -- As output from a simulation, ie with 
%                      shape = [tpts, nodes, modes]
%        time -- Either dt or a vector of time values, with length = tpts.
%        labels -- node labels, eg options.Connectivity.NodeStr 
%
% OUTPUT: 
%        none
%
% REQUIRES: 
%        none
%
% USAGE:
%{
    %Assuming you've just run ReducedFHN_RM_AC_1s_demo
    PlotTimeSeries(store_Alfa, store_t, options.Connectivity.NodeStr)
%}
%
% MODIFICATION HISTORY:
%     SAK(17-03-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function PlotSpaceTime(TimeSeries, time, labels)
  
  ThisStateVariable = inputname(1);
  [TimeSteps NumberOfNodes NumberOfModes] = size(TimeSeries);
  
  if nargin < 2,
    time = 1:TimeSteps;
  else
    if length(time) == 1, % assume it's dt
      time = time .* (1:TimeSteps);
    end
  end
  
  if nargin < 3,
    for k=1:NumberOfNodes, labels{k} = num2str(k); end; %index labels
  end

  space = (1:NumberOfNodes);
  
  for nom=1:NumberOfModes,
    figure,
      surf(space, time, TimeSeries,'FaceColor','interp','EdgeColor','none');
      axis tight
      if ~isoctave(),
        camlight left;
        lighting phong
      end
      view(21, 77);
      colormap hsv;
      title(['Space-time plot of "' ThisStateVariable '", Mode ' num2str(nom) ' of ' num2str(NumberOfModes)]);
      xlabel('Space()');
      set(gca,'XTick', space);
      set(gca,'XTickLabel', labels);
      ylabel('Time(ms)');
  end

end %function PlotSpaceTime()
