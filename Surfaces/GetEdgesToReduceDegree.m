%% <Description>
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
%     SAK(18-10-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [NonRedundantEdges] = GetEdgesToReduceDegree(tr, DownsampleTo, OnlyEdgesLessThan)   
%% Set any argument that weren't specified
 if nargin < 2,
   DownsampleTo = 6; %
 end
 if nargin < 3,
   OnlyEdgesLessThan = 42; %mm
 end
 
%%
 NumberOfVertices = size(tr.X,1);
 TrianglesPerVertex = vertexAttachments(tr, (1:NumberOfVertices).');
 NumberOfTrianglesPerVertex = cellfun(@length, TrianglesPerVertex);
 
 HighDegreeVertexIndices = find(NumberOfTrianglesPerVertex > DownsampleTo);
 SurrondingFaces = TrianglesPerVertex(HighDegreeVertexIndices);
 
 OneRingEdges = cell(size(SurrondingFaces));
 for k = 1:size(SurrondingFaces,1),
   OneRingEdges{k} = tr.Triangulation(SurrondingFaces{k},:);
   OneRingEdges{k} = OneRingEdges{k}.';
   OneRingEdges{k}(OneRingEdges{k}==HighDegreeVertexIndices(k)) = [];
   OneRingEdges{k} = reshape(OneRingEdges{k}, 2, NumberOfTrianglesPerVertex(HighDegreeVertexIndices(k))).';
 end
  
 %EdgesOfHighDegreeVertices = ;
   
%% Find edges to split
 ShortestOneRingEdge = zeros(1,size(OneRingEdges,1)); 
 ShortestOneRingEdgeLength = zeros(1,size(OneRingEdges,1)); 
 for k = 1:size(OneRingEdges,1),
   [ShortestOneRingEdgeLength(1,k) ShortestOneRingEdge(1,k)] = min(dis(tr.X(OneRingEdges{k}(:,1),:).',tr.X(OneRingEdges{k}(:,2),:).'));
 end
 %keyboard
 EdgesToCollapse = zeros(size(OneRingEdges,1),2);
 for k = 1:size(OneRingEdges,1),
 EdgesToCollapse(k,:) = OneRingEdges{k}(ShortestOneRingEdge(1,k),:);
 end
 
 EdgesToCollapse(ShortestOneRingEdgeLength>=OnlyEdgesLessThan,:) = [];
 
 if ~isempty(EdgesToCollapse),
   
   %Sort their vertices, vertex order in edges is unimportant but this was
   %the easiest way I could see to remove duplicates, need coffeeeee...
   EdgesToCollapse = sort(EdgesToCollapse, 2);
   
   %Through away repeated edges
   NonRedundantEdges = zeros(size(EdgesToCollapse));
   NonRedundantEdges(1,:) = EdgesToCollapse(1,:); %1st must be good.
   for k = 2:size(EdgesToCollapse,1),                               %All our edges
     if ~ismember(EdgesToCollapse(k,:), NonRedundantEdges, 'rows'), %We don't already have this edge
       NonRedundantEdges(k,:) = EdgesToCollapse(k,:);               %Take a copy
     end
   end
   NonRedundantEdges(NonRedundantEdges(:,1)==0,:) = [];             %Get rid of holes we didn't fill.
   
 else
   NonRedundantEdges = [];
 end
  
end %function GetEdgesToReduceDegree()