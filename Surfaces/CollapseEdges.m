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
%     SAK(30-09-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Vertices Triangles NeedsToBeRunAgain] = CollapseEdges(tr, MinimumEdgeLength, MaximumNumber, EdgesToCollapse)   
%% Set any argument that weren't specified
 if nargin < 2,
    MinimumEdgeLength = 0.5; %mm
 end
 
 Vertices  = tr.X;
 Triangles = tr.Triangulation;
 
 if nargin < 4,
   SurfaceEdges = edges(tr);
   NumberOfEdges = length(SurfaceEdges);
   
   %% Find edges to collapse
   EdgeLengths = zeros(1,NumberOfEdges);
   for k = 1:NumberOfEdges,
     EdgeLengths(1,k) = dis(tr.X(SurfaceEdges(k,1),:).',tr.X(SurfaceEdges(k,2),:).');
   end
   [sEL,iEL] = sort(EdgeLengths);
   
   Short  = find(sEL>MinimumEdgeLength, 1);
   if nargin >= 3,
     Short = min([Short MaximumNumber]);
   end
   EdgesToCollapse = SurfaceEdges(iEL(1:Short),:);
   
 end
 
 InitialNumberOfPossibleEdgesToCollapse = size(EdgesToCollapse,1);
 
 disp(['Going to try and collapse ' num2str(InitialNumberOfPossibleEdgesToCollapse) ' edges...'])
 
%% Exclude edges sharing triangles

 %UGLY HACK to avoid, but not correct, edges which have pinched off part of
 %the surface...
 TrianglesPerEdge = edgeAttachments(tr, EdgesToCollapse);
 TrianglesPerEdge = cellfun(@length, TrianglesPerEdge);
 EdgesToCollapse = EdgesToCollapse(TrianglesPerEdge==2,:);
 
 TrianglesToRemove = edgeAttachments(tr, EdgesToCollapse); %find pairs of  triangles connected to the long edges

 matTrianglesToRemove = cell2mat(TrianglesToRemove);

 NonConflictingEdges = [];
 for k = 1:size(matTrianglesToRemove,1),
   if ~any(ismember(matTrianglesToRemove(k,:), matTrianglesToRemove(NonConflictingEdges,:))),
     NonConflictingEdges = [NonConflictingEdges k];
   end
 end
 
 EdgesToCollapse = EdgesToCollapse(NonConflictingEdges,:);
%keyboard 
 
%% Exclude edges sharing vertices

% % %  [~, NonConflictingEdges] = unique(EdgesToCollapse(:,2),'first');
% % %  NonConflictingEdges = sort(NonConflictingEdges);

 NonConflictingEdges = [];
 for k = 1:size(EdgesToCollapse,1),
   if ~any(ismember(EdgesToCollapse(k,:), EdgesToCollapse(NonConflictingEdges,:))),
     NonConflictingEdges = [NonConflictingEdges k];
   end
 end
 
 EdgesToCollapse = EdgesToCollapse(NonConflictingEdges,:);
 
%% 
 
 TrianglesToRemove = edgeAttachments(tr, EdgesToCollapse);
 
 if size(EdgesToCollapse,1)<InitialNumberOfPossibleEdgesToCollapse,
   disp(['There are conflicting edges so only removing ' num2str(size(EdgesToCollapse,1)) ' edges...'])
   disp('RERUN WITH SAME ''MinimumEdgeLength'' TO COMPLETE Collapse...')
   NeedsToBeRunAgain = true;
 else
   NeedsToBeRunAgain = false;
 end
%keyboard

%% Colapse them
 % Remove triangles
   Triangles([TrianglesToRemove{:}],:) = [];
   
   % map remaining triangles to one of the two points
   for k = 1:size(EdgesToCollapse,1),
     Triangles(Triangles==EdgesToCollapse(k,2)) = EdgesToCollapse(k,1);
   end
   sETC2 = sort(EdgesToCollapse(:,2),'descend');
   for k = 1:size(EdgesToCollapse,1),
     Triangles(Triangles>sETC2(k)) = Triangles(Triangles>sETC2(k))-1;
   end
   
   % move the retained vertex to the centre of the collapsed edge 
   Vertices(EdgesToCollapse(:,1),:) = (Vertices(EdgesToCollapse(:,1),:) + Vertices(EdgesToCollapse(:,2),:))./2;
   
   % remove the unused vertex and associated surface normal vector.
   Vertices(EdgesToCollapse(:,2),:)     = [];
   %VertexNormals(EdgeToCollapse(2),:) = [];
   
  %% Clean up if we made an issolated vertex
    [Vertices Triangles] = RemoveIssolatedVertices(Vertices, Triangles);
% % %   % finds them and
% % %    tr = TriRep(Triangles, Vertices); 
% % %    TrianglesPerVertex = vertexAttachments(tr, (1:size(Vertices,1)).');
% % %    TrianglesPerVertex = cellfun(@length, TrianglesPerVertex);
% % %    IssolatedVertices  = find(TrianglesPerVertex<3);
% % %    
% % %    while ~isempty(IssolatedVertices),
% % %      IssolatedTriangles = vertexAttachments(tr, IssolatedVertices);
% % %      IssolatedTriangles = [IssolatedTriangles{:}].';
% % %      
% % %      %removes them
% % %      disp(['Made ' num2str(length(IssolatedVertices)) ' issolated vertices... removing them.']);
% % %      Triangles(IssolatedTriangles,:) = [];
% % %      Vertices(IssolatedVertices,:)   = [];
% % %      
% % %      for n=size(IssolatedVertices,1):-1:1,
% % %        Triangles(Triangles>IssolatedVertices(n)) = Triangles(Triangles>IssolatedVertices(n))-1;
% % %      end
% % %      
% % %      %recheck
% % %      tr = TriRep(Triangles, Vertices);
% % %      TrianglesPerVertex = vertexAttachments(tr, (1:size(Vertices,1)).');
% % %      TrianglesPerVertex = cellfun(@length, TrianglesPerVertex);
% % %      IssolatedVertices  = find(TrianglesPerVertex<3);
% % %    end
     
  %% Clean up if we pinched off part of the surface
   [Vertices Triangles] = RemovePinchedOffSurface(Vertices, Triangles);
   
end %function CollapseEdges()




