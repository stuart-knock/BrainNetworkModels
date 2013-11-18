%% Calculate bifurcation as a function of csf for FHN on RM_AC.
%
% Calculation is done using NodeBifurcation() and subsequent
% visualisation uses PlotNodeBifurcation().
%
% Approximate runtime: 6 hours, Octave, Workstation circa 2012
% Approximate memory:  <1GBB
% Approximate storage: <?>MB 
%
%


%% Some details of our environment...
  %Where is the code
  CodeDir = '..';        %can be full or relative directory path
  ScriptDir = pwd;       %get full path to this script
  cd(CodeDir)            %Change to code directory
  FullPathCodeDir = pwd; %get full path of CodeDir
  ThisScript = mfilename; %which script is being run
  
  %When and Where did we start:
  disp(['Script started: ' when()]) 
  if strcmp(filesep,'/'), %on a *nix machine, write machine details log...
    system('uname -a') 
  end 
  disp(['Running: ' ThisScript])
  disp(['Script directory: ' ScriptDir])
  disp(['Code directory: ' FullPathCodeDir])
 
%% Do the stuff...
  %Specify Connectivity to use
  options.Connectivity.WhichMatrix = 'RM_AC';
  options.Connectivity.invel = 1.0/25.0;
  
  %Specify Dynamics to use
  options.Dynamics.WhichModel = 'FHN';
  
  %Load default parameters for specified connectivity and dynamics
  options.Connectivity = GetConnectivity(options.Connectivity);
  options.Dynamics = SetDynamicParameters(options.Dynamics);
  options = SetIntegrationParameters(options);
  
  %Set non default values
  options.Integration.dt = 2^-9;
  options.Integration.iters = 2^16;
  
  options = SetDerivedParameters(options);
  options = SetInitialConditions(options);
  
  %Set default bifurcation parameters for this Model
  addpath(genpath('./Bifurcations'))
  options = SetBifurcationOptions(options);
  
  %Set non default values -- NOTE: these are actually defaults, it's just a demo
  options.Bifurcation.BifurcationParameterIncrement = 0.00025;
  options.Bifurcation.ErrorTolerance = 2.0e-7; 
  options.Bifurcation.MaxContinuations = 65; %set to 0 for interactive
  
  addpath(genpath('./PlottingTools')) %Need this here if using interactive mode
  options.Other.verbosity = 4;%42; %0 implies "be quiet"; >=33 is interactive mode
  
  %Calcualte the bifurcation
  [ForwardFxdPts BackwardFxdPts options] = NodeBifurcation(options);

%% When did we finish:
  disp(['Script ended: ' when()])

%% Plotting
  %Select a few nodes
  options.Plotting.OnlyNodes = {'A2', 'CCP', 'FEF', 'IP', 'PFCDM', 'S1'};
  
  % plot them
  FigureHandles = PlotNodeBifurcation(ForwardFxdPts, options)
  
  %Optionally over plot the Extrema found by back tracking
  options.Plotting.FigureHandles = FigureHandles;
  FigureHandles = PlotNodeBifurcation(BackwardFxdPts, options)

%%%EoF%%%
