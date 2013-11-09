%% Integrates an ensemble of FitzHugh-Nagumo oscillators, coupled locally 
% through the cortical surface and connected through a weighted network 
% with time delays
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
      %Surface
       load('Cortex_reg13.mat');           % Contains: 'Vertices', 'Triangles' 
       tr = TriRep(Triangles, Vertices); % Convert to TriRep object
       NumberOfVertices = length(Vertices);

      %Specify Connectivity to use
       options.Connectivity.WhichMatrix = 'O52R00_IRP2008';
       options.Connectivity.hemisphere = 'both';
       options.Connectivity.RemoveThalamus = true;
       options.Connectivity.invel = 1/4;

       options.Connectivity.NumberOfVertices = NumberOfVertices;


      %Local Coupling
       G1.Std =  5;
       G1.Amp =  2; %NOTE: set me to zero for single -ve Gaussian coupling.
       G2.Std = 20;
       G2.Amp =  1; %NOTE: set me to zero for single +ve Gaussian coupling.
       Neighbourhood = 12;
       [options.Dynamics.LocalCoupling, Convergence] = LocalCoupling(tr, G1, G2, Neighbourhood); %This takes a few minutes... 
       
       TrianglesPerVertex = vertexAttachments(tr,  (1:NumberOfVertices).');
       TrianglesPerVertex = cellfun(@length, TrianglesPerVertex);
       options.Dynamics.VertexDegree = TrianglesPerVertex.';

      %Specify Dynamics to use
       options.Dynamics.WhichModel = 'FHNtess';

      %Load default parameters for specified connectivity and dynamics
       options.Connectivity = GetConnectivity(options.Connectivity);
       options.Dynamics = SetDynamicParameters(options.Dynamics);
       options = SetIntegrationParameters(options);
       options = SetDerivedParameters(options);
       options = SetInitialConditions(options);

      %Integrate the network using default options (Network of   should take about  s)
       [V W t options] = FHNtess_heun(options);
%}
%
% MODIFICATION HISTORY:
%     SAK(28-11-2010) -- Original: derived from FHN_heun().
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [V W t options] = FHNtess_heun(options)

 if isfield(options.Dynamics, 'Stimulus'),
   Stimulus = options.Integration.dt * options.Dynamics.tau * options.Dynamics.Stimulus;
 else
   Stimulus = 0.0;
 end


%Set RandStream to a state consistent with InitialConditions.
 options.Dynamics.InitialConditions.ThisRandomStream.State = options.Dynamics.InitialConditions.StateRand;
 if isoctave(),
   rand('state', options.Dynamics.InitialConditions.ThisRandomStream.State);
 else %Presumably Matlab
   RandStream.setDefaultStream(options.Dynamics.InitialConditions.ThisRandomStream);
 end

%Set initial state vectors
 x = options.Dynamics.InitialConditions.V(end, :);
 y = options.Dynamics.InitialConditions.W(end, :);
 
%Initialise array to store fast variable, including it's history
 V = [options.Dynamics.InitialConditions.V((end-options.Integration.maxdelayiters+1):end, :) ; zeros(options.Integration.iters, options.Connectivity.NumberOfVertices)]; 
%Initialise array to store slow variable
 W =                                                                                           zeros(options.Integration.iters, options.Connectivity.NumberOfVertices) ; 
%-----------------------------------------------------------------------%

%% Integrate the Network of FitzHugh-Nagumo oscillators
 if options.Dynamics.csf~=0,   %Skip it when checking uncoupled dynamics.
   RegionAvg_V = zeros(options.Integration.maxdelayiters+options.Integration.iters,options.Connectivity.NumberOfNodes);
   for n = 1:options.Connectivity.NumberOfNodes,
     RegionAvg_V(:,n) = mean(V(:,options.Connectivity.RegionMapping==n),2); 
   end
 end

 xhist = zeros(1,options.Connectivity.NumberOfVertices); %need this for when csf = 0...
 
 fprintf(1,'Integrating for %d steps, currently on step:     ', options.Integration.iters);
 for k = 1:options.Integration.iters
   fprintf(1,'\b\b\b\b%4d', k);
   
  %Calculate coupling term 
   if options.Dynamics.csf~=0,   %Skip it when checking uncoupled dynamics.
     for n = 1:options.Connectivity.NumberOfNodes,
       RegionAvg_V(options.Integration.maxdelayiters+k-1,n) = mean(V(options.Integration.maxdelayiters+k-1,options.Connectivity.RegionMapping==n),2);
     end
     RegionAvg_xhist(1,:) = sum(options.Connectivity.weights.*RegionAvg_V(options.Integration.lidelay+k), 1);
     for n = 1:options.Connectivity.NumberOfNodes,
       xhist(1,options.Connectivity.RegionMapping==n) = RegionAvg_xhist(1,n);
     end
   end

  %Solve the differential equation (FitzHugh-Nagumo), using Heun scheme. (see, eg, Mannella 2002 "Integration Of SDEs on a Computer")  
   Noise_x = options.Dynamics.sqrtQfdt .* randn(1,options.Connectivity.NumberOfVertices); 
   Noise_y = options.Dynamics.sqrtQsdt .* randn(1,options.Connectivity.NumberOfVertices);
    
   %TODO: Need to enable delays and other adaptions... 
   %TODO: optimise, eg, predivide options.Dynamics.LocalCoupling by
   %                    options.Dynamics.VertexDegree 
   LocalCoupling = V(options.Integration.maxdelayiters+k-1, :) * options.Dynamics.LocalCoupling; 
   LocalCoupling = options.Integration.dt * options.Dynamics.tau * LocalCoupling; %NOTE: Currently don't support spatialised tau...
   
   [Fx0 Fy0] = FHN(x,y,options.Dynamics); 
   
   x1 = x + Fx0 * options.Integration.dt + Noise_x - options.Dynamics.dttauc .* xhist + LocalCoupling + Stimulus;
   y1 = y + Fy0 * options.Integration.dt + Noise_y;
   
   [Fx1 Fy1] = FHN(x1,y1,options.Dynamics); 
   
   nx = x + options.Integration.dtt * (Fx0 + Fx1) + Noise_x - options.Dynamics.dttauc .* xhist + LocalCoupling + Stimulus; 
   ny = y + options.Integration.dtt * (Fy0 + Fy1) + Noise_y; 

  %Store result of calc in variable for output
   V(options.Integration.maxdelayiters+k,:) = nx;
   W(k,:) = ny;
     
  %Update solution in time
   x = nx; %updating x
   y = ny; %updating y

 end
 fprintf(1,'\n');
 
 V = V((options.Integration.maxdelayiters+1):end,:); %Throw away initial history...
 
 if nargout > 2
   t = 0:options.Integration.dt:(options.Integration.dt*(options.Integration.iters-1)); %time in milliseconds
 end
 
 if nargout > 3 %Store the state of the random number generators, for continuation...
   if isoctave(),
     options.Dynamics.InitialConditions.StateRand  = rand('state');
   else %Presumably Matlab
     options.Dynamics.InitialConditions.StateRand  = options.Dynamics.InitialConditions.ThisRandomStream.State;
   end
 end
 
end %function FHNtess_heun()