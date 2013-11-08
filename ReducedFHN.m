%% Implements Equation 1 (Reduced system of FHN) from (see ./docs):  
% Stefanescu RA, Jirsa VK (2008), Neurons. PLoS Comput Biol 4(11).
% "A Low Dimensional Description of Globally Coupled Heterogeneous Neural 
% Networks of Excitatory and Inhibitory". 
%
% ARGUMENTS:
%            x(NumberOfModes,NumberOfNodes) -- State variable Xi
%            y(NumberOfModes,NumberOfNodes) -- State variable Eta
%            z(NumberOfModes,NumberOfNodes) -- State variable Alpha
%            w(NumberOfModes,NumberOfNodes) -- State variable Beta
%            P -- Structure containing parameters
%                .A(NumberOfModes,NumberOfModes)     -- 
%                .B(NumberOfModes,NumberOfModes)     -- 
%                .C(NumberOfModes,NumberOfModes)     --   
%                .e_i(NumberOfModes,NumberOfNodes)   --  
%                .f_i(NumberOfModes,NumberOfNodes)   -- 
%                .IE_i(NumberOfModes,NumberOfNodes)  -- 
%                .II_i(NumberOfModes,NumberOfNodes)  --   
%                .m_i(NumberOfModes,NumberOfNodes)   --  
%                .n_i(NumberOfModes,NumberOfNodes)   -- 
%                .b     --
%                .K11   -- Excitatory to excitatory coupling. 
%                .K12   -- Excitatory to inhibitory coupling.
%                .K21   -- Inhibitory to excitatory coupling.
%                .tau   -- Approx Inverse of time-scale separation between 
%                          fast and slow state variables ~1/sqrt()
%
% OUTPUT: 
%     Fx(NumberOfModes,NumberOfNodes) -- Derivative of state variable Xi
%     Fy(NumberOfModes,NumberOfNodes) -- Derivative of state variable Eta
%     Fz(NumberOfModes,NumberOfNodes) -- Derivative of state variable Alpha
%     Fw(NumberOfModes,NumberOfNodes) -- Derivative of state variable Beta
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(24-11-2009) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fx Fy Fz Fw] = ReducedFHN(x, y, z, w, P)

 Fx = P.tau.*(x - P.e_i.*(x.^3./3) - y) + P.K11.*(P.A*x - x) - P.K12.*(P.B*z - x) + P.tau.*P.IE_i;
 Fy = (x - P.b.*y + P.m_i)./P.tau;
 Fz = P.tau.*(z - P.f_i.*(z.^3./3) - w) + P.K21.*(P.C*x - z)                      + P.tau.*P.II_i;
 Fw = (z - P.b.*w + P.n_i)./P.tau;

end % function ReducedFHN()
