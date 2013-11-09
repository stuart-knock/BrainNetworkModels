%% Collect summary information for a surface.
%
% ARGUMENTS:
%           tr -- matlab TriRep object, representing the surface. 
%
% OUTPUT: 
%           SurfaceSummaryInfo -- NumberOfVertices
%                                 NumberOfTriangles
%                                 minEdgeLength
%                                 maxEdgeLength
%                                 meanEdgeLength
%                                 TotalSurfaceArea
%                                 minTriangleArea
%                                 maxTriangleArea
%                                 meanTriangleArea
%                                 minDegree
%                                 maxDegree
%                                 medianDegree
%
% REQUIRES: 
%          dis() --
%          GetSurfaceAreas() -- 
%
% USAGE:
%{
      ThisSurface = '213';
      load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles');  % Contains: 'Vertices', 'Triangles' , 'VertexNormals', 'TriangleNormals'
      tr = TriRep(Triangles, Vertices); % Convert to TriRep object
      SurfaceSummaryInfo = GetSurfaceSummaryInfo(tr);
      
      %Save for later use
      save(['SummaryInfo_' ThisSurface '.mat'], '-struct', 'SurfaceSummaryInfo');
%}
%
% MODIFICATION HISTORY:
%     SAK(12-01-2011) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SurfaceSummaryInfo] = GetSurfaceSummaryInfo(tr)
  
 %% NumberOf...
 SurfaceSummaryInfo.NumberOfVertices = size(tr.X,1);
 SurfaceSummaryInfo.NumberOfTriangles = size(tr.Triangulation,1);
 
 
 %% Lengths
 SurfaceEdges = edges(tr);
 NumberOfEdges = length(SurfaceEdges);
 EdgeLengths = zeros(1,NumberOfEdges);
 for k = 1:NumberOfEdges,
   EdgeLengths(1,k) = dis(tr.X(SurfaceEdges(k,1),:).', tr.X(SurfaceEdges(k,2),:).');
 end
 
 SurfaceSummaryInfo.minEdgeLength = min(EdgeLengths);
 SurfaceSummaryInfo.maxEdgeLength = max(EdgeLengths);
 SurfaceSummaryInfo.meanEdgeLength = mean(EdgeLengths);
 
  
 %% Areas  
 [TriangleAreas, SurfaceSummaryInfo.TotalSurfaceArea] = GetSurfaceAreas(tr);
 SurfaceSummaryInfo.minTriangleArea = min(TriangleAreas);
 SurfaceSummaryInfo.maxTriangleArea = max(TriangleAreas);
 SurfaceSummaryInfo.meanTriangleArea = mean(TriangleAreas);
    
 
 %% Degree
 TrianglesPerVertex = vertexAttachments(tr, (1:SurfaceSummaryInfo.NumberOfVertices).');
 Degree = cellfun(@length, TrianglesPerVertex);
 SurfaceSummaryInfo.minDegree = min(Degree);
 SurfaceSummaryInfo.maxDegree = max(Degree);
 SurfaceSummaryInfo.medianDegree = median(Degree);


end %function GetSurfaceSummaryInfo()
