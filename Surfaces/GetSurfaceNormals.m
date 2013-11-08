%% Get triangle normals and estimate vertex normals
%TODO: Add comments.
% ARGUMENTS:
%           <arg1> -- <description>
%
% OUTPUT: 
%           <output1> -- <description>
%
% USAGE:
%{
      Angles = GetAngles(Vertices,Triangles);
      tr = TriRep(Triangles, Vertices);
      [VertexNormals TriangleNormals] = GetSurfaceNormals(tr,Angles);
%}
%
% MODIFICATION HISTORY:
%     SAK(30-09-2010) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [VertexNormals TriangleNormals] = GetSurfaceNormals(tr,Angles)   

 NumberOfVertices = size(tr.X, 1);
 NumberOfTriangles = size(tr.Triangulation, 1);

%keyboard 
%%
 TriangleNormals = faceNormals(tr, (1:NumberOfTriangles).');
 SurrondingFaces = vertexAttachments(tr, (1:NumberOfVertices).'); 
 
 %TrianglesPerVertex = cellfun(@length, SurrondingFaces);
 %SurrondingFaceVertices = {tr.Triangulation(SurrondingFaces{:},:)};
 %SurrondingFaceVertices = cellfun(@(x,y) y(x,:), SurrondingFaces, tr.Triangulation, 'UniformOutput',false)
 %Circshift to put k in position 2 for each set of SurrondingFaceVertices
 %Normalise 1->2 and 2->3 to unit length 
 %Cross product normalised pairs of inout edges 1->2 X 2->3
 %Average and normalise to a unit normal for each vertex...
%%%keyboard 
 VertexNormals = zeros(NumberOfVertices,3); 
 for k=1:NumberOfVertices, 
   AngleMask = tr.Triangulation(SurrondingFaces{k},:) == k;
   TheseAngles = Angles(SurrondingFaces{k}, :);
   TheseAngles = TheseAngles(AngleMask);
   AngleScaling = repmat(TheseAngles ./ sum(TheseAngles), [1 3]);
   VertexNormals(k,:) = mean(AngleScaling .* TriangleNormals(SurrondingFaces{k},:)); %Scale by angle subtended. 
   VertexNormals(k,:) = VertexNormals(k,:) ./ sqrt(sum(VertexNormals(k,:).^2));      %Normalise to unit vectors.
 end
 
%%% NOTE: FOR SOME REASON THIS DOESN'T SEEM TO GIVE THE SAME SENSE MANUAL 
%%%       VERSION ABOVE... BUT NOT CONSISTENTLY, IE DON'T SIMPLY ALWAYS 
%%%       POINT IN OPPOSITE DIRECTION. -VE RESULTS IN MORE CONSISTENCY.
%%%       Also, has unwanted side effect of ploting the patches... 
% % % %     SAK(16-02-2011) -- Changed to use patch properties rather than manual
% % % %                        calc of VertexNormals, much faster. No longer
% % % %                        require Angles arg...
% % % SurfaceHandle = patch('Faces', tr.Triangulation, 'Vertices', tr.X);
% % % VertexNormals2 = get(SurfaceHandle, 'VertexNormals');
% % % VertexNormals2 = -VertexNormals2 ./ repmat(sqrt(sum(VertexNormals2.^2, 2)), [1 3]);
%% 

end %function GetSurfaceNormals()
