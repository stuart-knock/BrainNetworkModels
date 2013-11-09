%% Find triangles smaller than a specified area
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
%     SAK(15-10-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [LittleTrianglesGlobalIndex LittleTriangleArea LittleTriangles NonRedundantEdges] = GetLittleTriangles(tr,MaximumTriangleArea)
%% Set any argument that weren't specified
 if nargin < 2,
  MaximumTriangleArea = 1; %mm^2
 end

%% Do the stuff...  
  %Get triangle areas
  TriangleU = tr.X(tr.Triangulation(:,2),:) - tr.X(tr.Triangulation(:,1),:);
  TriangleV = tr.X(tr.Triangulation(:,3),:) - tr.X(tr.Triangulation(:,1),:);
  TriangleArea = sqrt(sum(cross(TriangleU,TriangleV).^2, 2))./2;

  %Select those shorter than our criterion 
  [sTA,iTA] = sort(TriangleArea);
  Little = find(sTA>MaximumTriangleArea,1);
  LittleTrianglesGlobalIndex = iTA(1:Little);
  
  LittleTriangleArea = TriangleArea(LittleTrianglesGlobalIndex);
  
  if nargout==2,
    return
  end
  
  %Take a copy of the littlens... 
  LittleTriangles = tr.Triangulation(LittleTrianglesGlobalIndex,:);

  if nargout==3,
    return
  end
  
  %Gather the edges 
  LittleTrianglesEdges = [reshape(circshift(LittleTriangles, [0 1]).', [numel(LittleTriangles) 1])   reshape(LittleTriangles.', [numel(LittleTriangles) 1])];

  %Sort their vertices, vertex order in edges is unimportant but this was 
  %the easiest way I could see to remove duplicates, need coffeeeee... 
  LittleTrianglesEdges = sort(LittleTrianglesEdges, 2);
  
  %Through away repeated edges
  NonRedundantEdges = zeros(size(LittleTrianglesEdges));
  NonRedundantEdges(1:3,:) = LittleTrianglesEdges(1:3,:); %Ordered by triangles, 1st 3 must be good.
  for k = 4:size(LittleTrianglesEdges,1),                               %All our edges
    if ~ismember(LittleTrianglesEdges(k,:), NonRedundantEdges, 'rows'), %We don't already have this edge
      NonRedundantEdges(k,:) = LittleTrianglesEdges(k,:);               %Take a copy
    end
  end
  NonRedundantEdges(NonRedundantEdges(:,1)==0,:) = [];                  %Get rid of wholes we didn't fill.
  
  
end %function GetLittleTriangles()