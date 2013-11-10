%% Plot only part of a tessellated surface, return the local surface.
%
% ARGUMENTS:
%           TR -- A matlab TriRep object of the global surface.
%           FocalVertex -- Index of the vertex on which to centre the plot.
%           Neighbourhood -- Number of "rings" to include in plot.
%           normals -- An Nx3 array specifying either Triangle or Vertex normals.
%                      Where N equals either the number of Vertices or Triangles.
%
% OUTPUT: 
%          LocalSurfaceFigureHandle -- <description>
%
% REQUIRES: 
%          TriRep -- A Matlab object, not yet available in Octave.
%          GetLocalSurface() -- Returns a local patch of surface of the 
%                               neighbourhood around a vertex. Is in the
%                               Surfaces directory.
%
% USAGE:
%{    
    ThisSurface = 'reg13';
    load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals');
    tr = TriRep(Triangles, Vertices);
    
    LocalSurfaceFigureHandleVnorm = PlotLocalSurface(tr, 42, 3, VertexNormals);
    %or
    LocalSurfaceFigureHandleTnorm = PlotLocalSurface(tr, 42, 3, TriangleNormals);
   
%}
%
% MODIFICATION HISTORY:
%     SAK(22-07-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function LocalSurfaceFigureHandle = PlotLocalSurface(TR, FocalVertex, Neighbourhood, normals)  
  %% Set defaults for any argument that weren't specified
  if nargin<3,
    Neighbourhood = 1;
  end
  if nargin<4,
    normals = zeros(size(TR.X));
  end
  
  NumberOfVertices = size(TR.X, 1);
  NumberOfTriangles = size(TR.Triangulation, 1);
  NumberOfNormals = size(normals, 1);
  
%% Get the local patch of surface
  switch NumberOfNormals,
    case NumberOfVertices
      [LocalVertices, LocalTriangles, GlobalVertexIndices] = GetLocalSurface(TR, FocalVertex, Neighbourhood);
      LocalNormals = normals(GlobalVertexIndices, :);
    case NumberOfTriangles
      [LocalVertices, LocalTriangles, ~, GlobalTriangleIndices] = GetLocalSurface(TR, FocalVertex, Neighbourhood);
      LocalNormals = normals(GlobalTriangleIndices, :);
      LocalCentres = incenters(TR, GlobalTriangleIndices);
    otherwise
      msg = 'The normals should be the size of either triangles or vertices...';
      error(['BrainNetworkModels:PlottingTools:' mfilename ':WrongNumberOfNormals'], msg);
  end

%% Plot...
  LocalSurfaceFigureHandle = figure;
    patch('Faces', LocalTriangles, 'Vertices', LocalVertices, ...
          'Edgecolor',[0.5 0.5 0], 'FaceColor', [0.3 0.3 0.3], 'FaceAlpha',0.3); %
    hold on 
    scatter3(LocalVertices(:,1), LocalVertices(:,2), LocalVertices(:,3), 'g.')
    scatter3(TR.X(FocalVertex,1), TR.X(FocalVertex,2), TR.X(FocalVertex,3), 'r.')
    
    switch NumberOfNormals,
      case NumberOfVertices
        plot3([LocalVertices(:,1).' ; LocalVertices(:,1).'+LocalNormals(:,1).'], ...
              [LocalVertices(:,2).' ; LocalVertices(:,2).'+LocalNormals(:,2).'], ...
              [LocalVertices(:,3).' ; LocalVertices(:,3).'+LocalNormals(:,3).'], 'b')
      case NumberOfTriangles
        scatter3(LocalCentres(:,1), LocalCentres(:,2), LocalCentres(:,3), 'b.')
        plot3([LocalCentres(:,1).' ; LocalCentres(:,1).'+LocalNormals(:,1).'], ...
              [LocalCentres(:,2).' ; LocalCentres(:,2).'+LocalNormals(:,2).'], ...
              [LocalCentres(:,3).' ; LocalCentres(:,3).'+LocalNormals(:,3).'], 'b')
    end
    daspect([1 1 1])

end %function PlotLocalSurface()
