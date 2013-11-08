%% Integrates an ensemble of FitzHugh-Nagumo oscillators, 
% connected through a weighted network with time delays
%
% Uses Heun method
%
% ARGUMENTS:
%           weights -- Matrix of connection weights between nodes
%           delay   -- Matrix of time delays between nodes in milliseconds
%           options -- A structure which can specify the arguments below:
%                     .iters -- Number iterations for the integration
%                     .dt    -- Length of each time step of the integration in milliseconds 
%                     .a     -- 
%                     .b     -- 
%                     .tau   -- Approx Inverse of time-scale separation between V and W ~1/sqrt()
%                     .csf   -- Scaling of coupling strength
%                     .Qf    -- Noise term for fast variable
%                     .Qs    -- Noise term for slow variable
%                     .InitialConditions -- Specify a non-default initial 
%                                           state for the random number 
%                                           generators:
%                                       .StateRand  
%                                       .StateRandN  
%                                           And/Or Specify non-random 
%                                           initial conditions:
%                                       .V -- must be >= max time delay long 
%                                       .W
%
% OUTPUT: 
%           V -- estimated time course of fast variable 
%           W -- estimated time course of slow variable 
%           t -- vector of time points for which integration was estimated 
%           StateRand  -- The final state of the random number generator
%           StateRandN -- The final state of the Normal dist. random number generator
%
% REQUIRES: 
%           FHN() -- Fitz-Hugh Nagumo function definition
%
% USAGE:
%{
      %Specify Connectivity to use
       options.Connectivity.WhichMatrix = 'RM_AC';
       options.Connectivity.invel = 1/7;

      %Specify Dynamics to use
       options.Dynamics.WhichModel = 'FHN';

      %Load default parameters for specified connectivity and dynamics
       options.Connectivity = GetConnectivity(options.Connectivity);
       options.Dynamics = SetDynamicParameters(options.Dynamics);
       options = SetIntegrationParameters(options);
       options = SetDerivedParameters(options);
       options = SetInitialConditions(options);

      %Integrate the network using default options (Network of 38N should take about 2s)
       [V W t options] = FHN_heun(options);
%}
%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [V W t options] = FHN_heun(options)

%Set RandStream to a state consistent with InitialConditions.
 options.Dynamics.InitialConditions.ThisRandomStream.State = options.Dynamics.InitialConditions.StateRand;
 RandStream.setDefaultStream(options.Dynamics.InitialConditions.ThisRandomStream);

%Set initial state vectors
 x = options.Dynamics.InitialConditions.V(end, :);
 y = options.Dynamics.InitialConditions.W(end, :);
 
%Initialise array to store fast variable, including it's history
 V = [options.Dynamics.InitialConditions.V((end-options.Integration.maxdelayiters+1):end, :) ; zeros(options.Integration.iters, options.Connectivity.NumberOfNodes)]; 
%Initialise array to store slow variable
 W =                                                                                           zeros(options.Integration.iters, options.Connectivity.NumberOfNodes) ; 
%-----------------------------------------------------------------------%

%% Integrate the Network of FitzHugh-Nagumo oscillators

 xhist = zeros(1,options.Connectivity.NumberOfNodes); %need this for when csf = 0...
 
 for k = 1:options.Integration.iters
   
  %Calculate coupling term 
   if options.Dynamics.csf~=0,   %Skip it when checking uncoupled dynamics.
     xhist(1,:) = sum(options.Connectivity.weights.*V(options.Integration.lidelay+k), 1);
   end

  %Solve the differential equation (FitzHugh-Nagumo), using Heun scheme. (see, eg, Mannella 2002 "Integration Of SDEs on a Computer")  
   Noise_x = options.Dynamics.sqrtQfdt*randn(1,options.Connectivity.NumberOfNodes); 
   Noise_y = options.Dynamics.sqrtQsdt*randn(1,options.Connectivity.NumberOfNodes);
    
   [Fx0 Fy0] = FHN(x,y,options.Dynamics); 
   
   x1 = x + Fx0*options.Integration.dt + Noise_x - options.Dynamics.dttauc*xhist;
   y1 = y + Fy0*options.Integration.dt + Noise_y;
   
   [Fx1 Fy1] = FHN(x1,y1,options.Dynamics); 
   
   nx = x + options.Integration.dtt*(Fx0 + Fx1) + Noise_x - options.Dynamics.dttauc*xhist; 
   ny = y + options.Integration.dtt*(Fy0 + Fy1) + Noise_y; 

  %Store result of calc in variable for output
   V(options.Integration.maxdelayiters+k,:) = nx;
   W(k,:) = ny;
     
  %Update solution in time
   x = nx; %updating x
   y = ny; %updating y

 end
 
 V = V((options.Integration.maxdelayiters+1):end,:); %Throw away initial history...
 
 if nargout > 2
   t = 0:options.Integration.dt:(options.Integration.dt*(options.Integration.iters-1)); %time in milliseconds
 end
 
 if nargout > 3 %Store the state of the random number generators, for continuation...
   options.Dynamics.InitialConditions.StateRand  = options.Dynamics.InitialConditions.ThisRandomStream.State;
 end
 
end %function fhn_net_heun()
