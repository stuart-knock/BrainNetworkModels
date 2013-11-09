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
%     SAK(24-11-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fx Fy] = FHN(x,y,P)

 Fx = P.d * tau*(y + x - x.^3/3);
 Fy = P.d * (P.a - x - P.b*y)./P.tau; 
 
end % function FHN()
