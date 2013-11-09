%% Generate a mesh surface for a unit sphere 
%
% ARGUMENTS:
%           NumberOfVertices -- <description>
%
% OUTPUT: 
%           UnitSphere -- <description>
%
% REQUIRES:
%          MoveTowardCenUnitSphereeOfMass() -- <description>
%          %%%dis() -- <description>
%          %%%SplitEdges() -- <description>
%
% USAGE:
%{
      UnitSphere = MakeMeshUnitSphere();

      SurfaceMesh(UnitSphere);
%}
%
% MODIFICATION HISTORY:
%     SAK(31-03-2011) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function UnitSphere=MakeMeshUnitSphere(NumberOfVertices)
%% Set any argument that weren't specified
 if nargin < 1,
   NumberOfVertices = 1024;
 end
%% Do the stuff...

 %Generate random vertices, unit distance from the origin
 Vertices = rand(NumberOfVertices,3) - 0.5;
 Vertices = Vertices./ repmat(sqrt(sum(Vertices.^2,2)), [1 3]);
 
 DT = DelaunayTri(Vertices(:,1), Vertices(:,2), Vertices(:,3)); % NOTE: The returned "Triangles" will be 4 sided polygons...
 [Triangles Vertices] = freeBoundary(DT);
 UnitSphere = TriRep(Triangles, Vertices);
 
 %Regularise
 for k=1:3,
   Vertices = MoveTowardCentreOfMass(UnitSphere,0.5);
   UnitSphere = TriRep(Triangles, Vertices);
 end

%NOTE: In addition to the below, we'll then need to collapse to restore
%      the number of Vertices in the UnitSphere to NumberOfVertices...
%      Probably becomes too messy, this was meant to be a simple function.
%
% % %  %Get edges and determine their length
% % %  SurfaceEdges = edges(UnitSphere);
% % %  NumberOfEdges = length(SurfaceEdges);
% % %  EdgeLengths = zeros(1,NumberOfEdges); 
% % %  for k = 1:NumberOfEdges,
% % %    EdgeLengths(1,k) = dis(UnitSphere.X(SurfaceEdges(k,1),:).', UnitSphere.X(SurfaceEdges(k,2),:).');
% % %  end
% % %  [sEL,iEL] = sort(EdgeLengths);
% % %  
% % %  SplitThese = iEL(1:floor(NumberOfVertices./4));
% % %  [Vertices Triangles] = SplitEdges(UnitSphere,0,0,SplitThese);
 
 
 %Renormalise Vertices to unit distance from origin
 Vertices = Vertices./ repmat(sqrt(sum(Vertices.^2,2)), [1 3]);
 UnitSphere = TriRep(Triangles, Vertices);
 
%% 

end %function MakeMeshUnitSphere()