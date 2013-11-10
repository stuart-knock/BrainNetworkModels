%% <Description>
%
% ARGUMENTS:
%           Correlation -- A vector of correlation values, length NumberOfNodes.
%           NodeLoc -- The location of nodes.
%           NodeStr -- A cell array containing a short label for each node.
%
% OUTPUT: 
%           none
%
% REQUIRES: 
%          GreenBlackRed -- a stored colourmap in ./colourmaps
%
% USAGE:
%{
      Connectivity.WhichMatrix = 'RM_AC'
      Connectivity = GetConnectivity(Connectivity);
      C = rand(size(Connectivity.NodeStr)) - 0.5;
      PlotNodewiseCorrelation(C, Connectivity.Position, Connectivity.NodeStr)
%}
%
% MODIFICATION HISTORY:
%     SAK(09-04-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function PlotNodewiseCorrelation(Correlation, NodeLoc, NodeStr)

%%
  [sphereX sphereY sphereZ] = sphere(10);
 
%% 
  figure
    if isoctave(),
      scatter3(NodeLoc(:,1), NodeLoc(:,2), NodeLoc(:,3));
    else %Presumably Matlab
      scatter3(NodeLoc(:,1), NodeLoc(:,2), NodeLoc(:,3), ...
               'MarkerFaceColor',[0 0 1], 'MarkerEdgeColor',[0.6784 0.9216 1]);
    end
    set(gca,'ZColor',[0.2471 0.2471 0.2471], ...
            'YColor',[0.2471 0.2471 0.2471], ...
            'XColor',[0.2471 0.2471 0.2471], ...
            'Color',[0 0 0],'FontSize',16);
    view([57 18]);      
    hold('all');
    MinXYZ = min(NodeLoc) - 0.1*abs(min(NodeLoc));
    MaxXYZ = max(NodeLoc) + 0.1*abs(max(NodeLoc));
    axis([MinXYZ(1) MaxXYZ(1) MinXYZ(2) MaxXYZ(2) MinXYZ(3) MaxXYZ(3)])
    daspect([1 1 1]);

%% 
  N = length(Correlation);
  minC = min(Correlation(:));
  maxC = max(Correlation(Correlation~=1));
  
  Crange = min([abs(minC) abs(maxC)]);
  minC = -Crange;
  maxC =  Crange;
  
  mCorrelation = Correlation;
  mCorrelation(Correlation>maxC) = maxC;
  mCorrelation(Correlation<minC) = minC;
  mCorrelation(Correlation==1) = 1;

%% Symmetric about 0, green anticorrelated, red correlated
  load('GreenBlackRed'); %load('BlueToBlack')
  set(gcf, 'Colormap', GreenBlackRed); %set(gcf,'Colormap',BlueToBlack)
  MAP = colormap;
  step = 1.0/size(MAP,1);

%% 
  for k = 1:N,
    nlc = (mCorrelation(k)-minC)./(maxC-minC); %scale
    if Correlation(k)~=1, %not self connection
      ci = max(fix(nlc/step),1);
      surf(NodeLoc(k,1)+3.*sphereX, NodeLoc(k,2)+3.*sphereY, NodeLoc(k,3)+3.*sphereZ, 'FaceColor', MAP(ci,:));
    else %self connections (diagonal elements)
      surf(NodeLoc(k,1)+4.*sphereX, NodeLoc(k,2)+4.*sphereY, NodeLoc(k,3)+4.*sphereZ, 'FaceColor', [0 0 1]);
    end
  end
  %Label the Original Channels
  for k = 1:length(NodeStr),
    text(NodeLoc(k,1)+0.003, NodeLoc(k,2), NodeLoc(k,3), ['\bf ' NodeStr{k}], 'color', [0.42 0.42 0.42]);
  end

  %Ahhh pruetttyyyyy...
  xlabel('X (mm)', 'FontWeight', 'bold', 'FontSize', 14);
  ylabel('Y (mm)', 'FontWeight', 'bold', 'FontSize', 14);
  zlabel('Z (mm)', 'FontWeight', 'bold', 'FontSize', 14);

  if ~isoctave(), %Octave doesn't seem to currently support these.
    lighting phong;
    camlight right; 
    %alpha(.3);
  end
  hold off

end %function PlotNodewiseCorrelation()
