%% Approximates local coupling on triangulated surface, based on the 
% subtraction of two Gaussian distributions. ie G1 - G2
%
% ARGUMENTS:
%           tr -- Surface as a TriRep object  
%           Neighbourhood -- The N-ring to truncate approximation.
%
% OUTPUT: 
%           LocalCoupling -- Nearest neighbours, value is 1/degree of 
%                            vertex.
%
% REQUIRES:
%           GetLocalSurface() -- extracts sub-region of surface.
%
% USAGE:
%{    

       load('Cortex_213.mat', 'Vertices', 'Triangles'); % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals'
       tr = TriRep(Triangles, Vertices); % Convert to TriRep object

       [LocalCoupling] = NearestNeighbourCoupling(tr);
%}
%
% MODIFICATION HISTORY:
%     SAK(24-11-2010) -- Original: from MeshLaplacian().
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [LocalCoupling] = NearestNeighbourCoupling(tr, Neighbourhood)
%% Set defaults for any argument that weren't specified
 if nargin<4,
   Neighbourhood = 1; %for spalloc()
 end

%% Sizes and preallocation
 AverageNeighboursPerVertex = [7; 20; 43; 75; 117; 170]; %TODO: figure out the right recursive function for this...
 AverageNeighboursPerVertex = AverageNeighboursPerVertex(Neighbourhood);
 NumberofVertices = length(tr.X);

 LocalCoupling = spalloc(NumberofVertices, NumberofVertices, AverageNeighboursPerVertex*NumberofVertices);

 
%% Do The Stuff
 for i = 1:NumberofVertices,
   [LocalVertices, ~, GlobalVertexIndices] = GetLocalSurface(tr, i, Neighbourhood);
   
   NumberOfNearestNeighbours = size(LocalVertices, 1) - 1;
   
   %
   LocalCoupling(GlobalVertexIndices(2:end),i) = 1.0 / NumberOfNearestNeighbours;
   
 end