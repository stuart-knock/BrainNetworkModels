%% Fitz-Hugh Nagumo model.
%
% ARGUMENTS:
%          x -- Previous state of the slow variable.
%          y -- Previous state of the fast variable.
%          P -- A structure containing the parameter definitions.
%
% OUTPUT: 
%          Fx -- <description>
%          Fy -- <description>
%
% REQUIRES: 
%          none
%
% USAGE:
%{
      %As called from within FHN_heun.m
      [Fx0 Fy0] = FHN(x,y,options.Dynamics);
%}
%
% MODIFICATION HISTORY:
%     SAK(24-11-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fx Fy] = FHN(x,y,P)

  Fx = P.d * P.tau*(y + x - x.^3/3.0);
  Fy = P.d * (P.a - x - P.b*y)./P.tau;

end % function FHN()
