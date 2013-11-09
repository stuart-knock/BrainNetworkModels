%% Finds and removes issolated vertices on the surface, these can be caused
% by edge collapse operations on the surface.
%TODO: Add comments.
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
%     SAK(21-10-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Vertices Triangles] = RemoveIssolatedVertices(Vertices, Triangles)

  % finds them and
   tr = TriRep(Triangles, Vertices); 
   TrianglesPerVertex = vertexAttachments(tr, (1:size(Vertices,1)).');
   TrianglesPerVertex = cellfun(@length, TrianglesPerVertex);
   IssolatedVertices  = find(TrianglesPerVertex<3);
%keyboard   
   while ~isempty(IssolatedVertices),
     IssolatedTriangles = vertexAttachments(tr, IssolatedVertices);
     IssolatedTriangles = [IssolatedTriangles{:}].';
     
     %removes them
     disp(['Made ' num2str(length(IssolatedVertices)) ' issolated vertices... removing them.']);
     Triangles(IssolatedTriangles,:) = [];
     Vertices(IssolatedVertices,:)   = [];
     
     for n=size(IssolatedVertices,1):-1:1,
       Triangles(Triangles>IssolatedVertices(n)) = Triangles(Triangles>IssolatedVertices(n))-1;
     end
     
     %recheck
     tr = TriRep(Triangles, Vertices);
     TrianglesPerVertex = vertexAttachments(tr, (1:size(Vertices,1)).');
     TrianglesPerVertex = cellfun(@length, TrianglesPerVertex);
     IssolatedVertices  = find(TrianglesPerVertex<3);
   end
     
end %function RemoveIssolatedVertices()