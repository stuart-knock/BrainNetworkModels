%% Generate 1 second worth of time series for the ReducedFHN model at 4096Hz.
%
% NOTE: This is a batch script example and so there is an exit at the end.
%
% Approximate runtime: 42 seconds, Octave, Workstation circa 2012
% Approximate memory:  400MB
% Approximate storage: 60MB 
%
% Under *nix, run without GUI using: 
%     batch -f ./run_ReducedFHN__RM_AC_1s_demo &
%

%% Some details of our environment...
  %Where is the code
  CodeDir = '..';        %can be full or relative directory path
  ScriptDir = pwd;       %get full path to this script
  cd(CodeDir)            %Change to code directory
  FullPathCodeDir = pwd; %get full path of CodeDir
  ThisScript = mfilename; %which script is being run

  if isoctave(),
    more off
  end

  %When and Where did we start:
  disp(['Script started: ' when()]) 
  if strcmp(filesep, '/'), %on a *nix machine, then write machine details to our log...
    system('uname -a') 
  end 
  disp(['Running: ' ThisScript])
  disp(['Script directory: ' ScriptDir])
  disp(['Code directory: ' FullPathCodeDir])
 
%% Do the stuff...

%% Set-up BrainNetworkModel
  %Connectivity
  options.Connectivity.WhichMatrix = 'RM_AC';
  Velocity = 7.0;
  options.Connectivity.invel = 1.0/Velocity;
  options.Connectivity = GetConnectivity(options.Connectivity);

  %Non-default scaling factor for coupling through the Connectivity
  %options.Dynamics.csf = 0.00042;

  %Dynamic Model:
  options.Dynamics.WhichModel = 'ReducedFHN';

  %Default Dynamic Parameters
  options.Dynamics = SetDynamicParameters(options.Dynamics);
  
  %Some non-default Model parameters, internal coupling
  %options.Dynamics.K11 = 3.0;
  %options.Dynamics.K12 = 0.6;
  %options.Dynamics.K21 = options.Dynamics.K11;
  
  %Noise scaling
  options.Dynamics.Qx = 0.001;
  options.Dynamics.Qy = 0.001;
  options.Dynamics.Qz = 0.001;
  options.Dynamics.Qw = 0.001;
  
  %Set default integration
  options = SetIntegrationParameters(options);
  
  %Non-defaults
  options.Integration.dt = 0.01525878906250;
  options.Integration.iters = 2^14; %16384 => 250ms at dt=0.01525878906250
  
  %Parameters depending on the combination of Connectivity, Dynamics, and Integration
  options = SetDerivedParameters(options);
  
  %Set InitialConditions for this BrainNetworkModel
  options = SetInitialConditions(options);

%% Down Sample Factors, arrays for storing
  DSF_t = 16; %Using 16 with options.Integration.dt = 0.01525878906250 gives 4096Hz
  Continuations = 4; % with dt=0.01525878906250 & iters=16384, 4 here gives 1 second of output.

  block_length = options.Integration.iters * options.Integration.dt;
  M = options.Dynamics.NumberOfModes;
  N = options.Connectivity.NumberOfNodes;
  iperiod = options.Integration.iters/DSF_t;
  shape = [DSF_t iperiod N M];

  DownSampledIters = options.Integration.iters ./ DSF_t;
  store_Xi   = zeros(Continuations .* DownSampledIters, N, M);
  store_Eta  = zeros(Continuations .* DownSampledIters, N, M);
  store_Alfa = zeros(Continuations .* DownSampledIters, N, M);
  store_Btta = zeros(Continuations .* DownSampledIters, N, M);
  store_t    = zeros(Continuations .* DownSampledIters, 1);
  
%% Simulate
  for k = 1:Continuations,
    disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) '...'])
    
    %Integrate the network 
   [Xi Eta Alfa Btta t options] = ReducedFHN_heun(options);
    
    %Downsample by averaging
    store_Xi(((k-1)*DownSampledIters + 1):k*DownSampledIters, :, :)   = squeeze(mean(reshape(Xi, shape)));
    store_Eta(((k-1)*DownSampledIters + 1):k*DownSampledIters, :, :)  = squeeze(mean(reshape(Eta, shape)));
    store_Alfa(((k-1)*DownSampledIters + 1):k*DownSampledIters, :, :) = squeeze(mean(reshape(Alfa, shape)));
    store_Btta(((k-1)*DownSampledIters + 1):k*DownSampledIters, :, :) = squeeze(mean(reshape(Btta, shape)));
    
    store_t(((k-1)*DownSampledIters + 1):k*DownSampledIters, 1) = (k-1) * block_length + t(1:DSF_t:end);
   
    options = UpdateInitialConditions(options);
  end
  clear Xi Eta Alfa Btta t


%% Save results to the directory of the invoking script
  %save([ScriptDir filesep 'reducedfhn_RM_AC_1s_demo.mat'])

%% When did we finish:
  disp(['Script ended: ' when()])

%% Always exit at the end when batching... 
  %exit
 
%%%EoF%%%