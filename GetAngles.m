%% Calculates the inner angles of all the triangles which make up a
% tesselated surface.
%
% ARGUMENTS:
%           vertices -- <description>
%           triangles -- <description>
%
% OUTPUT: 
%           angles -- <description>
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(12-03-2010) -- Original.
%     SAK(08-10-2010) -- Corrected bug in cycle through angles, had been
%                        calculating angles at vertices 1, 2 and 1 again...
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function angles=GetAngles(vertices,triangles)
%% 
 NumberofTriangles = length(triangles);

%% 
 angles = zeros(NumberofTriangles,3);
 for tt = 1:NumberofTriangles,
   ThisTriangle = triangles(tt,:);
   for ta = 1:3,
     ThisAngle = circshift(ThisTriangle, [0 -(ta-1)]);
     angles(tt,ta) = acos(dot((vertices(ThisAngle(2),:)-vertices(ThisAngle(1),:)) ./ sqrt(sum((vertices(ThisAngle(2),:)-vertices(ThisAngle(1),:)).^2)), ...
                              (vertices(ThisAngle(3),:)-vertices(ThisAngle(1),:)) ./ sqrt(sum((vertices(ThisAngle(3),:)-vertices(ThisAngle(1),:)).^2))));
     
   end
 end

%% 

end %function GetAngles()



