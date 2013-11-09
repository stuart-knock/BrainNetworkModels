%% Finds and removes pinched off pieces surface, these can be caused
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

function [Vertices Triangles IdentifiedPinchedOffVertices] = RemovePinchedOffSurface(Vertices, Triangles, MaxSteps)   
%% Set any argument that weren't specified
 if nargin<3,
   MaxSteps = 6; %1, Often suffis; 3, almost always; 6, very safe  
 end

%% Find pinched surface
 Check = TriRep(Triangles, Vertices);
 SurfaceEdges = edges(Check);
 TrianglesPerEdge = edgeAttachments(Check, SurfaceEdges);
 TrianglesPerEdge = cellfun(@length, TrianglesPerEdge);

 ProblemEdges = find(TrianglesPerEdge==4); 
 NumberOfProblemEdges = length(ProblemEdges);
 %keyboard
 if isempty(ProblemEdges)
     return
 end
 
%keyboard
 
%% Get associated triangles and their vertices
 ProblemEdgeTriangles  = edgeAttachments(Check, SurfaceEdges(ProblemEdges,:));
 ProblemEdgesCell = num2cell(SurfaceEdges(ProblemEdges,:));
 ProblemEdgeVertices = reshape(Check.Triangulation([ProblemEdgeTriangles{:}], :).', 3*4, NumberOfProblemEdges);
 ProblemEdgeVertices = num2cell(ProblemEdgeVertices, 1);
%keyboard 
%% For each edge only keep 4 vertices that aren't the edge
 ProblemEdgeVertices = cellfun(@(x,y) x(x~=y), ProblemEdgeVertices.', ProblemEdgesCell(:,1), 'UniformOutput',false);
 ProblemEdgeVertices = cellfun(@(x,y) x(x~=y), ProblemEdgeVertices,   ProblemEdgesCell(:,2), 'UniformOutput',false);

%keyboard
%% For each edge, MaxSteps one rings from origin, try each of the 4 ProblemEdgeVertices vertices in turn, try each one stepping until vertex set bounded 
 PinchedOffVertices = [];
 IdentifiedPinchedOffVertices = false(size(ProblemEdges));
 for ThisEdge = 1:NumberOfProblemEdges,           %Each edge
  %Within pinched off region TheseVertices should be bounded, but outside
  %it should continue to grow....
  StepsFromOrigin = 0;
  TryingVertex = 0;
  while ~IdentifiedPinchedOffVertices(ThisEdge),  %PinchedOffVertices not identified
    if ~mod(StepsFromOrigin,MaxSteps),            %Initial or having gone MaxSteps
      StepsFromOrigin = 0;                        %reset 
      TryingVertex = TryingVertex+1;              %Try next problem vertex  
      if TryingVertex>3, %Two are of the main surface and two are pinched off.
        break
      end
      TheseVertices = ProblemEdgeVertices{ThisEdge}(TryingVertex);
      NumberOfTheseVertices = 1;
    end
    StepsFromOrigin = StepsFromOrigin+1;
    
    TrIndices   = vertexAttachments(Check,TheseVertices);
    newVertices = unique(Check.Triangulation([TrIndices{:}],:));    %find vertecies that make up that set of triangles
 
    newVertices((newVertices==ProblemEdgesCell{ThisEdge,1}) | (newVertices==ProblemEdgesCell{ThisEdge,2})) = [];%Exclude the ProblemEdgeVertices so that if we started in the pinched off surface we'll stay there
    
    TheseVertices = unique([TheseVertices ; newVertices]);
    
    NumberOfPreviousVertices = NumberOfTheseVertices;
    NumberOfTheseVertices = size(TheseVertices,1);
    
    if NumberOfTheseVertices == NumberOfPreviousVertices,
      IdentifiedPinchedOffVertices(ThisEdge) = true;
      PinchedOffVertices = [PinchedOffVertices ; TheseVertices];
    end
  end
  
 end
 
%keyboard

   
%% Remove them
 PinchedOffVertices = unique(PinchedOffVertices); %Pinched off surface can contain pinched off surface...
 %PinchedOffVertices  = sort(PinchedOffVertices); 
 PinchedOffTriangles = vertexAttachments(Check, PinchedOffVertices);
 PinchedOffTriangles = unique([PinchedOffTriangles{:}]);
 
 Triangles(PinchedOffTriangles,:) = [];
 Vertices(PinchedOffVertices,:)   = [];
 
 for n=size(PinchedOffVertices,1):-1:1,
   Triangles(Triangles>PinchedOffVertices(n)) = Triangles(Triangles>PinchedOffVertices(n))-1;
 end


end %function ()