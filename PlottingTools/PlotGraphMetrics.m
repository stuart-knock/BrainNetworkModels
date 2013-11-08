%% Plot sorted historgams and imagesc() matrices of the graph metrics for a
% given connectivity matrix...
%
% ARGUMENTS:
%           ThisMatrix -- 
%           options -- 
%
% OUTPUT: 
%           <output1> -- <description>
%
% USAGE:
%{
     ThisMatrix = 'RM_AC';
     PlotGraphMetrics(ThisMatrix)
%}
%
% MODIFICATION HISTORY:
%     SAK(17-04-2009) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function PlotGraphMetrics(ThisMatrix,options)
 
%% Make sure the "delay" matrix will also be a distance matrix
 if nargin>1,
   if isfield(options,'invel'),
     warning(strcat('PlottingTools:',mfilename,':Resetting_invel'), 'Resetting the invel you provided to 1, so that delay is a distance matrix');
   end
 end
 options.invel = 1;
 
%% Get the connectivity matrix...
 switch ThisMatrix
   case {'RM_AC' 'O52R00_IRP2008'}
     [weights delay NodeStr NodeLoc] = GetConnectivity(ThisMatrix,options);
     
   %%%THE SENSE OF THESE MATRICES IS REVERSED FROM THAT EXPECTED BY THE GRAPH METRIC ALGORITHMS... (Algorithms expect n1 -> n2 = x(1,2); Matrices are n1 -> n2 = x(2,1))%%% 
     weights = weights.';
     delay   = delay.';

% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % %%% ALL THIS, FROM HERE TO %%%
% % % %      % Clean-up crappy Node Strings...(keep having to do this, should probably just do within GetConnectivity())
% % % %      for j = 1:length(NodeStr),
% % % %        if length(NodeStr{j})>6, NodeStr{j}(NodeStr{j}(1:6)=='BHD91-') = []; end
% % % %        if length(NodeStr{j})>5, NodeStr{j}(NodeStr{j}(1:5)=='BK83-')  = []; end
% % % %        if length(NodeStr{j})>4, NodeStr{j}(NodeStr{j}(1:4)=='O52-')   = []; end
% % % %        if length(NodeStr{j})>4, NodeStr{j}(NodeStr{j}(1:4)=='R00-')   = []; end
% % % %        %NodeStr{j}(NodeStr{j}=='.') = [];
% % % %      end
% % % % 
% % % %      %get rid of unconnected nodes..
% % % %      unconnected = [];
% % % %      for j = 1:length(NodeStr), 
% % % %        if all([weights(j,:) weights(:,j).'] == 0 ), 
% % % %          unconnected = [unconnected j];
% % % %        end
% % % %      end
% % % %      weights(:,unconnected) = [];
% % % %      weights(unconnected,:) = [];
% % % %      delay(:,unconnected)   = [];
% % % %      delay(unconnected,:)   = [];
% % % %      NodeStr(unconnected)   = [];
% % % % %%% HERE, SHOULD BE IN GetConnectivtiy() %%% 
% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'for_Vik_July11'}
     [weights delay NodeStr] = GetConnectivity(ThisMatrix,options);
   otherwise
     error(strcat(mfilename,':UnknownConnectionMatrix'), ['Don''t know how to load this matrix...' ThisMatrix]);
 end
 
%% Check for Disconnected Nodes.
 [In Out] = Degrees(weights);
%%%keyboard
 while any(In==0) || any(Out==0),
   if any(In==0),
     warning(strcat('PlottingTools:',mfilename,':NetworkDisconnected'), 'The network appears to be disconnected: Our metrics require a path to and from every node, removing nodes that can''t be reached to avoid Inf');

     %Remove nodes from weights
     weights(:,            find(In==0))  = [];
     weights(find(In==0),  :)            = [];
     %Remove nodes from delay
     delay(:,            find(In==0))  = [];
     delay(find(In==0),  :)            = [];
   end

   if any(Out==0),
     warning(strcat('PlottingTools:',mfilename,':NetworkDisconnected'), 'The network appears to be disconnected: Our metrics require a path to and from every node, removing nodes that can''t be escaped from to avoid Inf');

     %Remove nodes from weights
     weights(:,            find(Out==0)) = [];
     weights(find(Out==0), :)            = [];
     %Remove nodes from delay
     delay(:,            find(Out==0)) = [];
     delay(find(Out==0), :)            = [];
   end
 
  %Remove nodes from NodeStr
   NodeStr([find(In==0) ; find(Out==0)]) = [];
   
   [In Out] = Degrees(weights); %Recalculate 
 end
 
%% Calculate metrics 
 [PL stdPL nodeoPL stdnodeoPL nodeiPL stdnodeiPL epochPL stdepochPL D] = PathLengths(weights);
 [CC oCC iCC fbCC maCC] = ClusteringCoefficients(weights);
 [Hubco nodeHubco stdnodeHubco Edgco] = BetweenessCentrality(weights);

%% Invert the "distance matrix" returned by PathLengths() so that it's back in the
%% same "units" as weights...
  D(D~=0) = 1./D(D~=0);
  
 [mIn mOut] = Degrees(D);
   
%% Sort Node-wise metrics 
 %Degrees
 [SortIn indSortIn]   = sort(In);
 [SortOut indSortOut] = sort(Out);

 %Multi-step Degrees
 [SortmIn indSortmIn]   = sort(mIn);
 [SortmOut indSortmOut] = sort(mOut);
 
 %Pathlengths
 [SortnodeoPL indSortnodeoPL] = sort(nodeoPL);
 [SortnodeiPL indSortnodeiPL] = sort(nodeiPL);

 %Clustering Coefficients
 [SortCC indSortCC]     = sort(CC);
 [SortoCC indSortoCC]   = sort(oCC);
 [SortiCC indSortiCC]   = sort(iCC);
 [SortfbCC indSortfbCC] = sort(fbCC);
 [SortmaCC indSortmaCC] = sort(maCC);

 %Hub Coefficient
 [SortHubco indSortHubco] = sort(Hubco);
 
 disp(['Minimum Weighted In-Degree: '  NodeStr{indSortIn(1)}    ' = ' num2str(SortIn(1))])
 disp(['Maximum Weighted In-Degree: '  NodeStr{indSortIn(end)}  ' = ' num2str(SortIn(end))])
 disp(['Minimum Weighted Out-Degree: ' NodeStr{indSortOut(1)}   ' = ' num2str(SortOut(1))])
 disp(['Maximum Weighted Out-Degree: ' NodeStr{indSortOut(end)} ' = ' num2str(SortOut(end))])
 
 disp(['Minimum Connection Strength Inbound Path Length: '  NodeStr{indSortnodeiPL(1)}    ' = ' num2str(SortnodeiPL(1))])
 disp(['Maximum Connection Strength Inbound Path Length: '  NodeStr{indSortnodeiPL(end)}  ' = ' num2str(SortnodeiPL(end))])
 
 disp(['Minimum Connection Strength Outbound Path Length: '  NodeStr{indSortnodeoPL(1)}    ' = ' num2str(SortnodeoPL(1))])
 disp(['Maximum Connection Strength Outbound Path Length: '  NodeStr{indSortnodeoPL(end)}  ' = ' num2str(SortnodeoPL(end))])
 
 disp(['Minimum Clustering Coefficients: '  NodeStr{indSortCC(1)}    ' = ' num2str(SortCC(1))])
 disp(['Maximum Clustering Coefficients: '  NodeStr{indSortCC(end)}  ' = ' num2str(SortCC(end))])
 
 disp(['Minimum Betweeness Centrality: '  NodeStr{indSortHubco(1)}    ' = ' num2str(SortHubco(1))])
 disp(['Maximum Betweeness Centrality: '  NodeStr{indSortHubco(end)}  ' = ' num2str(SortHubco(end))])
 

%% Plot multi-step connectivity strength
 figure
 load('BlackToBlue'); 
 set(gcf,'Colormap',BlackToBlue); 
 
 imagesc(D);
 titleHandle = title(['Multi-step connectivity strength for ' ThisMatrix],'interpreter','none');
 set(titleHandle, 'FontWeight','bold');
 daspect([1 1 1]);
 set(gca,'XTick', 1:length(NodeStr),'FontWeight','bold','FontSize',10);
 set(gca,'YTick', 1:length(NodeStr),'FontWeight','bold','FontSize',10);
 set(gca,'XTickLabel', NodeStr,'FontWeight','bold','FontSize',10);
 set(gca,'YTickLabel', NodeStr,'FontWeight','bold','FontSize',10);
 imrotateticklabel(gca,90);
 set(gca,'ZColor',[0.2471 0.2471 0.2471],...
         'YColor',[0.2471 0.2471 0.2471],...
         'XColor',[0.2471 0.2471 0.2471],...
         'Color',[0 0 0],'FontSize',16);
 colorbar
 
%% Plot Edgecoefficients
 figure
 imagesc(Edgco);
 titleHandle = title(['Betweeness Centrality Edge-Coefficients for ' ThisMatrix],'interpreter','none');
 set(titleHandle, 'FontWeight','bold');
 daspect([1 1 1]);
 set(gca,'XTick', 1:length(NodeStr),'FontWeight','bold','FontSize',10);
 set(gca,'YTick', 1:length(NodeStr),'FontWeight','bold','FontSize',10);
 set(gca,'XTickLabel', NodeStr,'FontWeight','bold','FontSize',10);
 set(gca,'YTickLabel', NodeStr,'FontWeight','bold','FontSize',10);
 imrotateticklabel(gca,90);
 set(gca,'ZColor',[0.2471 0.2471 0.2471],...
         'YColor',[0.2471 0.2471 0.2471],...
         'XColor',[0.2471 0.2471 0.2471],...
         'Color',[0 0 0],'FontSize',16);
 colorbar
 
%%    
%%%keyboard 
 figure, %degrees
   
   Regions = GroupRegions(In,indSortIn,NodeStr,ThisMatrix);
   subplot(1,2,1), 
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortIn));
     title('Weighted In-Degree')

   Regions = GroupRegions(Out,indSortOut,NodeStr,ThisMatrix);
   subplot(1,2,2), 
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortOut));
     title('Weighted Out-Degree')
     
 figure, %multi-step degrees
   
   Regions = GroupRegions(mIn,indSortmIn,NodeStr,ThisMatrix);
   subplot(1,2,1), 
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortmIn));
     title('Weighted Multi-step In-Degree')

   Regions = GroupRegions(mOut,indSortmOut,NodeStr,ThisMatrix);
   subplot(1,2,2), 
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortmOut));
     title('Weighted Multi-step Out-Degree')

 figure, %pathlength
   Regions = GroupRegions(nodeiPL,indSortnodeiPL,NodeStr,ThisMatrix);
   subplot(1,2,1),  
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortnodeiPL));   
     title('Inbound Pathlength')
     
   Regions = GroupRegions(nodeoPL,indSortnodeoPL,NodeStr,ThisMatrix);
   subplot(1,2,2), 
     PlotRegionColouredBars(Regions,NodeStr)
     set(gca,'YTickLabel', NodeStr(indSortnodeoPL)); 
     title('Outbound Pathlength')

     

 figure, %clusteringcoefficient
   Regions = GroupRegions(CC,indSortCC,NodeStr,ThisMatrix);
   subplot(1,5,1),
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortCC));  
     title('Average Clustering Coefficient') 

   Regions = GroupRegions(oCC,indSortoCC,NodeStr,ThisMatrix);
   subplot(1,5,2),
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortoCC)); 
     title('Outbound Clustering Coefficient')
   
   Regions = GroupRegions(iCC,indSortiCC,NodeStr,ThisMatrix);
   subplot(1,5,3), 
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortiCC)); 
     title('Inbound Clustering Coefficient')
   
   Regions = GroupRegions(fbCC,indSortfbCC,NodeStr,ThisMatrix);
   subplot(1,5,4), 
     PlotRegionColouredBars(Regions,NodeStr)
     set(gca,'YTickLabel', NodeStr(indSortfbCC)); 
     title('Feedback Clustering Coefficient')
   
   Regions = GroupRegions(maCC,indSortmaCC,NodeStr,ThisMatrix);
   subplot(1,5,5),  
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortmaCC));   
     title('Mutual Association Clustering Coefficient')


 figure, %Hubcoefficient
   Regions = GroupRegions(Hubco,indSortHubco,NodeStr,ThisMatrix);
     PlotRegionColouredBars(Regions,NodeStr)
     set(gca,'YTickLabel', NodeStr(indSortHubco));
    title('Node-wise Betweeness Centrality') 


%% Calculate Path lengths for physical space 
 delay(weights==0) = Inf; %where there are no connections set the distance between those nodes to Inifinity
 delay = delay + rand(size(delay)); %Has effect of randomly jittering points by upto 1mm, avoid issue caused by thalumus as point...
 [PL stdPL nodeoPL stdnodeoPL nodeiPL stdnodeiPL epochPL stdepochPL D] = PathLengths(1./delay);
 
%% Sort Node-wise  physical space Path lengths
 %Pathlengths
 [SortnodeiPL indSortnodeiPL] = sort(nodeiPL);
 [SortnodeoPL indSortnodeoPL] = sort(nodeoPL);
 
 disp(['Minimum physical space Inbound Path lengths: '  NodeStr{indSortnodeiPL(1)}    ' = ' num2str(SortnodeiPL(1)) ' mm'])
 disp(['Maximum physical space Inbound Path lengths: '  NodeStr{indSortnodeiPL(end)}  ' = ' num2str(SortnodeiPL(end)) ' mm'])
 
 disp(['Minimum physical space Outbound Path lengths: '  NodeStr{indSortnodeoPL(1)}    ' = ' num2str(SortnodeoPL(1)) ' mm'])
 disp(['Maximum physical space Outbound Path lengths: '  NodeStr{indSortnodeoPL(end)}  ' = ' num2str(SortnodeoPL(end)) ' mm'])

%% Plot multi-step minimum distance between nodes
 figure
 load('GreenToBlack')
 set(gcf,'Colormap',GreenToBlack) 
 
 imagesc(D);
 titleHandle = title(['Multi-step distance matrix for ' ThisMatrix],'interpreter','none');
 set(titleHandle, 'FontWeight','bold');
 daspect([1 1 1]);
 set(gca,'XTick', 1:length(NodeStr),'FontWeight','bold','FontSize',10);
 set(gca,'YTick', 1:length(NodeStr),'FontWeight','bold','FontSize',10);
 set(gca,'XTickLabel', NodeStr,'FontWeight','bold','FontSize',10);
 set(gca,'YTickLabel', NodeStr,'FontWeight','bold','FontSize',10);
 imrotateticklabel(gca,90);
 set(gca,'ZColor',[0.2471 0.2471 0.2471],...
         'YColor',[0.2471 0.2471 0.2471],...
         'XColor',[0.2471 0.2471 0.2471],...
         'Color',[0 0 0],'FontSize',16);
 colorbar
 
%% 
 figure, %pathlength
   Regions = GroupRegions(nodeiPL,indSortnodeiPL,NodeStr,ThisMatrix);
   subplot(1,2,1),  
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortnodeiPL)); 
     title('Inbound Pathlength')
     xlabel('(mm)')  
     
   Regions = GroupRegions(nodeoPL,indSortnodeoPL,NodeStr,ThisMatrix);
   subplot(1,2,2), 
     PlotRegionColouredBars(Regions,NodeStr) 
     set(gca,'YTickLabel', NodeStr(indSortnodeoPL)); 
     title('Outbound Pathlength')
     xlabel('(mm)')  

 
end %function PlotGraphMetrics()


% % % function Regions = GroupRegions(Metric,Index,NodeStr,ThisMatrix) % % %,options)
% % %  
% % % % % %  if nargin<5
% % % % % %    options.GroupBy = 'RestStateNetwork';
% % % % % %  else
% % % % % %    if ~isfield(options,'GroupBy'), 
% % % % % %      options.GroupBy = 'RestStateNetwork'; 
% % % % % %    end
% % % % % %  end
% % %  
% % %  N = length(NodeStr);
% % %  
% % %  switch ThisMatrix,
% % %    case {'RM_AC' 'O52R00_IRP2008'}
% % %      Regions.PreFrontal = zeros(N,1);
% % %      Regions.Parietal   = zeros(N,1);
% % %      Regions.Cingulate  = zeros(N,1);
% % %      Regions.Visual     = zeros(N,1);
% % %      Regions.AllOther   = zeros(N,1);
% % % 
% % %      for j = 1:N,
% % %        switch lower(NodeStr{j}(1:2)),
% % %          case {'pf'},
% % %            Regions.PreFrontal(Index==j) = Metric(j);
% % %          case {'pc'},
% % %            Regions.Parietal(Index==j)   = Metric(j);
% % %          case {'cc'},
% % %            Regions.Cingulate(Index==j)  = Metric(j);
% % %          case {'va', 'v1', 'v2',},
% % %            Regions.Visual(Index==j)     = Metric(j);
% % %          otherwise
% % %            Regions.AllOther(Index==j)   = Metric(j);
% % %        end
% % %      end
% % %   
% % %    case {'for_Vik_July11'}
% % % % % %      switch lower(options.GroupBy)
% % % % % %        case {'hemisphere'}
% % %          Regions.Left  = zeros(N,1);
% % %          Regions.Right = zeros(N,1);
% % %          for j = 1:N,
% % %            switch lower(NodeStr{j}(1)),
% % %              case {'l'},
% % %                Regions.Left(Index==j)     = Metric(j);
% % %              case {'r'},
% % %                Regions.Right(Index==j)    = Metric(j);
% % %              otherwise
% % %                Regions.AllOther(Index==j) = Metric(j);
% % %            end
% % %          end
% % %          
% % % % % %        case {'reststatenetwork'}
% % % % % %          Regions.PreFrontal = zeros(N,1);
% % % % % %          Regions.Parietal   = zeros(N,1);
% % % % % %          Regions.Cingulate  = zeros(N,1);
% % % % % %          Regions.Visual     = zeros(N,1);
% % % % % %          Regions.AllOther   = zeros(N,1);
% % % % % %          for j = 1:N,
% % % % % %            switch lower(NodeStr{j}(1:2)),
% % % % % %              case {'pf'},
% % % % % %                Regions.PreFrontal(Index==j) = Metric(j);
% % % % % %              case {'pc'},
% % % % % %                Regions.Parietal(Index==j)   = Metric(j);
% % % % % %              case {'cc'},
% % % % % %                Regions.Cingulate(Index==j)  = Metric(j);
% % % % % %              case {'va', 'v1', 'v2',},
% % % % % %                Regions.Visual(Index==j)     = Metric(j);
% % % % % %              otherwise
% % % % % %                Regions.AllOther(Index==j)   = Metric(j);
% % % % % %            end
% % % % % %          end
% % % % % %      end
% % %      
% % %    otherwise
% % %      error(strcat(mfilename,':UnknownConnectionMatrix'), ['Don''t know how to load this matrix...' ThisMatrix]);
% % %  end
% % %      
% % % end % function GroupRegions()
% % % 
% % % 
% % % function PlotRegionColouredBars(Regions,NodeStr)
% % % 
% % %  RegionNames = fieldnames(Regions);
% % %  NumberOfRegions =length(RegionNames);
% % %  N = length(Regions.(RegionNames{1}));
% % %  
% % %  TheseBars = zeros(N,NumberOfRegions);
% % %  for j=1:length(RegionNames),
% % %    TheseBars(:,j) = Regions.(RegionNames{j});
% % %  end
% % %  
% % %  barh(TheseBars,'stacked')
% % %  legend(RegionNames,'Location','SouthEast')
% % %  set(gca,'ylim',[0 length(NodeStr)+1]);
% % %  set(gca,'YTick', 1:length(NodeStr));
% % %  
% % % end  %PlotRegionColouredBars()

%%%EoF%%%