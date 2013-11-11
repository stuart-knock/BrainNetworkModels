%% Plot node values as a bar chart, coloured based on the larger region
% of which they are a part.
%
% See figures 5, 9, and 10 of:
%   Knock, S. A., et al. "The effects of physiologically plausible connectivity
%   structure on local and global dynamics in large scale brain models." 
%   Journal of neuroscience methods 183.1 (2009): 86-94.
%
%
% ARGUMENTS:
%          Regions -- A regions structure, as produced by the GroupRegions()
%                     function in utilities.
%          NodeStr -- A cell array of strings that label the nodes.
%
% OUTPUT: 
%          none
%
% REQUIRES: 
%          none
%
% USAGE:
%{
    %You probably don't want to directly, see ./PlotGraphMetrics.m
%}
%


function PlotRegionColouredBars(Regions, NodeStr)

  RegionNames = fieldnames(Regions);
  NumberOfRegions = length(RegionNames);
  N = length(Regions.(RegionNames{1}));
  
  TheseBars = zeros(N,NumberOfRegions);
  for j=1:length(RegionNames),
    TheseBars(:,j) = Regions.(RegionNames{j});
  end
  
  barh(TheseBars,'stacked')
  legend(RegionNames,'Location','SouthEast')
  set(gca,'ylim',[0 length(NodeStr)+1]);
  set(gca,'YTick', 1:length(NodeStr));
 
end  %PlotRegionColouredBars()
