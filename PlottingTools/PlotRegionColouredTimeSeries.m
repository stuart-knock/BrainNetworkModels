%% Plot FFT of a TimeSeries Mapped into a set of regions and coloured accordingly.
%
% ARGUMENTS:
%        TimeSeries -- (tpts, nodes)
%        time -- Either dt or a vector of time values, with length = tpts.
%        Mapping -- From nodes to time-series you want to display,
%                   a simple subset, a region averaging, or 
%                   TODO: more complex mappings such as EEG/MEG/etc...
%
% OUTPUT: 
%        FigureHandle -- A handle for the figure.
%
% REQUIRES: 
%        none
%
% USAGE:
%{
    %Assuming you've just run ReducedFHN_RM_AC_1s_demo
    addpath(genpath('./PlottingTools'))
    Mapping = mapping_to_functional(options);
    FigureHandle = PlotRegionColouredTimeSeries(store_Alfa(:,:,1), store_t, Mapping)
%}
%
% MODIFICATION HISTORY:
%     SAK(07-05-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function FigureHandles = PlotRegionColouredTimeSeries(TimeSeries, time, Mapping)
%% TimeSeries info
  if ndims(TimeSeries)>2,
    msg = 'This PlottingTool only works for TimeSeries of shape (tpts, nodes)';
    error(['BrainNetwrokModels:PlottingTools', mfilename, ':HateModes'], msg);
  end
  [NumberOfTimePoints NumberOfNodes] = size(TimeSeries);
  ThisTimeSeries = inputname(1);

%% Set defaults for any argument that weren't specified
  if nargin<2 || isempty(time),
    msg = 'No time provided, defaulting to data-points...';
    warning(['BrainNetwrokModels:PlottingTools', mfilename, ':NoTime'], msg);
    time = 1:NumberOfTimePoints;
  else
  	if length(time) == 1, % assume it's dt
      time = time .* (1:NumberOfTimePoints);
    end
  end
  if nargin<3 || isempty(Mapping),
    msg = 'No Mapping was provided, if this is a surface time-series this''ll get ugly';
    warning(['BrainNetwrokModels:PlottingTools', mfilename, ':NoMapping'], msg);
    Mapping.ProjectionMatrix = speye(NumberOfNodes);
    for k=1:NumberOfNodes, Mapping.ProjectionLables{k} = num2str(k); end; %index labels
  end

%% Projecting to 
  NumberOfRegions = size(Mapping.ProjectionMatrix, 2);

%% Initialise timeseries
  TimeSeries = TimeSeries * Mapping.ProjectionMatrix;
  TimeSeries = detrend(TimeSeries);
  
  RegionNames = Mapping.ProjectionLables;
  NumberOfRegions = length(RegionNames);
  
  MAP = colormap;
  step = NumberOfRegions/size(MAP,1);
  
  rHandles = zeros(1,NumberOfRegions);
  SeparateBy = 0.42*(max(TimeSeries(:)) - min(TimeSeries(:)));
  SeparateBy = SeparateBy * (1:NumberOfRegions);
  
  figure, hold on
  for j=1:NumberOfRegions,
    ci = max(fix(j/step),1); %Colour Index
    temp = plot(time, TimeSeries(:, j) + SeparateBy(j), 'Color',MAP(ci,:), 'LineWidth',2);
    rHandles(1,j) = temp(1);
  end
  title(ThisTimeSeries, 'interpreter', 'none');
  xlabel('Time(ms)');
  
  legend(rHandles,RegionNames,'Location','SouthEast')
  set(gca,'ylim',[0 SeparateBy(NumberOfRegions)+max(TimeSeries(:))]);
  set(gca,'YTick', SeparateBy);
  set(gca,'YTickLabel', RegionNames);

end  %PlotRegionColouredTimeSeries()
