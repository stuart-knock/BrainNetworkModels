%% Generate 2 seconds worth of "rest-state" data @ 1024Hz on the cortical 
% surface using BRRWtess model and O52R00_IRP2008 connectivity. 
%
% NOTE: By default long-range coupling is turned off...
%
% Approximate runtime: 25 minutes, Octave, Workstation circa 2012
% Approximate memory: 3GB
% Approximate storage: NA (save not included...:)
%


%% Some details of our environment...
  %Where is the code
  CodeDir = '..';        %can be full or relative directory path
  ScriptDir = pwd;       %get full path to this script
  cd(CodeDir)            %Change to code directory
  FullPathCodeDir = pwd; %get full path of CodeDir
  
  if isoctave(),
    more off
  end

  %When and Where did we start:
  disp(['Script started: ' when()]) 
  if strcmp(filesep,'/'), %on a *nix machine, then write machine details to our log...
    system('uname -a') 
  end 
  disp(['Script directory: ' ScriptDir])
  disp(['Code directory: ' FullPathCodeDir])

%% Do the stuff...
  
  %Add path to Surfaces
  SurfacesPath = genpath(fullfile(FullPathCodeDir,'Surfaces'));
  path(SurfacesPath, path)
  
  %Load surface
  ThisSurface = 'reg13';
  load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles'); %Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals'
 
  %Connectivity
  ThisConnectivity = 'O52R00_IRP2008';
  options.Connectivity.WhichMatrix = ThisConnectivity;
  options.Connectivity.hemisphere = 'both';
  options.Connectivity.RemoveThalamus = true; %Dynamic model includes a thalamus...
  ConductionVelocity = 4.0; %mm/ms
  options.Connectivity.invel = 1/ConductionVelocity;
  options.Connectivity = GetConnectivity(options.Connectivity);

  NumberOfVertices = length(Vertices);
  options.Connectivity.NumberOfVertices = NumberOfVertices;
 
  %Region mapping
  load(['RegionMapping_' ThisSurface '_' ThisConnectivity '.mat'])
  options.Connectivity.RegionMapping = RegionMapping;
 
  %Dynamic Model:
  options.Dynamics.WhichModel = 'BRRWtess';
  options.Dynamics.BrainState = 'eo'; %Default eyes open parameter set.

  %Default Dynamic Parameters
  options.Dynamics = SetDynamicParameters(options.Dynamics);
  
  %Integration options
  options = SetIntegrationParameters(options);
  
  %Non-defaults
  options.Integration.dt = 0.122070312500000;
  %This is default% options.Integration.iters = 2^10; %1024 => 125ms at dt=0.122070312500
 
  %Increased verbosity, here it enables the integration step counter.
  options.Other.verbosity = 1;
 
  % Set things derived from our choices above
  options = SetDerivedParameters(options); %
  options = SetInitialConditions(options);

  % Beltrami-Laplace operator
  load(['LapOp_' ThisSurface '.mat'], 'LapOp')
  if isoctave(), %this is becoming absurd...
    row = LapOp.ir + 1;
    col = zeros(size(LapOp.data));
    for j = 1:(size(LapOp.jc, 2)-1),
      col(LapOp.jc(j)+1:LapOp.jc(j+1)) = j;
    end
    options.Dynamics.LapOp = sparse(row, col, LapOp.data);
  else %Presumably Matlab
    options.Dynamics.LapOp = LapOp;
  end
  clear LapOp


%% initial integration, to clear transient
  Continuations = 8;
  for k = 1:Continuations,
    disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for initial integration...'])
   
    [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRWtess_heun(options);
    options = UpdateInitialConditions(options);
  end

%% Down Sample Factors, for storing
  DSF_t = 8; %Using 8 with options.Integration.dt = 0.12207031250 gives 1024Hz
  Continuations = 16;

  block_length = options.Integration.iters * options.Integration.dt;
  iperiod = options.Integration.iters/DSF_t;
  N = options.Connectivity.NumberOfVertices;
  shape = [DSF_t iperiod N];
  
  DownSampledIters = options.Integration.iters ./ DSF_t;
  Store_phi_e = zeros(Continuations .* DownSampledIters, N);
  Store_t     = zeros(Continuations .* DownSampledIters, 1);

%% Simulate noise driven rest-state
  for k = 1:Continuations,
    disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for rest-state simulation...'])
    
    options.Dynamics.phi_n = 1e-3 + 0.01e-3*randn(size(options.Dynamics.phi_n));
    [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRWtess_heun(options);
    
    Store_phi_e(((k-1)*DownSampledIters + 1):k*DownSampledIters, :) = squeeze(mean(reshape(phi_e, shape)));
    Store_t(((k-1)*DownSampledIters + 1):k*DownSampledIters, 1) = (k-1) * block_length + t(1:DSF_t:end);
    
    options = UpdateInitialConditions(options);
  end

%% When did we finish:
  disp(['Simulation ended: ' when()])


% %% Look at the TimeSeries averaged by Connectivity regions 
%   PlotRegionAveragedTimeSeries(Store_phi_e(1:4:end,:), options.Connectivity, Store_t(1:4:end))


% %% Look at the FFT by region 
%   addpath(genpath('./PlottingTools'))
%   %Simple regional projection matrix.
%   NumberOfRegions = options.Connectivity.NumberOfNodes;
%   NumberOfVertices = options.Connectivity.NumberOfVertices;
%   Mapping.ProjectionMatrix = spalloc(NumberOfVertices, NumberOfRegions, NumberOfRegions);
%   for k=1:NumberOfRegions, 
%     ThisRegionVertices = options.Connectivity.RegionMapping==k;
%     Mapping.ProjectionMatrix(ThisRegionVertices,k) = 1./sum(ThisRegionVertices); %approx normalise region area 
%   end
%   Mapping.ProjectionLables = options.Connectivity.NodeStr;
  
%   sfhz = 1000.0 / (options.Integration.dt * DSF_t); %Sample frequency in Hz
%   PlotRegionColouredFFT(Store_phi_e, Mapping, sfhz); 


%% Make a Pruuutty picture...
  %tr = TriRep(Triangles,Vertices);
  %SurfaceMovie(tr, Store_phi_e(1:4:end,:), options.Connectivity.RegionMapping)


%%%EoF%%%
