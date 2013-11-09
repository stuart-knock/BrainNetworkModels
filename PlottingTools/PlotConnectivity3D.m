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
%     SAK(06-05-2009) -- Modified to (ThisMatrix,options) calling format.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function PlotConnectivity3D(ThisMatrix,options)
%%
 if nargin == 1, %No options specified
   [weights delay NodeStr] = GetConnectivity(ThisMatrix);
 else
   [weights delay NodeStr] = GetConnectivity(ThisMatrix,options);
 end
 
 N = size(weights,1);
 minW = min(weights(:));
 maxW = max(weights(:));
 minD = min(delay(:)) ;
 maxD = max(delay(:));
 stepD = (maxD-minD)/100;
 
 ThisTitle = ThisMatrix;

 if nargin == 1, %No options specified
   Order = 1:N;
   EdgeCutoff = minW;
 else
   if isfield(options,'Order'),
     Order = options.Order;
   else
     Order = 1:N;
   end
   
   if isfield(options,'EdgeCutoff'),
     EdgeCutoff = options.EdgeCutoff;
     ThisTitle = [ThisTitle ' for EdgeCutoff: ' num2str(EdgeCutoff)];  
   else
     EdgeCutoff = minW; %effectively no cutoff
   end
 end
 
%% Create matrices which define a unit cube...
 cubeX = [0 1 1 0 0 0 ; ...
          1 1 0 0 1 1 ; ... 
          1 1 0 0 1 1 ; ... 
          0 1 1 0 0 0];
 cubeY = [0 0 1 1 0 0 ; ...
          0 1 1 0 0 0 ; ...
          0 1 1 0 1 1 ; ...
          0 0 1 1 1 1];
 cubeZ = [0 0 0 0 0 1 ; ...
          0 0 0 0 0 1 ; ...
          1 1 1 1 0 1 ; ...
          1 1 1 1 0 1];
 
%% Create a figure with 
 figure, hold on
 axis([0 N+1 0 maxD 0 N+1])
 set(gca,'ZColor',[0.2471 0.2471 0.2471],...
         'YColor',[0.2471 0.2471 0.2471],...
         'XColor',[0.2471 0.2471 0.2471],...
         'Color',[0 0 0],'FontSize',14);
 view([57 18]);      
 hold('all');
 daspect([2*N/maxD 1 2*N/maxD]);
 
%% colourmap to Emphasise large numbers
 load('BlackToBlue'); 
 set(gcf,'Colormap',BlackToBlue);    
 MAP = colormap;
 step = 1/size(MAP,1);

%% Loop over connectivity matrix, colouring and one cube per matrix element
 for k = 1:N,
   for m = 1:N,
     if weights(k,m)~=0,
       nlc = (weights(k,m)-minW)./(maxW-minW); %scale
       if k~=m, %not self connection (diagonal
         if weights(k,m) > EdgeCutoff,
           ci = max(fix(nlc/step),1);
           fill3(k+cubeX, delay(k,m)+(stepD.*cubeZ), m+cubeY, MAP(ci,:));
         end
       end
     end
   end
 end
 
%% Pruuutttyyyy... 
 
 title(ThisTitle,'FontWeight','bold','FontSize',16,'interpreter','none')

 set(gca,'XTick', 1:length(Order));
 set(gca,'XTickLabel', {});
%  xticklabel_rotate([],90);
%  set(gca,'YTick', 1:length(Order));
%  set(gca,'YTickLabel', NodeStr(Order));
 set(gca,'ZTick', 1:length(Order));
 set(gca,'ZTickLabel', NodeStr(Order));
 ylabel('Delay (ms)','FontWeight','bold','FontSize',14);
 %lighting phong;
 %camlight right; 
 alpha(.3);

%Ugly hack to make colorbar tick labels...
   RangeLabels = cell(1,11);
   Ranges = 0:(maxW/10):maxW;
   for rli = 1:length(RangeLabels),
     RangeLabels{1,rli} = num2str(Ranges(rli));
   end
   colorbar('YTickLabel', RangeLabels);
 
 hold off
 
end %function PlotConnectivity3D()

%  cubeX = [0 1 1 0 0  0 ; 1  1 0  0 1  1; 1 1 0 0  1 1; 0 1 1 0 0 0]
%  cubeY = [0 0 1 1 0 0; 0 1 1 0 0 0 ; 0 1 1 0 1 1 ; 0 0  1 1 1 1]
%  cubeZ = [0 0 0 0 0 1; 0 0 0 0 0 1; 1 1 1 1 0 1; 1 1 1 1 0 1]
%  cubeFaces = [1 2 6 5; 2 3 7 6 ; 3 4 8 7 ; 4 1 5 8; 1 2 3 4 ; 5 6 7 8]
%  cubeVertices = [0 0 0; 1 0 0 ; 1 1 0 ; 0 1 0; 0 0 1; 1 0 1; 1  1 1; 0 1 1]
 
 