%% Calculate area of triangles making up a surface
%
% ARGUMENTS:
%           tr -- matlab TriRep object, representing the surface. 
%           TheseTriangles -- Default is whole surface, use this to specify 
%                             only a subset of triangles.
%
% OUTPUT: 
%           TriangleAreas -- Area of triangles that make up th e surface,
%                            by default the whole surface.
%           TotalSurfaceArea -- Sum of area of triangles, by default the
%                               whole surface. 
%
% REQUIRES: 
%          none
%
% USAGE:
%{
      load('Cortex_213.mat', 'Vertices', 'Triangles'); % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals' 
      tr = TriRep(Triangles, Vertices); % Convert to TriRep object
      [TriangleAreas, TotalSurfaceArea] = GetSurfaceAreas(tr);
%}
%
% MODIFICATION HISTORY:
%     SAK(28-11-2010) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [TriangleAreas, TotalSurfaceArea] = GetSurfaceAreas(tr, TheseTriangles)
%% Set any argument that weren't specified 
 if nargin < 2,
    TheseTriangles= 1:size(tr.Triangulation, 1); %Calculate whole surface.
 end
 
 %% Do the  stuff...
  TriangleU = tr.X(tr.Triangulation(TheseTriangles,2),:) - tr.X(tr.Triangulation(TheseTriangles,1),:);
  TriangleV = tr.X(tr.Triangulation(TheseTriangles,3),:) - tr.X(tr.Triangulation(TheseTriangles,1),:);
  
  TriangleAreas = sqrt(sum(cross(TriangleU,TriangleV).^2, 2))./2;
     
  if nargout>1,
    TotalSurfaceArea = sum(TriangleAreas);
  end
%% 

end %function GetSurfaceAreas()