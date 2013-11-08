%% Integrates an ensemble of corticothalamis model, 
% connected through a weighted network with time delays.
%
% Implements Equations A1-A8 (Corticothalamic Model of Robinson, Rennie, Wright), 
% with a spatial term added to A2, from (see ./docs):                                          
% M. Breakspear, etal (2005), Cerebral Cortex.
% "A Unifying Explanation of Primary Generalized Seizures Through Nonlinear
% Brain Modeling and Bifurcation Analysis".
%
% Uses Heun method
%
% ARGUMENTS:
%           options -- A structure which can specify the arguments below:
%                     .iters -- Number iterations for the integration
%                     .dt    -- Length of each time step of the integration in milliseconds 
%                     .Theta_e -- (V) Mean neuronal threshold for Excitatory cortical population. 
%                     .Theta_s -- (V) Mean neuronal threshold for specific thalamic population. 
%                     .Theta_r -- (V) Mean neuronal threshold for reticular thalamic population.
%                     .sigma_e -- (V) Threshold variability for Excitatory cortical population.
%                     .sigma_s -- (V) Threshold variability for specific thalamic population.
%                     .sigma_r -- (V) Threshold variability for reticular thalamic population.
%                     .Qmax    -- Maximum firing rate
%                     .v       -- (m/s) Conduction velocity
%                     .r_e     -- (m) Mean range of axons
%                     .gamma_e -- (/s) Ratio of conduction velocity to mean range of axons v/r_e
%                     .alfa   -- (/s) Inverse decay time of membrane potential... 
%                     .btta    -- (/s) Inverse rise time of membrane potential... 
%                     .nu_ee   -- (V s) Excitatory corticocortical gain/coupling
%                     .nu_ei   -- (V s) Inhibitory corticocortical gain/coupling
%                     .nu_es   -- (V s) Specific thalamic nuclei to cortical gain/coupling
%                     .nu_se   -- (V s) Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
%                     .nu_sr   -- (V s) Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
%                     .nu_sn   -- (V s) Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
%                     .nu_re   -- (V s) Excitatory cortical to thalamic reticular nucleus gain/coupling
%                     .nu_rs   -- (V s) Specific to reticular thalamic nuclei gain/coupling
%       
%                     .LapOp   -- Laplacian operator, discrete approximation. 
%                     .Delta_x -- (m) distance between nodes (patches of brain) at cortex (effective coupling strength)... enters through Laplacian operator
% 
%                     .csf   -- Coupling scale factor
%                     .InitialConditions -- Specify a non-default initial 
%                                           state for the random number 
%                                           generators:
%                                       .StateRand  
%                                       .StateRandN  
%                                           And/Or Specify non-random 
%                                           initial conditions:
%                                       .Xi -- must be >= max time delay long 
%                                       .Eta
%                                       .Alpha
%                                       .Beta
%
% OUTPUT: 
%           phi_e  -- 
%           dphi_e -- 
%           V_e    -- 
%           dV_e   -- 
%           V_s    -- 
%           dV_s   -- 
%           V_r    -- 
%           dV_r   -- 
%           t -- vector of time points for which integration was estimated 
%           options
%
% REQUIRES: 
%        BRRW() -- Corticothalamic continuum model function 
%        Sigma() -- Calculates sigmoidal function
%
% USAGE:
%{
      %Specify Connectivity to use
       options.Connectivity.WhichMatrix = 'RM_AC';
       options.Connectivity.invel = 1/7;

      %Specify Dynamics to use
       options.Dynamics.WhichModel = 'BRRW';
       options.Dynamics.BrainState = 'absence';

      %Load default parameters for specified connectivity and dynamics
       options.Connectivity = GetConnectivity(options.Connectivity);
       options.Dynamics = SetDynamicParameters(options.Dynamics);
       options = SetIntegrationParameters(options);
       options = SetDerivedParameters(options);
       options = SetInitialConditions(options);

      %Integrate the network using default options (Network of 38N should take about 3s)
       [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRW_heun(options);
%}
% MODIFICATION HISTORY:
%     VJ/YAR(<dd-mm-yyyy>) -- Original.
%     SAK(27-10-2008) -- Optimise... (speedup ~140x)
%     SAK(04-10-2008) -- Comment/Structure/Generalise.
%     SAK(17-12-2008) -- Incorporated ability to start from Non-random
%                        initial conditions... primarily to allow
%                        continuation of previous run.
%     SAK(19-01-2009) -- Corrected bug I introduced in calculation of W
%                        Corrected noise contribution to be proportional to
%                        sqrt(dt) rather than dt
%     SAK(21-01-2009) -- Modified from fhn_net_rk.m to use heun method for
%                        consistency between solution order for
%                        deterministic and stochastic components...
%     SAK(28-01-2009) -- Save state of random number generators for use
%                        when continuing from previous run
%     SAK(04-09-2009) -- Changed coupling scale factor parameter from c to 
%                        csf, for more straight forward parameter
%                        consitence across functions...
%     SAK(16-09-2009) -- Following discussion with MW implemented delayed
%                        coupling via linear indexing, also made a number
%                        of other minor optimisations... (speedup ~15x)
%     SAK(17-09-2009) -- Default noise => 0. Cleaned up parameter initialisation.
%     SAK(30-11-2009) -- Modified from fhn_net_heun()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRW_heun(options)

%Set RandStream to a state consistent with InitialConditions.
 options.Dynamics.InitialConditions.ThisRandomStream.State = options.Dynamics.InitialConditions.StateRand;
 RandStream.setDefaultStream(options.Dynamics.InitialConditions.ThisRandomStream);

% % % %% Calculate some suitable initial conditions if none were provided
% % %  if ~isfield(options.Dynamics, 'InitialConditions'),
% % %    options.Dynamics.InitialConditions.StateRand  = 5489;
% % %    %Set RandStream to a state consistent with InitialConditions.
% % %    options.Dynamics.InitialConditions.ThisRandomStream = RandStream.create('mt19937ar','seed', options.Dynamics.InitialConditions.StateRand);
% % %    RandStream.setDefaultStream(options.Dynamics.InitialConditions.ThisRandomStream);
% % %    
% % %    options.Dynamics.InitialConditions = BRRW_InitialConditions(Parameters);
% % %  else
% % %    %Set RandStream to a state consistent with InitialConditions.
% % %    ThisRandomStream = RandStream.getDefaultStream;
% % %    ThisRandomStream.State = options.Dynamics.InitialConditions.StateRand;
% % %    RandStream.setDefaultStream(ThisRandomStream);  
% % %  end
% % % %-----------------------------------------------------------------------%

%Check sufficient history was provided
 if options.Integration.maxdelayiters>size(options.Dynamics.InitialConditions.phi_e, 1), %Initialconditions aren't sufficiently long enough
   error(['BrainNetworkModels:' mfilename ':InitialConditionsTooShort'],'The InitialConditions provided do not contain enough data points for the maximum delay of the system...');
 end
 
%Set initial state vectors
 x  = options.Dynamics.InitialConditions.phi_e(end, :);
 dx = options.Dynamics.InitialConditions.dphi_e(end, :);
 y  = options.Dynamics.InitialConditions.V_e(end, :);
 dy = options.Dynamics.InitialConditions.dV_e(end, :);
 z  = options.Dynamics.InitialConditions.V_s(end, :);
 dz = options.Dynamics.InitialConditions.dV_s(end, :);
 w  = options.Dynamics.InitialConditions.V_r(end, :);
 dw = options.Dynamics.InitialConditions.dV_r(end, :);
 
%Initialise array to store   variable, including it's history
 phi_e  = [options.Dynamics.InitialConditions.phi_e((end-options.Integration.maxdelayiters+1):end, :) ; zeros(options.Integration.iters, options.Connectivity.NumberOfNodes)]; 
%Initialise array to store   variable
 dphi_e =                                                                                      zeros(options.Integration.iters, options.Connectivity.NumberOfNodes) ; 
 V_e    =                                                                                      zeros(options.Integration.iters, options.Connectivity.NumberOfNodes) ; 
 dV_e   =                                                                                      zeros(options.Integration.iters, options.Connectivity.NumberOfNodes) ; 
%Initialise array to store   variable, including it's history
 V_s    = [options.Dynamics.InitialConditions.V_s((end-options.Integration.maxdelayiters+1):end, :)   ; zeros(options.Integration.iters, options.Connectivity.NumberOfNodes)]; 
%Initialise array to store   variable
 dV_s   =                                                                                      zeros(options.Integration.iters, options.Connectivity.NumberOfNodes) ; 
 V_r    =                                                                                      zeros(options.Integration.iters, options.Connectivity.NumberOfNodes) ; 
 dV_r   =                                                                                      zeros(options.Integration.iters, options.Connectivity.NumberOfNodes) ; 
%-----------------------------------------------------------------------%

%% Integrate the f... Network Coupling
 
 xhist = zeros(1,options.Connectivity.NumberOfNodes); %need this for when csf = 0...
 xt    = zeros(2,options.Connectivity.NumberOfNodes);
 zt    = zeros(2,options.Connectivity.NumberOfNodes);
%%%keyboard 
 for k = 1:options.Integration.iters
   
  %Calculate coupling term 
   if options.Dynamics.csf~=0,   %Skip it when checking uncoupled dynamics.
     xhist(1,:) = sum(options.Connectivity.weights.*phi_e(options.Integration.lidelay+k), 1);
   end
   xt(1,:) = phi_e(options.Dynamics.CTlidelay+k);
   xt(2,:) = phi_e(options.Dynamics.CTlidelay+k+1);
   zt(1,:) = V_s(options.Dynamics.TClidelay+k);
   zt(2,:) = V_s(options.Dynamics.TClidelay+k+1);
 
   LongRangeCouplingTerm = options.Dynamics.axb.*options.Dynamics.dtcsf.*Sigma(xhist, options.Dynamics.Qmax, options.Dynamics.Theta_e, options.Dynamics.sigma_e); 
  
  %Solve the differential equation (BRRW), using Heun scheme. (see, eg, Mannella 2002 "Integration Of SDEs on a Computer")  
   [Fx0 Fdx0 Fy0 Fdy0 Fz0 Fdz0 Fw0 Fdw0] = BRRW(x, xt(1,:),dx, y, dy, z, zt(1,:),dz, w, dw, k, options.Dynamics);
   x1  = x  + options.Integration.dt*Fx0;
   dx1 = dx + options.Integration.dt*Fdx0;
   y1  = y  + options.Integration.dt*Fy0;
   dy1 = dy + options.Integration.dt*Fdy0 + LongRangeCouplingTerm; %%%???Properly within int: local-homogeneous => nu_ee.*x; Inhomogeneous-Longrange => nu_ee.*Sigma(xhist,Qmax,Theta_e,sigma_e): ???%%%;
   z1  = z  + options.Integration.dt*Fz0;
   dz1 = dz + options.Integration.dt*Fdz0;
   w1  = w  + options.Integration.dt*Fw0;
   dw1 = dw + options.Integration.dt*Fdw0;
  
   [Fx1 Fdx1 Fy1 Fdy1 Fz1 Fdz1 Fw1 Fdw1] = BRRW(x1,xt(2,:),dx1,y1,dy1,z1,zt(2,:),dz1,w1,dw1, k, options.Dynamics);
   nx  =  x + options.Integration.dtt*(Fx0  + Fx1); 
   ndx = dx + options.Integration.dtt*(Fdx0 + Fdx1); 
   ny  =  y + options.Integration.dtt*(Fy0  + Fy1); 
   ndy = dy + options.Integration.dtt*(Fdy0 + Fdy1) + LongRangeCouplingTerm; %%%???Properly within int: local-homogeneous => nu_ee.*x; Inhomogeneous-Longrange => nu_ee.*Sigma(xhist,Qmax,Theta_e,sigma_e): ???%%%
   nz  =  z + options.Integration.dtt*(Fz0  + Fz1); 
   ndz = dz + options.Integration.dtt*(Fdz0 + Fdz1); 
   nw  =  w + options.Integration.dtt*(Fw0  + Fw1); 
   ndw = dw + options.Integration.dtt*(Fdw0 + Fdw1); 

  %Store result of calc in variable for output
   phi_e(options.Integration.maxdelayiters+k,:) = nx;
   dphi_e(k,:) = ndx;
   V_e(k,:)    = ny;
   dV_e(k,:)   = ndy;
   V_s(options.Integration.maxdelayiters+k,:) = nz;
   dV_s(k,:)   = ndz;
   V_r(k,:)    = nw;
   dV_r(k,:)   = ndw;
     
  %Update solution in time
   x  = nx;  %updating phi
   dx = ndx; %updating dphi
   y  = ny;  %updating Ve
   dy = ndy; %updating dVe
   z  = nz;  %updating Vs
   dz = ndz; %updating dVs
   w  = nw;  %updating Vr
   dw = ndw; %updating dVr

 end
 
 phi_e = phi_e((options.Integration.maxdelayiters+1):end,:); %Throw away initial history...
 V_s   =   V_s((options.Integration.maxdelayiters+1):end,:); %Throw away initial history...
 
 if nargout > 2
   t = 0:options.Integration.dt:(options.Integration.dt*(options.Integration.iters-1)); %time in seconds
 end
 
 if nargout > 3 %Store the state of the random number generators, for continuation...
   options.Dynamics.InitialConditions.StateRand  = options.Dynamics.InitialConditions.ThisRandomStream.State;
 end
 
end %function BRRW_heun()
