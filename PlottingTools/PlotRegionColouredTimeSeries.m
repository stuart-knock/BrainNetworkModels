%% <Description>
%
% ARGUMENTS:
%           <arg1> -- <description>
%
% OUTPUT: 
%           <output1> -- <description>
%
% USAGE:
%{
      
%}
%
% MODIFICATION HISTORY:
%     SAK(07-05-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlotRegionColouredTimeSeries(TimeSeries,Regions,NodeStr)
 
 TimeSeries = detrend(TimeSeries.');
 
 RegionNames = fieldnames(Regions);
 NumberOfRegions =length(RegionNames);
 N = length(Regions.(RegionNames{1}));
 
 MAP = colormap;
 step = NumberOfRegions/size(MAP,1);
 
 rHandles = zeros(1,NumberOfRegions);
 
 figure, hold on
 for j=1:length(RegionNames),
   ci = max(fix(j/step),1); %Colour Index
%%%keyboard
   temp = plot(TimeSeries(:,Regions.(RegionNames{j})~=0) + repmat(Regions.(RegionNames{j})(Regions.(RegionNames{j})~=0).',[length(TimeSeries) 1]), 'Color', MAP(ci,:));
   rHandles(1,j) = temp(1);
 end
 
 legend(rHandles,RegionNames,'Location','SouthEast')
 set(gca,'ylim',[0 length(NodeStr)+1]);
 set(gca,'YTick', 1:length(NodeStr));
 set(gca,'YTickLabel', NodeStr);
 
end  %PlotRegionColouredTimeSeries()
