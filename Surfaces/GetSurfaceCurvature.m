%% Get a rough estimate of surface curvature at vertices
%
% ARGUMENTS:
%           <arg1> -- <description>
%
% OUTPUT: 
%           <output1> -- <description>
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(30-09-2010) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SurfaceCurvature = GetSurfaceCurvature(tr,VertexNormals,TheseVertices)
%% Set any argument that weren't specified 
 if nargin < 3,
    TheseVertices= 1:size(tr.X, 1); %Calculate for all vertices
 end
 
 %% Do the  stuff...
     SurfaceCurvature = zeros(1,length(TheseVertices));
     for k = 1:length(TheseVertices),
       i = TheseVertices(k);
       TrIndi = vertexAttachments(tr, i); 
       
       VertDirectConnecti = unique(tr.Triangulation([TrIndi{:}],:));       %find vertecies that make up that set of triangles
       VertDirectConnecti = VertDirectConnecti(VertDirectConnecti~=i);     %remove vertex i from that set
%keyboard
       Delta_x = repmat(tr.X(i,:),[length(VertDirectConnecti) 1]) - tr.X(VertDirectConnecti,:);
       MeanVectorToNeighbours = mean(Delta_x,1);
       
       SurfaceCurvature(1,k) = dot(MeanVectorToNeighbours, VertexNormals(i,:));
       %SAME%SurfaceCurvature(1,k) = mean(dot(Delta_x, repmat(VertexNormals(i,:), [length(VertDirectConnecti) 1]), 2));
     end
 

%% 

end %function GetSurfaceCurvature()
