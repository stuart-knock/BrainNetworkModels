%% Implements Equations A1-A8 (Corticothalamic Model of Robinson, Rennie, Wright), 
% with a spatial term added to A2, from (see ./docs):                                          
% M. Breakspear, etal (2005), Cerebral Cortex.
% "A Unifying Explanation of Primary Generalized Seizures Through Nonlinear
% Brain Modeling and Bifurcation Analysis".
%
% ARGUMENTS:
%            x (1,NumberOfNodes) -- State variable 
%            xt(1,NumberOfNodes) -- State variable 
%            dx(1,NumberOfNodes) -- State variable 
%            y (1,NumberOfNodes) -- State variable 
%            dy(1,NumberOfNodes) -- State variable 
%            z (1,NumberOfNodes) -- State variable 
%            zt(1,NumberOfNodes) -- State variable 
%            dz(1,NumberOfNodes) -- State variable 
%            w (1,NumberOfNodes) -- State variable 
%            dw(1,NumberOfNodes) -- State variable 
%            P -- Structure containing parameters
%                .Theta_e -- (V) Mean neuronal threshold for Excitatory cortical population. 
%                .Theta_s -- (V) Mean neuronal threshold for specific thalamic population. 
%                .Theta_r -- (V) Mean neuronal threshold for reticular thalamic population.
%                .sigma_e -- (V) Threshold variability for Excitatory cortical population.
%                .sigma_s -- (V) Threshold variability for specific thalamic population.
%                .sigma_r -- (V) Threshold variability for reticular thalamic population.
%                .Qmax    -- Maximum firing rate
%                .v       -- (m/s) Conduction velocity
%                .r_e     -- (m) Mean range of axons
%                .gamma_e -- (/s) Ratio of conduction velocity to mean range of axons v/r_e
%                .alfa   -- (/s) Inverse decay time of membrane potential... 
%                .btta    -- (/s) Inverse rise time of membrane potential... 
%                .nu_ee   -- (V) Excitatory corticocortical gain/coupling
%                .nu_ei   -- (V) Inhibitory corticocortical gain/coupling
%                .nu_es   -- (V) Specific thalamic nuclei to cortical gain/coupling
%                .nu_se   -- (V) Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
%                .nu_sr   -- (V) Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
%                .nu_sn   -- (V) Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
%                .nu_re   -- (V) Excitatory cortical to thalamic reticular nucleus gain/coupling
%                .nu_rs   -- (V) Specific to reticular thalamic nuclei gain/coupling
%
%                .LapOp   -- Laplacian operator, discrete approximation. 
%                .Delta_x -- (m) distance between nodes (patches of brain) at cortex (effective coupling strength)... enters through Laplacian operator
% 
%
% OUTPUT: 
%     Fx (1,NumberOfNodes) -- Derivative of state variable phi_e
%     Fdx(1,NumberOfNodes) -- Second derivative of state variable phi_e
%     Fy (1,NumberOfNodes) -- Derivative of state variable V_e
%     Fdy(1,NumberOfNodes) -- Second derivative of state variable V_e
%     Fz (1,NumberOfNodes) -- Derivative of state variable V_s
%     Fdz(1,NumberOfNodes) -- Second derivative of state variable V_s 
%     Fw (1,NumberOfNodes) -- Derivative of state variable V_r
%     Fdw(1,NumberOfNodes) -- Second derivative of state variable V_r
%
% USAGE:
%{
   

%}
%
% MODIFICATION HISTORY:
%     SAK(24-11-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function [Fx Fdx Fy Fdy Fz Fdz Fw Fdw] = BRRW(x,xt,dx,y,dy,z,zt,dz,w,dw,k,P)

 SigYe = Sigma(y,P.Qmax,P.Theta_e,P.sigma_e);
 
 Fx = dx;
 Fdx = P.gamma_e.^2 .* (SigYe - x) - 2*P.gamma_e .*dx + P.v.^2 .* (x*P.LapOp);
 Fy = dy;
 Fdy = P.axb.*(P.nu_ee.*x  + P.nu_ei.*SigYe + P.nu_es.*Sigma(zt,P.Qmax,P.Theta_s,P.sigma_s)       - y) - (P.apb).*dy;
 Fz = dz;
 Fdz = P.axb.*(P.nu_se.*xt + P.nu_sr.*Sigma(w,P.Qmax,P.Theta_r,P.sigma_r) + P.nu_sn.*P.phi_n(k,:) - z) - (P.apb).*dz;
 Fw = dw;
 Fdw = P.axb.*(P.nu_re.*xt + P.nu_rs.*Sigma(z,P.Qmax,P.Theta_s,P.sigma_s)                         - w) - (P.apb).*dw;

end % function BRRW()

% 
% % Run Cortex on connectivity network with CorticoThalamicModel and then
% % Run Cortex and thalamus with the explicit cortico-thalmic network...
% 
% %External stimulus, coupling and waveform...
% % nu_sn
% % phi_n
% 
% %Numerical approximation to the spatial laplacian
% %SpaLap
% %spatial separation alon cortical surface
% %Delta_x  
% 
% %tau = t_0/2 %corticothalamic delay...
% 
% % dx => d phi/dt
% %  x => phi 
% % dy => d Ve/dt
% %  y => Ve
% % dz => d Vs/dt
% %  z => Vs
% % dw => d Vr/dt
% %  w => Vr
% %%
% 
% %EC -- Parameter values
% defaults.Theta_e = 0.015;  %(V)  - Mean neuronal threshold for Excitatory cortical population. 
% defaults.Theta_s = 0.015;  %(V)  - Mean neuronal threshold for specific thalamic population. 
% defaults.Theta_r = 0.015;  %(V)  - Mean neuronal threshold for reticular thalamic population.
% defaults.sigma_e = 0.006;  %(V)  - Threshold variability for Excitatory cortical population.
% defaults.sigma_s = 0.006;  %(V)  - Threshold variability for specific thalamic population.
% defaults.sigma_r = 0.006;  %(V)  - Threshold variability for reticular thalamic population.
% defaults.Qmax = 250.0;     %     - Maximum firing rate
% defaults.v   = 10.00;      %(m/s)- Conduction velocity
% defaults.r_e =  0.08;      %(m)  - Mean range of axons
% defaults.gamma_e = v/r_e;  %(/s) - Ratio of conduction velocity to mean range of axons
% defaults.alfa = 60.0;     %(/s) - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
% defaults.btta  = 4.0*alfa;%(/s) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
% defaults.Qs = 0.10;
% defaults.Qr = 0.10;
% defaults.nu_ee = 17.0e-4;  %(V)  - Excitatory corticocortical gain/coupling
% defaults.nu_ei =-18.0e-4;  %(V)  - Inhibitory corticocortical gain/coupling
% defaults.nu_es = 12.0e-4;  %(V)  - Specific thalamic nuclei to cortical gain/coupling
% defaults.nu_se = 10.0e-4;  %(V)  - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
% defaults.nu_sr =-10.0e-4;  %(V)  - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
% defaults.nu_sn = 10.0e-4;  %(V)  - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
% defaults.nu_re =  4.0e-4;  %(V)  - Excitatory cortical to thalamic reticular nucleus gain/coupling
% defaults.nu_rs =  2.0e-4;  %(V)  - Specific to reticular thalamic nuclei gain/coupling
% 
% %As a 1st approx: take mean of distances to nearest neighbour for all nodes
% %options.RemoveThalamus = true;
% %[w delay NodeStr Position] = GetConnectivity(ThisMatrix,options)
% %for n=1:length(Position), aaa = dis(Position.', Position(n,:).'); bbb(1,n) = min(aaa(aaa~=0)); end
% %defaults.Delta_x = mean(bbb);
% defaults.Delta_x = 0.130; %(m) distance between nodes (patches of brain) at cortex (effective coupling strength)... enters through Laplacian operator
% 
% 
% %% 
%  SpaLap = onedee(NumberOfNodes,3);
% 
% %% 
%  axb = alfa.*btta;
%  apb = alfa+btta;
%
%  zt => z(t-tau,:)
%  xt => phi_e(t-tau,:)

%
%  For ordering on the ring, calc dis() to a node... ?prob. pick frontal or
%  Occipital? then sort on the resulting dis, take every second invert
%  order of one set and stick bac ktogether...
%
%
%
%

%
%