%% Plot region averaged time series
%
% ARGUMENTS:
%           <arg1> -- <description>
%
% OUTPUT: 
%           <output1> -- <description>
%
% USAGE:
%{
      % Add path to ExampleScripts if necessary
      ExampleScriptsPath = genpath(fullfile(pwd,'ExampleScripts'));
      path(ExampleScriptsPath,path)
 
      %Generate some data (note this one take 30+ minutes)
      ExampleScript_Rest_BRRWtess

      %Plot it...
      PlotRegionAveragedTimeSeries(Store_phi_e(1:4:end,:), options.Connectivity, Store_t(1:4:end))
%}
%
% MODIFICATION HISTORY:
%     SAK(16-02-2010) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlotRegionAveragedTimeSeries(TimeSeries, Connectivity, Time)

 
%% Data info
 ThisStateVariable = inputname(1);

 [TimeSteps NumberOfVertices NumberOfModes] = size(TimeSeries);
 
 if nargin<3,
   Time = 1:TimeSteps;
 end

%% Initialise regional timeseries 
 RegionalTimeSeries = zeros(TimeSteps, Connectivity.NumberOfNodes, NumberOfModes); 
 SeparateBy = zeros(1, NumberOfModes);
 for nom=1:NumberOfModes,
   for k=1:Connectivity.NumberOfNodes,
     RegionalTimeSeries(:,k,nom) = mean(TimeSeries(:,Connectivity.RegionMapping==k,nom), 2);
   end
   RegionalTimeSeries(:,:,nom) = detrend(RegionalTimeSeries(:,:,nom));
   SeparateBy(1, nom) = 0.33*(max(max(RegionalTimeSeries(:,:,nom))) - min(min(RegionalTimeSeries(:,:,nom))));
 end

  for nom=1:NumberOfModes,
    figure,
    plot(Time, RegionalTimeSeries(:,:,nom) + SeparateBy(1,nom)*repmat((1:Connectivity.NumberOfNodes),[TimeSteps,1]));
    title([ThisStateVariable '    Mode ' num2str(nom) ' of ' num2str(NumberOfModes)], 'interpreter', 'none');
    xlabel('Time()');
    set(gca,'ylim',[0 SeparateBy(1,nom)*(Connectivity.NumberOfNodes+1)]);
    set(gca,'YTick', SeparateBy(1,nom)*(1:Connectivity.NumberOfNodes));
    set(gca,'YTickLabel', Connectivity.NodeStr);
  end

end  %PlotRegionAveragedTimeSeries()