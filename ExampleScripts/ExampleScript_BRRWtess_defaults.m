%% Example batch script for BRRWtess (NOTE: batch means there is an exit at the end)
%
% NOTE: This is a batch script example, so there is a save and exit at the end.
%
% Approximate runtime: 30s on a Workstation circa 2010
% Approximate memory: 2GB
% Approximate storage: 1GB
% 
% Under *nix, run without GUI using:
%     batch -f ./run_ExampleScript_BRRWtess_defaults &
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
  if strcmp(filesep,'/'), %on a *nix machine, then write machine details to our log...
    system('uname -a') 
  end
  disp(['Running: ' ThisScript])
  disp(['Script directory: ' ScriptDir])
  disp(['Code directory: ' FullPathCodeDir])

%% Do the stuff...

  %Add path to Surfaces
  SurfacesPath = genpath(fullfile(FullPathCodeDir,'Surfaces'));
  path(SurfacesPath,path)
 
  %Load surface
  ThisSurface = 'reg13';
  load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles'); %Contains: 'Vertices', 'Triangles'
 
  %Connectivity
  ThisConnectivity = 'O52R00_IRP2008';
  options.Connectivity.WhichMatrix = ThisConnectivity;
  options.Connectivity.hemisphere = 'both';
  options.Connectivity.RemoveThalamus = true;
  ConductionVelocity = 4.0; %mm/ms
  options.Connectivity.invel = 1.0/ConductionVelocity;
  options.Connectivity = GetConnectivity(options.Connectivity);
  
  load(['SummaryInfo_Cortex_' ThisSurface '.mat'], 'NumberOfVertices');
  options.Connectivity.NumberOfVertices = NumberOfVertices;
  clear NumberOfVertices
  
  %Mapping of Connectivity to Surface
  load(['RegionMapping_' ThisSurface '_' ThisConnectivity '.mat'], 'RegionMapping');
  options.Connectivity.RegionMapping = RegionMapping;
  clear RegionMapping
  
  %Dynamic Model
  options.Dynamics.WhichModel = 'BRRWtess';
  options.Dynamics.BrainState = 'ec'; %Default eyes closed parameter set.
 
  %Initialise defaults
  options.Dynamics = SetDynamicParameters(options.Dynamics);
  options = SetIntegrationParameters(options);
  options = SetDerivedParameters(options);
  options = SetInitialConditions(options);
  
  %Beltrami-Laplace operator
  load(['LapOp_' ThisSurface '.mat'], 'LapOp');
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
  
  %Integrate the network model
  [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRWtess_heun(options);
  
%% Save results to the directory of the invoking script
  ResultsPathFile = [ScriptDir filesep mfilename '.mat'];
  save(ResultsPathFile)
  disp(['Saved results of calculation to: ' ResultsPathFile])

%% When did we finish:
  disp(['Script ended: ' when()])

%% Always exit at the end when batching... 
  exit
 
%%% EoF %%%
