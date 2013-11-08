%% Integrates an ensemble of Reduced FitzHugh-Nagumo oscillator based 
% neural field, connected through a weighted network with time delays.
%
% Implements Equation 1 (Reduced system of FHN) from (see ./docs directory):  
%    Stefanescu RA, Jirsa VK (2008), Neurons. PLoS Comput Biol 4(11).
%    "A Low Dimensional Description of Globally Coupled Heterogeneous Neural 
%     Networks of Excitatory and Inhibitory" 
% as the local dynamic of the nodes.
%
% Uses Heun method
%
% ARGUMENTS:
%           weights -- Matrix of connection weights between nodes
%           delay   -- Matrix of time delays between nodes in milliseconds
%           options -- A structure which can specify the arguments below:
%                     .iters -- Number iterations for the integration
%                     .dt    -- Length of each time step of the integration in milliseconds 
%                     .fhn.A     -- 
%                     .fhn.B     -- 
%                     .fhn.C     --   
%                     .fhn.e_i   --  
%                     .fhn.f_i   -- 
%                     .fhn.IE_i  -- 
%                     .fhn.II_i  --   
%                     .fhn.m_i   --  
%                     .fhn.n_i   -- 
%                     .b     --
%                     .K11   -- Excitatory to excitatory coupling in model. 
%                     .K12   -- Excitatory to inhibitory coupling in model.
%                     .K21   -- Inhibitory to excitatory coupling in model.
%                     .tau   -- Approx Inverse of time-scale separation between V and W ~1/sqrt()
%                     .Qx    -- Noise term for Xi
%                     .Qy    -- Noise term for Eta
%                     .Qz    -- Noise term for Alfa
%                     .Qw    -- Noise term for Btta
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
%                                       .Alfa
%                                       .Btta
%
% OUTPUT: 
%           Xi    -- estimated time course of Excitatory-Fast variable 
%           Eta   -- estimated time course of Excitatory-Slow variable 
%           Alfa -- estimated time course of Inhibitory-Fast variable 
%           Btta  -- estimated time course of Inhibitory-Slow variable 
%           t -- vector of time points for which integration was estimated 
%           options  -- The original options structure augmented with final state of the random number generator
%          
%
% USAGE:
%{
      %Specify Connectivity to use
       options.Connectivity.WhichMatrix = 'RM_AC';
       options.Connectivity.invel = 1/7;

      %Specify Dynamics to use
       options.Dynamics.WhichModel = 'ReducedFHN';

      %Load default parameters for specified connectivity and dynamics
       options.Connectivity = GetConnectivity(options.Connectivity);
       options.Dynamics = SetDynamicParameters(options.Dynamics);
       options = SetIntegrationParameters(options);
       options = SetDerivedParameters(options);
       options = SetInitialConditions(options);

      %Integrate the network using default options (Network of 38N should take about 3s)
       [Xi Eta Alfa Btta t options] = ReducedFHN_heun(options);
     
%}
%
% MODIFICATION HISTORY:
%     VJ/YAR(<dd-mm-yyyy>) -- Original.
%     SAK(27-10-2008) -- Optimise... (speedup ~140x)
%     SAK(04-10-2008) -- Comment/Structure/Generalise.
%     SAK(17-12-2008) -- Incorporated ability to start from Non-random
%                        initial conditions... primarily to allow
%                        continuation of previous run.
%     SAK(19-01-2009) -- Corrected bug I introduced in calculation of W.
%                        Corrected noise contribution to be proportional to
%                        sqrt(dt) rather than dt.
%     SAK(21-01-2009) -- Modified from fhn_net_rk.m to use heun method for
%                        consistency between solution order for
%                        deterministic and stochastic components...
%     SAK(28-01-2009) -- Save state of random number generators for use
%                        when continuing from previous run
%     SAK(4:10-09-2009) -- Modified from fhn_net_heun() @ v1.8
%     SAK(16-09-2009) -- Following discussion with MW implemented delayed
%                        coupling via linear indexing, also made a number
%                        of other minor optimisations... (speedup ~15x)
%     SAK(17-09-2009) -- Default noise => 0. Cleaned up parameter initialisation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Xi Eta Alfa Btta t options] = ReducedFHN_heun(options)
  
%Set RandStream to a state consistent with InitialConditions.
 options.Dynamics.InitialConditions.ThisRandomStream.State = options.Dynamics.InitialConditions.StateRand;
 if isoctave(),
   rand('state', options.Dynamics.InitialConditions.ThisRandomStream.State);
 else %Presumably Matlab
   RandStream.setDefaultStream(options.Dynamics.InitialConditions.ThisRandomStream);
 end

%Check sufficient history was provided
 if options.Integration.maxdelayiters>size(options.Dynamics.InitialConditions.Xi, 1), %Initialconditions aren't sufficiently long enough
   error(['BrainNetworkModels:' mfilename ':InitialConditionsTooShort'],'The InitialConditions provided do not contain enough data points for the maximum delay of the system...');
 end
 
%Set initial state vectors
 x = squeeze(options.Dynamics.InitialConditions.Xi(   end, :, :)).';
 y = squeeze(options.Dynamics.InitialConditions.Eta(  end, :, :)).';
 z = squeeze(options.Dynamics.InitialConditions.Alfa(end, :, :)).';
 w = squeeze(options.Dynamics.InitialConditions.Btta( end, :, :)).';
%%%keyboard
%Initialise array to store fast variable, including it's history
 Xi =  zeros(options.Integration.maxdelayiters+options.Integration.iters, options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes); 
 for k = 1:options.Integration.maxdelayiters,
   Xi(k,:,:) = options.Dynamics.InitialConditions.Xi((end-options.Integration.maxdelayiters+k), :, :);
 end
%Initialise array to store variables that don't require history
 Eta   = zeros(options.Integration.iters, options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes); %slow
 Alfa  = zeros(options.Integration.iters, options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes); %fast
 Btta  = zeros(options.Integration.iters, options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes); %slow
%-----------------------------------------------------------------------%
 
%Combine multiple copies of weights to match lidelay
if isfield(options.Connectivity, 'HaveRotatedWeights') && (options.Connectivity.HaveRotatedWeights == true), %FIXME: UGLY HACK...
  error(['BrainNetworkModels:' mfilename ':WeightsWereRotated'],['The weights matrix has been rotated but ' mfilename '() is written expecting weights in original sense...']);
end
 weights = permute(repmat(options.Connectivity.weights, [1 1 options.Dynamics.NumberOfModes]), [3 1 2]);
%-----------------------------------------------------------------------%

%% Integrate the Network of oscillators

 Noise_x = zeros(options.Dynamics.NumberOfModes, options.Connectivity.NumberOfNodes);
 Noise_y = zeros(options.Dynamics.NumberOfModes, options.Connectivity.NumberOfNodes);
 Noise_z = zeros(options.Dynamics.NumberOfModes, options.Connectivity.NumberOfNodes);
 Noise_w = zeros(options.Dynamics.NumberOfModes, options.Connectivity.NumberOfNodes);
 
 xhist = zeros(options.Dynamics.NumberOfModes, options.Connectivity.NumberOfNodes); %need this for when csf = 0...
 
 for k = 1:options.Integration.iters,
  %Set noise terms for this integration step
   if options.Dynamics.sqrtQxdt, %noise not zeros
     Noise_x = options.Dynamics.sqrtQxdt .* randn(options.Dynamics.NumberOfModes, options.Connectivity.NumberOfNodes);
   end
   if options.Dynamics.sqrtQydt,
     Noise_y = options.Dynamics.sqrtQydt .* randn(options.Dynamics.NumberOfModes, options.Connectivity.NumberOfNodes);
   end
   if options.Dynamics.sqrtQzdt,
     Noise_z = options.Dynamics.sqrtQzdt .* randn(options.Dynamics.NumberOfModes, options.Connectivity.NumberOfNodes);
   end
   if options.Dynamics.sqrtQwdt,
     Noise_w = options.Dynamics.sqrtQwdt .* randn(options.Dynamics.NumberOfModes, options.Connectivity.NumberOfNodes);
   end
   
  %Calculate coupling term 
   if options.Dynamics.csf~=0,   %Skip it when checking uncoupled dynamics.
     xhist = sum(weights.*Xi(options.Integration.lidelay+k), 3);
   end
%%%keyboard 

  %Solve the differential equation (), using Heun scheme. (see, eg, Mannella 2002 "Integration Of SDEs on a Computer")  
   [Fx0 Fy0 Fz0 Fw0] = ReducedFHN(x, y, z, w, options.Dynamics);
   
   x1 = x + Fx0*options.Integration.dt + Noise_x - options.Dynamics.dttauc .* xhist ;
   y1 = y + Fy0*options.Integration.dt + Noise_y;
   z1 = z + Fz0*options.Integration.dt + Noise_z;
   w1 = w + Fw0*options.Integration.dt + Noise_w;
   
   [Fx1 Fy1 Fz1 Fw1] = ReducedFHN(x1, y1, z1, w1, options.Dynamics);
   
   nx = x + options.Integration.dtt * (Fx0 + Fx1) + Noise_x - options.Dynamics.dttauc .* xhist; 
   ny = y + options.Integration.dtt * (Fy0 + Fy1) + Noise_y;
   nz = z + options.Integration.dtt * (Fz0 + Fz1) + Noise_z; 
   nw = w + options.Integration.dtt * (Fw0 + Fw1) + Noise_w; 

  %Store result of calc in variable for output
   Xi(options.Integration.maxdelayiters+k, :, :) = nx.';
   Eta(                                 k, :, :) = ny.';
   Alfa(                                k, :, :) = nz.';
   Btta(                                k, :, :) = nw.';
     
  %Update solution in time
   x = nx; %updating Xi
   y = ny; %updating Eta
   z = nz; %updating Alfa
   w = nw; %updating Btta

 end
 
 Xi = Xi((options.Integration.maxdelayiters+1):end, :, :); %Throw away initial history...
 
 if nargout > 4
   t = 0:options.Integration.dt:(options.Integration.dt*(options.Integration.iters-1)); %time in milliseconds
 end
 
 if nargout > 5 %Store the state of the random number generators, for continuation...
   if isoctave(),
     options.Dynamics.InitialConditions.StateRand  = rand('state');
   else %Presumably Matlab
     options.Dynamics.InitialConditions.StateRand  = options.Dynamics.InitialConditions.ThisRandomStream.State;
   end
 end
 
end %function ReducedFHN_heun()
