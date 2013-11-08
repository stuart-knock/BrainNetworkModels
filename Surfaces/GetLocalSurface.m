%% Return a local patch of surface of the neighbourhood around a vertex.
%
% ARGUMENTS:
%           TR -- TriRep object for the lobal surface
%           FocalVertex -- <description>
%           Neighbourhood -- <description>
%
% OUTPUT: 
%         LocalVertices  -- <description>
%         LocalTriangles -- <description>
%
% REQUIRES: 
%         none
%         
% USAGE:
%{
      load('Cortex_213.mat', 'Vertices', 'Triangles', 'VertexNormals'); % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals' 
      tr = TriRep(Triangles, Vertices); % Convert to TriRep object
      [LocalVertices LocalTriangles GlobalVertexIndices GlobalTriangleIndices nRing] = GetLocalSurface(tr, 42, 3);    
%}
%
% MODIFICATION HISTORY:
%     SAK(22-07-2010) -- Original.
%     SAK() -- modified from GetLocalSurface() to use Matlabs TriRep
%     SAK(19-11-2010) -- Added calc of nRing, which is a vector specifying 
%                        the number of vertices in each of the nRings from 
%                        1 through to Neighbourhood.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [LocalVertices LocalTriangles GlobalVertexIndices GlobalTriangleIndices nRing] = GetLocalSurface(tr, FocalVertex, Neighbourhood)
%% Set any argument that weren't specified
 if nargin<3,
   Neighbourhood = 1;
 end

%% Do the stuff...
 % Get indices of local vertices and triangles 
 LocalVertices = FocalVertex;
 LocalTriangles = [];
 newVertices = FocalVertex;
 nRing = zeros(1,Neighbourhood);
 for k = 1:Neighbourhood,
   TrIndices = vertexAttachments(tr, newVertices); 
   newTriangles = setdiff(unique([TrIndices{:}].'),                 LocalTriangles);   %
   newVertices  = setdiff(unique(tr.Triangulation(newTriangles,:)), LocalVertices);    %find vertices that make up that set of triangles
   nRing(1,k) = length(newVertices);
   
   LocalTriangles = [LocalTriangles ; newTriangles];
   LocalVertices  = [LocalVertices  ; newVertices];
 end
 
  if nargout>2,
    GlobalVertexIndices   = LocalVertices;
  end
  if nargout>3,
    GlobalTriangleIndices = LocalTriangles;
  end
 
 LocalTriangles = tr.Triangulation(LocalTriangles,:);
 % Map triangles from "vertices" indices to "LocalVertices" indices 
 temp = zeros(size(LocalTriangles));
 for j = 1:length(LocalVertices) 
   temp(LocalTriangles==LocalVertices(j)) = j;
 end
 LocalTriangles = temp;
 LocalVertices = tr.X(LocalVertices,:);
  
%% 

end %function GetLocalSurface()