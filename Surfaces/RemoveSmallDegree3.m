%% Find and remove degree 3 vertices where the area of the 3 small
% triangles and thus the large triangle that will replace them is samller 
% than a specified area.
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
%     SAK(22-10-2010) -- Original.
%     SAK(14-02-2011) -- Fixed bug where the added triangle had the wrong 
%                        orientation sense relative to surrounding surface. 
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Vertices Triangles] = RemoveSmallDegree3(tr,MaximumArea)
%% Set any argument that weren't specified
 if nargin < 2,
   MaximumArea = 1; %Reasonable assuming mm^2 & ~100000+ vertices
 end
 
%% Get Area
 TriangleU = tr.X(tr.Triangulation(:,2),:) - tr.X(tr.Triangulation(:,1),:);
 TriangleV = tr.X(tr.Triangulation(:,3),:) - tr.X(tr.Triangulation(:,1),:);
 TriangleArea = sqrt(sum(cross(TriangleU,TriangleV).^2, 2))./2;
 
%% Finds them 
 NumberOfVertices = size(tr.X,1);
 TrianglesPerVertex = vertexAttachments(tr, (1:NumberOfVertices).');
 NumberOfTrianglesPerVertex = cellfun(@length, TrianglesPerVertex);
 
 VerticesToRemove = find(NumberOfTrianglesPerVertex==3);

%% Exclude too big
 TrianglesToRemove = vertexAttachments(tr, VerticesToRemove);
 ReplacementTriangleArea = sum(TriangleArea(cell2mat(TrianglesToRemove)),2);
 VerticesToRemove(ReplacementTriangleArea>MaximumArea) = [];
 
%% Get associated little triangles     
 TrianglesToRemove = vertexAttachments(tr, VerticesToRemove);
 
%% Create new big triangles
 TrianglesToAdd = zeros(length(TrianglesToRemove),3);
 for k=1:length(TrianglesToRemove),
   TheseVertices = tr.Triangulation(TrianglesToRemove{k},:);
   
   %Select initial two vertices in order to ensure correct triangle sense
   BasisTriangle = find(TheseVertices(:,1)==VerticesToRemove(k),1,'first');
   if ~isempty(BasisTriangle),
     FirstTwo = TheseVertices(BasisTriangle,2:3);
   else
     BasisTriangle = find(TheseVertices(:,3)==VerticesToRemove(k),1,'first');
     if ~isempty(BasisTriangle),
       FirstTwo = TheseVertices(BasisTriangle,1:2);
     else
       BasisTriangle = find(TheseVertices(:,2)==VerticesToRemove(k),1,'first');
       if ~isempty(BasisTriangle),
         FirstTwo = TheseVertices(BasisTriangle,[3 1]);
       else
         error(['BrainNetworkModels:' mfilename ':VertexNotInSet'],'This shouldn''t happen -- the vertex to be removed doesn''t seem to be in th etrianles to be removed...');
       end
     end
   end
   
   TrianglesToAdd(k,:) = [FirstTwo  setdiff(TheseVertices(:), [FirstTwo  VerticesToRemove(k)])];    
 end
     

%% Remove degree 3 vertex, replace 3 small triangles with 1 big    
 
 Vertices = tr.X;
 Triangles = tr.Triangulation;
 
 %Remove central vertex from each triplet
 Vertices(VerticesToRemove,:) = [];

 %Remove triplet of little triangles 
 Triangles([TrianglesToRemove{:}],:) = [];
 
 %Add big triangles in their place
 Triangles = [Triangles ; TrianglesToAdd];
 
 %Correct for removed vertices
 for n=size(VerticesToRemove,1):-1:1,
   Triangles(Triangles>VerticesToRemove(n)) = Triangles(Triangles>VerticesToRemove(n))-1;
 end

 %keyboard
 
end % function RemoveSmallDegree3()