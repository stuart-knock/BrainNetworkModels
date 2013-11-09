%% Calculates Discrete Laplacian on triangulated surface.
%
% Belkinetal2008 "Discrete Laplace Operator On Meshed Surface"
%
% ARGUMENTS:
%           TR -- Surface as a TriRep object
%           Neighbourhood -- The N-ring to truncate approximation.  
%           AverageNeighboursPerVertex -- <description>
%
% OUTPUT: 
%           LapOp -- Discrete approximation to Laplace-Beltrami operator.
%           Convergence -- <description>
%
% REQUIRES:
%           dis() -- euclidean distance.
%           GetLocalSurface() -- extracts sub-region of surface.
%           perform_fast_marching_mesh() -- Calculates geodesic distances 
%                                           between vertices on a mesh 
%                                           surface.
%
% USAGE:
%{
       ThisSurface = 'reg13';
       load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles'); % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals' 
       tr = TriRep(Triangles, Vertices);     % Convert to TriRep object
       load(['SummaryInfo_Cortex_' ThisSurface '.mat'], 'meanEdgeLength'); %

       [LapOp, Convergence] = MeshLaplacian(tr, 8, meanEdgeLength);

       %Plot to check, ratio max outer ring / dominant contribution, the
       %closer to zero these values are the better.
       figure, plot(Convergence ./ max(LapOp))
%}
%
% MODIFICATION HISTORY:
%     SAK(19-11-2010) -- Original: from DiscreteLaplacianTriangulation().
%     SAK(17-05-2011) -- Changed to use geodesic distance function, 
%                        perform_fast_marching_mesh(), instead of the graph
%                        path-length based function, MeshDistance().
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [LapOp, Convergence] = MeshLaplacian(TR, Neighbourhood, MeanEdgeLength)  
%% Set defaults for any argument that weren't specified
 if nargin<2,
   Neighbourhood = 8; %for spalloc()
 end
 
 
%% Sizes and preallocation
 NumberofVertices = length(TR.X);
 AverageNeighboursPerVertex = 342; %for spalloc() %FIXME: Need a principaled way to approximate this...

 LapOp = spalloc(NumberofVertices,NumberofVertices,AverageNeighboursPerVertex*NumberofVertices);

 
%% Belkin etal... but truncated to the N-ring 
 %
 if nargin<3,
   SurfaceEdges = edges(TR);
   NumberOfEdges = length(SurfaceEdges);
   EdgeLengths = zeros(1,NumberOfEdges);
   for k = 1:NumberOfEdges,
     EdgeLengths(1,k) = dis(TR.X(SurfaceEdges(k,1),:).', TR.X(SurfaceEdges(k,2),:).');
   end
   MeanEdgeLength = mean(EdgeLengths);
 end
 
 % NOTE: 'h' needs to be set such that the Nth ring contributes ~ 0...
 h = MeanEdgeLength * Neighbourhood/4;
 h4 = h * 4; %QUERY: should it be h^2 so exp(...) is dimensionless???
 
 C1 = 1/(4*pi*h^2);
 
 Convergence = zeros(1,NumberofVertices);
 for i = 1:NumberofVertices,
   [LocalVertices, LocalTriangles, GlobalVertexIndices, ~, nRing] = GetLocalSurface(TR, i, Neighbourhood);
   LocalTriangleU = LocalVertices(LocalTriangles(:,2),:) - LocalVertices(LocalTriangles(:,1),:);
   LocalTriangleV = LocalVertices(LocalTriangles(:,3),:) - LocalVertices(LocalTriangles(:,1),:);
   
   LocalTriangleArea = sqrt(sum(cross(LocalTriangleU,LocalTriangleV).^2, 2))./2;
   
   %Get distance to vertices in neighbourhood of current vertex
   DeltaX = perform_fast_marching_mesh(LocalVertices, LocalTriangles, 1);
   DeltaX = DeltaX(2:end).';
   
   %
   NumberOfTriangles = zeros(1,length(LocalVertices)-1);
   AreaOfTriangles   = zeros(1,length(LocalVertices)-1);
   for k=1:length(LocalVertices)-1,
     NumberOfTriangles(k) = sum(LocalTriangles(:)==(k+1)); %of each vertex in our local patch of surface
     [TrIndi, ~] = find(LocalTriangles==(k+1));
     AreaOfTriangles(k) = mean(LocalTriangleArea(TrIndi));
   end
   
   %
   LapOp(GlobalVertexIndices(2:end),i) = C1 * AreaOfTriangles./3 .* NumberOfTriangles .* exp(- DeltaX.^2 ./h4);
   %NOTE: the 1/h^2 in C1 has the role of  division by dx^2,  as it corresponds to an effective
   %      neighbourhood considered by the Laplacian. ?THINK THIS IS TRUE?
   %      So don't do: LapOp(GlobalVertexIndices(2:end),i) = LapOp(GlobalVertexIndices(2:end),i).' ./ DeltaX.^2;
   
   %TODO: Add check of outer ring values, if > critical value then increase neighbourhood...
   Convergence(1,i) = max(LapOp(GlobalVertexIndices((end-nRing(1,Neighbourhood)+1):end),i));
   
   LapOp(i,i) = -sum(LapOp(:,i));
 end
       
 

end %function MeshLaplacian()
