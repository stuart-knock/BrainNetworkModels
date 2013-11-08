%% Generate 4 seconds worth of "rest-state" data @ 1000Hz on the cortical 
% surface using BRRWtess model and O52R00_IRP2008 connectivity. 
%
% NOTE: By default long-range coupling is turned off...
%
% Approximate runtime: 40 minutes on a Workstation circa 2010
% Approximate memory: 8GB
% Approximate storage: NA (save not included...:)
%

current_path = path;

%% Add path to Surfaces
 SurfacesPath = genpath(fullfile(pwd,'Surfaces'));
 if ~any(findstr(SurfacesPath, current_path)),
   path(SurfacesPath,path)
 end
   
%% Load surface
 ThisSurface = 'reg13';
 load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles'); %Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals'
 tr = TriRep(Triangles,Vertices);
 NumberOfVertices = length(Vertices);
 
 
 %% Dynamics
 options.Dynamics.WhichModel = 'BRRWtess';
 options.Dynamics.BrainState = 'eo';

%% Dynamic Parameters
 options.Dynamics = SetDynamicParameters(options.Dynamics);

%% Connectivity
 ThisConnectivity = 'O52R00_IRP2008';
 options.Connectivity.WhichMatrix = ThisConnectivity;
 options.Connectivity.hemisphere = 'both';
 options.Connectivity.RemoveThalamus = true; %Dynamic model includes a thalamus...
 ConductionVelocity = 4; %mm/ms
 options.Connectivity.invel = 1/ConductionVelocity;
 options.Connectivity = GetConnectivity(options.Connectivity);
 options.Connectivity.NumberOfVertices = NumberOfVertices;

%% Region mapping
 load(['RegionMapping_' ThisSurface '_' ThisConnectivity '.mat'])
 options.Connectivity.RegionMapping = RegionMapping;
 
%% Integration options
 options = SetIntegrationParameters(options);
 options.Integration.iters = 2^11; %
 
%Increased verbosity, here it enables the integration step counter.
options.Other.verbosity = 1;
 
%% Set things derived from our choices above
 options = SetDerivedParameters(options); %
 options = SetInitialConditions(options);

%% Beltrami-Laplace operator
 load(['LapOp_' ThisSurface '.mat'])
 options.Dynamics.LapOp = LapOp;
 clear LapOp

 
%% initial integration, to clear transient
 Continuations = 6;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for initial integration...'])
   
   [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRWtess_heun(options);
   options = UpdateInitialConditions(options);
 end

%% Down Sample Factors, for storing
% NOTE: This downsampling is just stepping stone, it's more correct to 
% average blocks for time and either regions or perform projections(EEG, 
% MEG) for space.
 DSF_t = 8; %Using 8 with default options.Integration.dt gives 1000Hz
 DSF_x = 1; %Don't downsample space if you want to see the activity on the cortical surface...
 
%% Noise driven rest-state
 Continuations = 16;
 DownSampledIters = options.Integration.iters ./ DSF_t;
 DownSampledVertices = options.Connectivity.NumberOfVertices ./ DSF_x;
 Store_phi_e = zeros(Continuations .* DownSampledIters, DownSampledVertices);
 Store_t     = zeros(Continuations .* DownSampledIters, 1);
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for noise driven rest-state...'])
   
   options.Dynamics.phi_n = 1e-3 + 0.01e-3*randn(size(options.Dynamics.phi_n));
   [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRWtess_heun(options);
   
   Store_phi_e(((k-1)*DownSampledIters + 1):k*DownSampledIters, :) = phi_e(1:DSF_t:end, 1:DSF_x:end);
   Store_t(((k-1)*DownSampledIters + 1):k*DownSampledIters, 1) = (k-1) * options.Integration.iters * options.Integration.dt + t(1:DSF_t:end);
   
   options = UpdateInitialConditions(options);
 end
 
 %% Make a Pruuutty picture...
  
  %SurfaceMovie(tr, Store_phi_e(1:4:end,:), options.Connectivity.RegionMapping)


%%%EoF%%%