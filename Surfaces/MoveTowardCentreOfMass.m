%% Moves all vertices of a surface toward the centre of mass of their
%% surrounding vertices.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Vertices = MoveTowardCentreOfMass(tr,Fraction)
%% Set any argument that weren't specified
 if nargin < 2,
    Fraction = 0.5; %
 end

 TrIndices = vertexAttachments(tr,(1:length(tr.X)).');
 
 Vertices = zeros(size(tr.X));
 
 for k = 1:length(TrIndices),
   Offset = mean(tr.X(tr.Triangulation(TrIndices{k},:), :)) - tr.X(k,:);
   Vertices(k,:) = tr.X(k,:) + Fraction*Offset; 
 end
 
 
end %function MoveTowardCentreOfMass()
