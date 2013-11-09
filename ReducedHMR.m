%% Implements Equation 3 (Reduced system of HMR) from (see ./docs):  
% Stefanescu RA, Jirsa VK (2008), Neurons. PLoS Comput Biol 4(11).
% "A Low Dimensional Description of Globally Coupled Heterogeneous Neural 
% Networks of Excitatory and Inhibitory".
% 
%
% ARGUMENTS:
%            x(NumberOfModes,NumberOfNodes) -- State variable Xi
%            y(NumberOfModes,NumberOfNodes) -- State variable Eta
%            z(NumberOfModes,NumberOfNodes) -- State variable Tau
%            w(NumberOfModes,NumberOfNodes) -- State variable Alpha
%            v(NumberOfModes,NumberOfNodes) -- State variable Beta
%            u(NumberOfModes,NumberOfNodes) -- State variable Gamma
%            P -- Structure containing parameters
%                 .A(NumberOfModes,NumberOfModes)     -- 
%                 .B(NumberOfModes,NumberOfModes)     -- 
%                 .C(NumberOfModes,NumberOfModes)     --    
%                 .a_i(NumberOfModes,NumberOfNodes)   --  
%                 .e_i(NumberOfModes,NumberOfNodes)   --     
%                 .b_i(NumberOfModes,NumberOfNodes)   -- 
%                 .f_i(NumberOfModes,NumberOfNodes)   --   
%                 .c_i(NumberOfModes,NumberOfNodes)   --   
%                 .h_i(NumberOfModes,NumberOfNodes)   -- 
%                 .IE_i(NumberOfModes,NumberOfNodes)  -- 
%                 .II_i(NumberOfModes,NumberOfNodes)  --   
%                 .d_i(NumberOfModes,NumberOfNodes)   --   
%                 .p_i(NumberOfModes,NumberOfNodes)   --   
%                 .m_i(NumberOfModes,NumberOfNodes)   --  
%                 .n_i(NumberOfModes,NumberOfNodes)   --  
%                 .r     --  
%                 .s     -- 
%                 .K11   -- Excitatory to excitatory coupling. 
%                 .K12   -- Excitatory to inhibitory coupling.
%                 .K21   -- Inhibitory to excitatory coupling.
%
% OUTPUT: 
%     Fx(NumberOfModes,NumberOfNodes) -- Derivative of state variable Xi
%     Fy(NumberOfModes,NumberOfNodes) -- Derivative of state variable Eta
%     Fz(NumberOfModes,NumberOfNodes) -- Derivative of state variable Tau
%     Fw(NumberOfModes,NumberOfNodes) -- Derivative of state variable Alpha
%     Fv(NumberOfModes,NumberOfNodes) -- Derivative of state variable Beta
%     Fu(NumberOfModes,NumberOfNodes) -- Derivative of state variable Gamma
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

function [Fx Fy Fz Fw Fv Fu] = ReducedHMR(x, y, z, w, v, u, P)

 Fx = y - P.a_i.*x.^3 + P.b_i.*x.^2 - z + P.K11.*(P.A*x - x) - P.K12.*(P.B*w - x) + P.IE_i;
 Fy = P.c_i - P.d_i.*x.^2 - y;
 Fz = P.r.*P.s.*x - P.r.*z - P.m_i;
 Fw = v - P.e_i.*w.^3 + P.f_i.*w.^2 - u + P.K21.*(P.C*x - w)                      + P.II_i;
 Fv = P.h_i - P.p_i.*w.^2 - v;
 Fu = P.r.*P.s.*w - P.r.*u - P.n_i;

end % function ReducedHMR()
