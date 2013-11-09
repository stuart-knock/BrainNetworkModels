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
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(09-04-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function PlotConnectivity(Connectivity)
% Default the "delay" matrix to be a distance matrix
if ~isfield(Connectivity,'invel'), 
  Connectivity.invel = 1;
end
 
%% Get the connectivity matrix...
 
 Connectivity = GetConnectivity(Connectivity);
     
 %clean up self connection weights from the DSI martix...
  Connectivity.weights = Connectivity.weights .* ~eye(size(Connectivity.weights));
 
 if nargin==1,
   Order = 1:Connectivity.NumberOfNodes;
 else
   if isfield(Connectivity,'Order'),
     Order = Connectivity.Order;
   else
     Order = 1:Connectivity.NumberOfNodes;
   end
 end
 
%% Make the titles
 switch Connectivity.WhichMatrix
   case {'G_20110513' }
     for k = 1:Connectivity.NumberOfNodes, 
       Connectivity.NodeStr{k} = Connectivity.NodeStr{k}(1:end-2); 
     end
     WeightsTitle = ['Weights for ' Connectivity.WhichMatrix];
     DelaysTitle  = ['Delays(ms) for V = ' num2str(Connectivity.invel) ' m/s for ' Connectivity.WhichMatrix];
   case {'RM_AC' 'NearestNeighbour' 'Local' 'Random' 'AllToAll'}
     WeightsTitle = ['Weights for ' Connectivity.WhichMatrix];
     DelaysTitle  = ['Delays(ms) for V = ' num2str(Connectivity.invel) ' m/s for ' Connectivity.WhichMatrix];
   case {'for_Vik_July11'}
     WeightsTitle = ['Weights for ' Connectivity.WhichMatrix];
     DelaysTitle  = ['Delays(ms) for V = ' num2str(Connectivity.invel) ' m/s for ' Connectivity.WhichMatrix];
     if isfield(Connectivity,'subject'),
       WeightsTitle = [WeightsTitle ' Subject: ' num2str(Connectivity.subject)];
       DelaysTitle  = [DelaysTitle  ' Subject: ' num2str(Connectivity.subject)];
     end
   case {'O52R00_IRP2008'}
     WeightsTitle = ['Weights for ' Connectivity.WhichMatrix];
     DelaysTitle  = ['Delays(ms) for V = ' num2str(Connectivity.invel) ' m/s for ' Connectivity.WhichMatrix];
     if isfield(Connectivity,'centres'),
       WeightsTitle = [WeightsTitle ' Centres: ' Connectivity.centres];
       DelaysTitle  = [DelaysTitle  ' Centres: ' Connectivity.centres];
     end
     if isfield(Connectivity,'hemisphere'),
       WeightsTitle = [WeightsTitle ' Hemisphere: ' Connectivity.hemisphere];
       DelaysTitle  = [DelaysTitle  ' Hemisphere: ' Connectivity.hemisphere];
     end
   otherwise
     error(strcat(mfilename,':UnknownConnectionMatrix'), ['Don''t know how to load this matrix...' Connectivity.WhichMatrix]);
 end
 
%% Create a figure with colourmap to Emphasise large numbers
 figure
 load('BlackToBlue'); 
 set(gcf,'Colormap',BlackToBlue); 

%% Weights
 imagesc(Connectivity.weights(Order,Order));
 titleHandle = title(WeightsTitle,'interpreter','none');
 set(titleHandle, 'FontWeight','bold');
   
 daspect([1 1 1]);
 set(gca,'XTick', 1:length(Order),'FontWeight','bold','FontSize',10);
 set(gca,'YTick', 1:length(Order),'FontWeight','bold','FontSize',10);
 set(gca,'XTickLabel', Connectivity.NodeStr(Order),'FontWeight','bold','FontSize',10);
 set(gca,'YTickLabel', Connectivity.NodeStr(Order),'FontWeight','bold','FontSize',10);
 imrotateticklabel(gca,90);
 set(gca,'ZColor',[0.2471 0.2471 0.2471],...
         'YColor',[0.2471 0.2471 0.2471],...
         'XColor',[0.2471 0.2471 0.2471],...
         'Color',[0 0 0],'FontSize',16);
 colorbar

       
%% Create a figure with colourmap to Emphasise small numbers
 figure
 load('GreenToBlack')
 set(gcf,'Colormap',GreenToBlack) 
 
%% Delays
 Connectivity.delay(Connectivity.weights==0) = Inf;
 imagesc(Connectivity.delay(Order,Order));
 titleHandle = title(DelaysTitle,'interpreter','none');
 set(titleHandle, 'FontWeight','bold');
   
 daspect([1 1 1]);
 set(gca,'XTick', 1:length(Order),'FontWeight','bold','FontSize',10);
 set(gca,'YTick', 1:length(Order),'FontWeight','bold','FontSize',10);
 set(gca,'XTickLabel', Connectivity.NodeStr(Order),'FontWeight','bold','FontSize',10);
 set(gca,'YTickLabel', Connectivity.NodeStr(Order),'FontWeight','bold','FontSize',10);
 imrotateticklabel(gca,90);
 set(gca,'ZColor',[0.2471 0.2471 0.2471],...
         'YColor',[0.2471 0.2471 0.2471],...
         'XColor',[0.2471 0.2471 0.2471],...
         'Color',[0 0 0],'FontSize',16);
 colorbar

 
end %function PlotConnectivity()