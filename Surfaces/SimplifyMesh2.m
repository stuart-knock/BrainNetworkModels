%% Downsample a surface by collapsing edges
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
%     SAK(05-10-2010) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DownsampleTo = 2^16; % DownsampleTo = 2^15; % DownsampleTo = 2^14; % DownsampleTo = 2^13; % DownsampleTo = 2^12; %

function [Vertices Triangles] = SimplifyMesh2(tr, DownsampleTo, OnlyEdgesLessThan)   
%% Set any argument that weren't specified
 if nargin < 2,
   DownsampleTo = 2^nextpow2(length(tr.X)/(2+eps)); %next lower power of 2
 end
 if nargin < 3,
   OnlyEdgesLessThan = 4; %mm
 end
 
%%
 SurfaceEdges = edges(tr);
 NumberOfEdges = length(SurfaceEdges);
 Vertices  = tr.X;
 NumberOfVertices = size(tr.X,1);
 Triangles = tr.Triangulation;
   
%% Find edges to collapse
 EdgeLengths = zeros(1,NumberOfEdges); 
 for k = 1:NumberOfEdges,
   EdgeLengths(1,k) = dis(tr.X(SurfaceEdges(k,1),:).',tr.X(SurfaceEdges(k,2),:).');
 end
 [sEL,iEL] = sort(EdgeLengths);

 Short  = find(sEL>OnlyEdgesLessThan, 1); %mm
 PossibleEdgesToCollapse = SurfaceEdges(iEL(1:Short),:);
 
 if size(PossibleEdgesToCollapse,1)<(NumberOfVertices-DownsampleTo),
   keyboard
   error(['BrainNetworkModels:' mfilename ':ConflictingOptions'],['The combination of DownsampleTo=' num2str(DownsampleTo) ' and OnlyEdgesLessThan=' num2str(OnlyEdgesLessThan) ' is too restrictive.'])
 end
 
 SelectionOrder = randperm(Short);

%% 
 NeedsToBeRunAgain = true;
 EdgesToCollapse = PossibleEdgesToCollapse(SelectionOrder(1:(NumberOfVertices-DownsampleTo)),:);
 CurrentNextEdge = (NumberOfVertices-DownsampleTo)+1;
 Attempts = 0;
 while NeedsToBeRunAgain,
   Attempts = Attempts+1;
   %% Exclude edges sharing triangles
   
 disp(['Trying to collapse ' num2str(size(EdgesToCollapse,1)) ' edges...'])
 
 %UGLY HACK to avoid, but not correct, edges which have pinched off part of
 %the surface...
 TrianglesPerEdge = edgeAttachments(tr, EdgesToCollapse);
 TrianglesPerEdge = cellfun(@length, TrianglesPerEdge);
 EdgesToCollapse = EdgesToCollapse(TrianglesPerEdge==2,:);
   
   TrianglesToRemove = edgeAttachments(tr, EdgesToCollapse); %find pairs of  triangles connected to the long edges
 %keyboard  
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
   NonConflictingEdges = [];
   for k = 1:size(EdgesToCollapse,1),
     if ~any(ismember(EdgesToCollapse(k,:), EdgesToCollapse(NonConflictingEdges,:))),
       NonConflictingEdges = [NonConflictingEdges k];
     end
   end
   
   EdgesToCollapse = EdgesToCollapse(NonConflictingEdges,:);
   
   %% MISSING AN EXCLUSION CRITERIA... 
   
   %% Check that we've found enough edges to collapse
   if size(EdgesToCollapse,1)<(NumberOfVertices-DownsampleTo),
     NeedsToBeRunAgain = true;
     disp(['There are conflicting edges, so far only have ' num2str(size(EdgesToCollapse,1)) ' edges...'])
     disp(['Have used ' num2str(CurrentNextEdge) ' of ' num2str(Short) ' available edges...'])
     NeedThisManyMoreEdges = (NumberOfVertices-DownsampleTo)-size(EdgesToCollapse,1); %TODO: NEED TO STOP THIS GETTING SMALL AS MULTIPLE COMPLETE LOOPS TO GET THE LAST COUPLE OF EDGES IS A PAIN...
     if Short<(CurrentNextEdge+NeedThisManyMoreEdges),
       %keyboard
       error(['BrainNetworkModels:' mfilename ':ConflictingOptions'],['The combination of DownsampleTo=' num2str(DownsampleTo) ' and OnlyEdgesLessThan=' num2str(OnlyEdgesLessThan) ' is too restrictive.'])
     end
     EdgesToCollapse = [EdgesToCollapse ; PossibleEdgesToCollapse(SelectionOrder(CurrentNextEdge:(CurrentNextEdge+NeedThisManyMoreEdges-1)),:)];
     CurrentNextEdge = (CurrentNextEdge+NeedThisManyMoreEdges);
   else
     NeedsToBeRunAgain = false;
     disp('Have a full set of edges... removing them.')
   end
 end
 

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
   
   
  %% Clean up if we made issolated vertices
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
   
end %function SimplifyMesh2()