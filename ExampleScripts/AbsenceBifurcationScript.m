%% Calculate bifurcation as a function of nu_se for BRRW-absence.
%
% Calculation is done using NodeBifurcation() and subsequent
% visualisation uses PlotNodeBifurcation().
%
% Approximate runtime: 5 hours, Octave, Workstation circa 2012
% Approximate memory:  < 1GB
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
  options.Connectivity.WhichMatrix = 'O52R00_IRP2008';
  options.Connectivity.RemoveThalamus = true;
  options.Connectivity.invel = 1.0/7.0;
  
  %Specify Dynamics to use
  options.Dynamics.WhichModel = 'BRRW';
  options.Dynamics.BrainState = 'absence';
  
  %Load default parameters for specified connectivity and dynamics
  options.Connectivity = GetConnectivity(options.Connectivity);
  options.Dynamics = SetDynamicParameters(options.Dynamics);
  options = SetIntegrationParameters(options);
  
  options.Integration.dt = 2^-3;
  options.Integration.iters = 2^14;
  
  options = SetDerivedParameters(options);
  options = SetInitialConditions(options);
  
  addpath(genpath('./Bifurcations'))
  options = SetBifurcationOptions(options);
  options.Bifurcation.BifurcationParameterIncrement =  0.625e2;
  options.Bifurcation.ErrorTolerance = 1.0e-6; 
  options.Bifurcation.MaxContinuations = 77;
  options.Bifurcation.AttemptForceFixedPoint = false;
  
  addpath(genpath('./PlottingTools')) %Need this if using interactive mode
  options.Other.verbosity = 4; %42;
  
  %Calcualte the bifurcation
  [ForwardFxdPts BackwardFxdPts options] = NodeBifurcation(options);


%% When did we finish:
  disp(['Script ended: ' when()])

%% Plotting
  %Select a few nodes
  options.Plotting.OnlyNodes = {'rFEF', 'rPFCORB', 'rV1', 'rV2'};
  
  % plot them
  FigureHandles = PlotNodeBifurcation(ForwardFxdPts, options)
  
  %Optionally over plot the Extrema found by back tracking
  options.Plotting.FigureHandles = FigureHandles;
  FigureHandles = PlotNodeBifurcation(BackwardFxdPts, options)

%%%EoF%%%
