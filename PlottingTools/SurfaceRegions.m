%% Colour the cortical surface by region. 
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
       ThisSurface = 'reg13';
       load(['Surfaces' filesep 'Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles');  % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals'
       tr = TriRep(Triangles, Vertices);

       options.Connectivity.WhichMatrix = 'O52R00_IRP2008';
       options.Connectivity.hemisphere = 'both';
       options.Connectivity.RemoveThalamus = true;
       options.Connectivity = GetConnectivity(options.Connectivity)
        
       load(['Surfaces' filesep 'RegionMapping_' ThisSurface '_O52R00_IRP2008.mat'])
       options.Connectivity.RegionMapping = RegionMapping;

       [ThisFigure SurfaceHandle] = SurfaceRegions(tr, options)

%}
%
% MODIFICATION HISTORY:
%     SAK(13-01-2011) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ThisFigure SurfaceHandle] = SurfaceRegions(Surface, options, ThisColourMap)
%% Set any argument that weren't specified
 if nargin < 3,
   ThisColourMap = 'RegionColours74';
 end
 
 
%% Data info
 NumberOfRegions = length(unique(options.Connectivity.RegionMapping));
 
 
%% Display info
 ThisScreenSize = get(0,'ScreenSize');
 FigureWindowSize = ThisScreenSize + [ThisScreenSize(3)./4 ,ThisScreenSize(4)./16, -ThisScreenSize(3)./2 , -ThisScreenSize(4)./8];
   
 
%% Initialise figure  
 ThisFigure = figure;
 set(ThisFigure,'Position',FigureWindowSize);

 load(ThisColourMap); 
 colormap(RegionColours)
 
%%% RegionLabels = cellfun(@(x) x(2:end), options.Connectivity.NodeStr(1:end/2), 'UniformOutput', false);
  
%% Colour Surface by Region
 SurfaceHandle = patch('Faces', Surface.Triangulation(1:1:end,:) , 'Vertices', Surface.X, ...
   'Edgecolor','interp', 'FaceColor', 'interp', 'FaceVertexCData', options.Connectivity.RegionMapping.'); %
 material dull
 
 %title(['???'], 'interpreter', 'none');
 xlabel('X (mm)');
 ylabel('Y (mm)');
 zlabel('Z (mm)');
 
 step = (length(options.Connectivity.NodeStr)-1) / length(options.Connectivity.NodeStr);
 colorbar('YTick', 0.5:step:(length(options.Connectivity.NodeStr)-1), 'YTickLabel', options.Connectivity.NodeStr, 'Ylim', [0, length(options.Connectivity.NodeStr)-1]);
 
 daspect([1 1 1])
%keyboard                       

     

end  %SurfaceRegions()