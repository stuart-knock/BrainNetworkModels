%% Plot on the cortical surface all the regigons connected to a given 
% region, with interactive step through regions. 
%
% ARGUMENTS:
%          Surface -- TriRep object of cortical surface.
%          options -- 
%
% OUTPUT: 
%      ThisFigure        -- Handle to overall figure object.
%      SurfaceHandle    -- Handle to patch object, cortical surface.
%
% USAGE:
%{     
       TR = TriRep(Triangles, Vertices);
       SurfaceConnectivity(TR,options)
%}
%
% MODIFICATION HISTORY:
%     SAK(24-11-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ThisFigure SurfaceHandle] = SurfaceConnectivity(Surface,options)

%% Data info
 NumberOfRegions = length(unique(options.Connectivity.RegionMapping));
 MaxW = max(options.Connectivity.weights(options.Connectivity.weights~=0));
 MinW = min(options.Connectivity.weights(options.Connectivity.weights~=0));
 
%% Display info
 ThisScreenSize = get(0,'ScreenSize');
 FigureWindowSize = ThisScreenSize + [ThisScreenSize(3)./4 ,ThisScreenSize(4)./16, -ThisScreenSize(3)./2 , -ThisScreenSize(4)./8];
   
 ThisRegionColour      = [1 0 0];
 ConnectedRegionColour = [0 1 0];
 %OtherRegionColour     = [0 0 1];
  
%% Initialise figure  
 ThisFigure = figure;
 set(ThisFigure,'Position',FigureWindowSize);

  
%% Initialise Surface
 Connectivity = zeros(size(Surface.X)); 
 
 SurfaceHandle = patch('Faces', Surface.Triangulation(1:1:end,:) , 'Vertices', Surface.X, ...
   'Edgecolor','interp', 'FaceColor', 'interp', 'FaceVertexCData', Connectivity); %
 material dull
 SurfaceAxes = ancestor(SurfaceHandle,{'axes'});
 %title(['???'], 'interpreter', 'none');
 xlabel('X (mm)');
 ylabel('Y (mm)');
 zlabel('Z (mm)');
 
 daspect([1 1 1])
%keyboard                       

%% Interactively step through regions. 
   direction = 1;
   Region = 1;
   while (Region >= 1) && (Region <= NumberOfRegions),
     
    %Get this regions connectivity
     Connectivity = zeros(size(Surface.X));
     Connectivity(options.Connectivity.RegionMapping == Region,:) = repmat(ThisRegionColour, [sum(options.Connectivity.RegionMapping == Region) 1]);
     ConnectedRegions = find(options.Connectivity.weights(Region,:));
     ConnectedRegions = setdiff(ConnectedRegions,Region);
     for k = 1:length(ConnectedRegions),
       Connectivity(options.Connectivity.RegionMapping == ConnectedRegions(k),:) = repmat(ConnectedRegionColour*(options.Connectivity.weights(Region,ConnectedRegions(k))-MinW)./(MaxW-MinW), ...
         [sum(options.Connectivity.RegionMapping == ConnectedRegions(k)) 1]);
     end
 
    %Plot for this Region
     set(SurfaceHandle, 'FaceVertexCData', Connectivity);
     title(SurfaceAxes, ['Region:  ' options.Connectivity.NodeStr{Region}], 'interpreter', 'none');
     home
     newdirection = input(['Current scroll direction is ' num2str(direction) ', select new direction [Next = 1; Previous = -1]: ']);
     if ~isempty(newdirection),
       direction = newdirection;
     end
     Region = Region+direction;
   end

end  %SurfaceConnectivity()