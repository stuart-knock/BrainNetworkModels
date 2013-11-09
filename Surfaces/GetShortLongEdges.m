%% Find the shortest and longest edge of triangles
%
% ARGUMENTS:
%           <arg1> -- <description>
%
% OUTPUT: 
%           <output1> -- <description>
%
% REQUIRES: 
%           dis() -- Euclidean distance
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

function [ShortestEdgesGlobalIndex LongestEdgesGlobalIndex ShortestEdgesLength LongestEdgesLength] = GetShortLongEdges(tr,TheseTriangles)
%% Set any argument that weren't specified
 if nargin < 2,
  TheseTriangles = 1:length(tr.Triangulation); %
 end

%% Do the stuff...  

  TriLC = tr.Triangulation(TheseTriangles,:);

 %Gather the edges 
  Pairing = [1 2 ; 2 3 ; 3 1]; %
  TheseTrianglesEdges = [reshape(TriLC.', [numel(TriLC) 1]) reshape(circshift(TriLC, [0 -1]).', [numel(TriLC) 1])];
  NumberOfEdges = size(TheseTrianglesEdges,1);

 %Determine their length
  EdgeLengths = zeros(1,NumberOfEdges); 
  for k = 1:NumberOfEdges,
    EdgeLengths(1,k) = dis(tr.X(TheseTrianglesEdges(k,1),:).',tr.X(TheseTrianglesEdges(k,2),:).');
  end
  
 %Regroup by triangle
  EdgeLengthsByTriangle = reshape(EdgeLengths, 3,NumberOfEdges./3); %surface is triangles, each triangle contributes 3 edges...

 %Shortest & Longest by triangle 
  [ShortestEdgesLength ShortestEdges] = min(EdgeLengthsByTriangle);
  [LongestEdgesLength  LongestEdges ] = max(EdgeLengthsByTriangle);
  
 %Map back to TriLC
  ShortestEdges = Pairing(ShortestEdges,:);
  LongestEdges  = Pairing(LongestEdges, :);
  
 %Map back to global indices
  ShortestEdgesGlobalIndex = zeros(size(ShortestEdges,1),2);
  LongestEdgesGlobalIndex  = zeros(size(LongestEdges, 1),2);
  for k = 1:size(ShortestEdges,1),
    ShortestEdgesGlobalIndex(k,:) = TriLC(k, ShortestEdges(k,:));
    LongestEdgesGlobalIndex(k, :) = TriLC(k, LongestEdges(k, :));
  end
  
  
end %function GetShortLongEdges()