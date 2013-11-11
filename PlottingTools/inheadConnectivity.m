%% Plot Connectivity in head space as arrows between region centres.
%
% ARGUMENTS:
%        options --
%
% OUTPUT: 
%        none
%
% REQUIRES: 
%        arrow3D() -- 
%        GetConnectivity() -- Conditionally if the options structure doesn't
%                             already contain the Connectivity data.
%        BlackToBlue -- a stored colourmap from PlottingTools/colourmaps/
%
% USAGE:
%{
    options.Connectivity.WhichMatrix = 'RM_AC';
    options = inheadConnectivity(options);
%}
%
% MODIFICATION HISTORY:
%     SAK(09-04-2009) -- Original.
%     SAK(06-05-2009) -- Modified to (ThisMatrix,options) calling format.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function options = inheadConnectivity(options)
%%
  if ~isfield(options.Connectivity, 'Position'), %
    options.Connectivity = GetConnectivity(options.Connectivity);
  end
  
  if ~(isfield(options, 'Plotting') && isfield(options.Plotting,'EdgeCutoff')), %
    options.Plotting.EdgeCutoff = 0.0;
  end

%%  
  scatter3(options.Connectivity.Position(:,1), ... 
           options.Connectivity.Position(:,2), ... 
           options.Connectivity.Position(:,3), ... 
           'MarkerFaceColor',[0 0 1], 'MarkerEdgeColor',[0.6784 0.9216 1]);
  set(gca,'ZColor',[0.2471 0.2471 0.2471],...
          'YColor',[0.2471 0.2471 0.2471],...
          'XColor',[0.2471 0.2471 0.2471],...
          'Color',[0 0 0],'FontSize',16);
  view([57 18]);      
  hold('all');
  MinXYZ = min(options.Connectivity.Position) - 0.1*abs(min(options.Connectivity.Position));
  MaxXYZ = max(options.Connectivity.Position) + 0.1*abs(max(options.Connectivity.Position));
  axis([MinXYZ(1) MaxXYZ(1) MinXYZ(2) MaxXYZ(2) MinXYZ(3) MaxXYZ(3)])
  daspect([1 1 1]);

%% 
  minW = max([min(options.Connectivity.weights(:)) options.Plotting.EdgeCutoff]);
  maxW = max(options.Connectivity.weights(:));

%% Emphasise large numbers
  load('BlackToBlue'); %load('BlueToBlack')
  set(gcf,'Colormap',BlackToBlue); %set(gcf,'Colormap',BlueToBlack)     
  MAP = colormap;
  step = 1/size(MAP,1);

%% 
  for k = 1:options.Connectivity.NumberOfNodes,
    for m = 1:options.Connectivity.NumberOfNodes,
      if options.Connectivity.weights(k,m)~=0,
        nlc = (options.Connectivity.weights(k,m)-minW)./(maxW-minW); %scale
        if k~=m, %not self connection (diagonal
          if options.Connectivity.weights(k,m) > options.Plotting.EdgeCutoff,
            ci = max(fix(nlc/step),1);
            arrow3D(options.Connectivity.Position(k,:)+((options.Connectivity.Position(m,:)-options.Connectivity.Position(k,:)).*0.5), (options.Connectivity.Position(m,:)-options.Connectivity.Position(k,:)).*0.5, MAP(ci,:), 0.95,0.33);
          end
        else %self connections (diagonal elements)
          if options.Connectivity.weights(k,m) > options.Plotting.EdgeCutoff,
            ci = max(fix(nlc/step),1);
          else
            ci = size(MAP,1);
          end
          %Plot coloured sphere to represent node...
        end %if k~=m,
      end %options.Connectivity.weights(k,m)~=0
    end %for m
  end %for k
  %Label the Original Channels
  for k = 1:length(options.Connectivity.NodeStr),
    text(options.Connectivity.Position(k,1)+0.003, options.Connectivity.Position(k,2), options.Connectivity.Position(k,3), ['\bf ' options.Connectivity.NodeStr{k}], 'color', [0.42 0.42 0.42]);
  end

  %Ahhh pruetttyyyyy... 
  if nargin == 1,
    title(options.Connectivity.WhichMatrix,'FontWeight','bold','FontSize',16,'interpreter','none')
    if strcmp(options.Connectivity.WhichMatrix,'RM_AC'),
      for j = 1:3,
        nlc = (j-minW)./(maxW-minW);
        ci = max(fix(nlc/step),1);
        arrow3D([-5 40 30+(j*10)], [0 20 0], MAP(ci,:), 0.95,0.5); text(-5,60,30+(j*10),['\bf ' num2str(j)], 'color', [0.42 0.42 0.42])
      end
    end
  end
  xlabel('X (mm)','FontWeight','bold','FontSize',14);
  ylabel('Y (mm)','FontWeight','bold','FontSize',14);
  zlabel('Z (mm)','FontWeight','bold','FontSize',14);
  if ~isoctave(),
    lighting phong;
    camlight right; 
    %alpha(.3);
  end
  
  hold off
 
end %function inheadConnectivity()
