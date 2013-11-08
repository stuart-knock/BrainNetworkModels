function PlotRegionColouredBars(Regions,NodeStr)

 RegionNames = fieldnames(Regions);
 NumberOfRegions =length(RegionNames);
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