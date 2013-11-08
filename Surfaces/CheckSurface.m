%% Checks a surface, identifying isolated vertices, holes and other
% anomalies. Prints a summary of what it finds. If the surface is closed 
% and has no anomalies it just returns empty arrays. 
%
% ARGUMENTS:
%           tr -- the surface as a matlab TriRep object.
%
% OUTPUT: 
%           IsolatedVertices -- Indices of isolated vertices
%           PinchedOff -- Indices of the vertices at either end of the
%                         edge where the surface is pinched off.
%           Holes -- Indices of the vertices at either end of the
%                    edge where there is a hole in the surface, dear liza, dear liza...
%
% REQUIRES: 
%          GetSurfaceSummaryInfo() --
%
% USAGE:
%{
      tr = TriRep(Triangles, Vertices);
      [IsolatedVertices, PinchedOff, Holes] = CheckSurface(tr);
%}
%
% MODIFICATION HISTORY:
%     SAK(06-03-2012) -- Original, from scattered existing scripts.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [IsolatedVertices, PinchedOff, Holes] = CheckSurface(tr)
  IsolatedVertices = [];
  PinchedOff = []; % Identified by vertex indices specifying edge
  Holes = []; % Identified by vertex indices specifying edge
  
  % Basic summary information
   SurfaceSummaryInfo = GetSurfaceSummaryInfo(tr) 
   
   if SurfaceSummaryInfo.minDegree < 3,
    disp('WARNING: THERE ARE ISSOLATED VERTICES...')
    TrianglesPerVertex = vertexAttachments(tr, (1:size(tr.X,1)).');
    TrianglesPerVertex = cellfun(@length, TrianglesPerVertex);
    IsolatedVertices  = find(TrianglesPerVertex<3);
   end
   
   
  % Find issues relative to edges
   SurfaceEdges = edges(tr);
   TrianglesPerEdge = edgeAttachments(tr, SurfaceEdges);
   TrianglesPerEdge = cellfun(@length, TrianglesPerEdge);
   if max(TrianglesPerEdge)>2,
     disp('WARNING: THERE ARE EDGES WITH MORE THAN 2 TRIANGLES, PART OF THE SURFACE IS PINCHED OFF...')
     PinchedOff  = SurfaceEdges(TrianglesPerEdge>2, :);
   end
   if min(TrianglesPerEdge)<2,
     disp('WARNING: FREE BOUNDARIES, THERE ARE HOLES IN THE SURFACE...')
     Holes = SurfaceEdges((TrianglesPerEdge<2), :);
   end
 
end %function CheckSurface()
