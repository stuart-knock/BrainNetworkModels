%% Split surface edges
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
%     SAK(30-09-2010) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Vertices Triangles NeedsToBeRunAgain] = SplitEdges(tr, MaximumEdgeLength, MaximumNumber, EdgesToSplit)   
%% Set any argument that weren't specified
 if nargin < 2,
   MaximumEdgeLength = 5; %Reasonable assuming mm & ~30000+ vertices
 end
 
 Vertices  = tr.X;
 NumberOfVertices = size(tr.X,1);
 Triangles = tr.Triangulation;
   
 if nargin < 4,
   SurfaceEdges = edges(tr);
   NumberOfEdges = length(SurfaceEdges);

%% Find edges to split
   EdgeLengths = zeros(1,NumberOfEdges); 
   for k = 1:NumberOfEdges,
     EdgeLengths(1,k) = dis(tr.X(SurfaceEdges(k,1),:).',tr.X(SurfaceEdges(k,2),:).');
   end
   [sEL,iEL] = sort(EdgeLengths);
   
   Long  = find(sEL>MaximumEdgeLength, 1); 
   if nargin >= 3,
     Long = max([Long (size(SurfaceEdges,1)-MaximumNumber+1)]); 
   end
   EdgesToSplit = SurfaceEdges(iEL(Long:end),:);
 
 end
 
 InitialNumberOfPossibleEdgesToSplit = size(EdgesToSplit,1);
 
 disp(['Going to try and split ' num2str(InitialNumberOfPossibleEdgesToSplit) ' edges...'])
 
%% Exclude edges sharing triangles
 TrianglesToSplit = edgeAttachments(tr, EdgesToSplit); %find pairs of  triangles connected to the long edges

 matTrianglesToSplit = cell2mat(TrianglesToSplit);
 
% % %  [~, NonConflictingTriangles] = unique(matTrianglesToSplit); %Identify 
% % %  
% % %  NonConflictingEdges = false(size(EdgesToSplit));
% % %  NonConflictingEdges(NonConflictingTriangles) = true;
% % %  NonConflictingEdges = sum(NonConflictingEdges,2)==2;

 NonConflictingEdges = [];
 for k = size(matTrianglesToSplit,1):-1:1,
   if ~any(ismember(matTrianglesToSplit(k,:), matTrianglesToSplit(NonConflictingEdges,:))),
     NonConflictingEdges = [k NonConflictingEdges];
   end
 end
 
 EdgesToSplit = EdgesToSplit(NonConflictingEdges,:);
 
 TrianglesToSplit = edgeAttachments(tr, EdgesToSplit);
 
 if size(EdgesToSplit,1)<InitialNumberOfPossibleEdgesToSplit
   disp(['There are conflicting edges so only splitting ' num2str(size(EdgesToSplit,1)) ' edges...'])
   if nargout <3, 
     disp('RERUN WITH SAME ''MaximumEdgeLength'' TO COMPLETE SPLITTING...')
   end
   NeedsToBeRunAgain = true;
 else
   NeedsToBeRunAgain = false;
 end
%keyboard
%% Split them
 % Add new vertices half way along the long edges
 NewVertices = (tr.X(EdgesToSplit(:,1),:) + tr.X(EdgesToSplit(:,2),:))./2; 
 Vertices = [Vertices ; NewVertices];
 NewVerticesIndices = NumberOfVertices+(1:size(NewVertices,1));
 
 %Add 4 small triangles per split edge
 AdjacentVertices = zeros(size(EdgesToSplit));
 for k = 1:size(EdgesToSplit,1),
   AdjacentVertices(k,1) = setdiff(Triangles(TrianglesToSplit{k}(1),:), EdgesToSplit(k,:));
   AdjacentVertices(k,2) = setdiff(Triangles(TrianglesToSplit{k}(2),:), EdgesToSplit(k,:));
 end
 
 %% FIXME: POSSIBLY BROKEN... RETHINK TO ENSURE OF CORRECT TRIANGLE SENSE.
 %% NOTE: IF THE BUG ISN'T HERE THEN NEED TO FIND IT AS WE DEFINATELY HAVE
 %% INCORRECTLY ORIENTED TRIANGLES IN THE CURRENT CORTEX TESSELATIONS...
 %% FIXED A TRIANGLE ORIENTATION BUG IN  RemoveSmallDegree3(), WHICH MAY
 %% HAVE BEEN THE SOURCE OF THE PROBLEM...
 %NB. ordering below creates triangle sense that should preserve surface
 %    orientation, ie. normals will point "out" from cortex... 
 NewTriangles = [reshape(repmat(NewVerticesIndices, [4 1]),           1, 4*size(NewVertices,1)).'  ...
                 reshape([EdgesToSplit AdjacentVertices(:,[2 1]) ].', 1, 4*size(EdgesToSplit,1)).'     ...
                 reshape([AdjacentVertices(:,[1 2]) EdgesToSplit].',  1, 4*size(EdgesToSplit,1)).' ];
               
%% keyboard  
 %Remove pairs of long edge triangles they replaced
 Triangles([TrianglesToSplit{:}],:) = [];
 
 Triangles = [Triangles ; NewTriangles];

% % %  %Correct triangles added with the wrong sense... OBVIOUSLY, IT WOULD BE BETTER NOT TO ADD THEM IN FIRST PLACE. 
% % %  NumberOfTriangles = size(tr.Triangulation,1);
% % %  Newtr = TriRep(Triangles, Vertices);
% % %  OrigTriangleNormals = faceNormals(tr, [TrianglesToSplit{:}].'); 
% % %  NewTrianglesNormals = faceNormals(Newtr, ((NumberOfTriangles-length([TrianglesToSplit{:}]))+(1:(4*size(NewVertices,1)))).');
% % %  Orig2NewTriInd = reshape([1:2:length([TrianglesToSplit{:}]) ; 2:2:length([TrianglesToSplit{:}]) ; 2:2:length([TrianglesToSplit{:}]) ; 1:2:(length([TrianglesToSplit{:}])) ], 1,size(NewTriangles,1));
% % %  % sign(dot(NewTriangleNormals.', OrigTriangleNormals(Orig2NewTriInd,:).'))
 
end %function SplitEdges()