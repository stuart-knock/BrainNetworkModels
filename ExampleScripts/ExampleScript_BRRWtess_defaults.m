%% Example batch script for BRRWtess (NOTE: batch means there is an exit at the end)
% <notes> 
% Approximate runtime: 30s on a Workstation circa 2010
% Approximate memory: 2GB
% Approximate storage: 1GB
% Run without GUI: 
% batch -f ./run_ExampleScript_BRRWtess_defaults &

%% Some details of our environment...
%Where is the code
 CodeDir = '..';        %can be full or relative directory path
 ScriptDir = pwd;       %get full path to this script
 cd(CodeDir)            %Change to code directory
 FullPathCodeDir = pwd; %get full path of CodeDir
 
%Get separator for this OS
 Sep = filesep;

%When and Where did we start:
 CurrentTime = clock;
 disp(['Script started on ' date ' at ' num2str(CurrentTime(4)) ':' num2str(CurrentTime(5)) ':' num2str(CurrentTime(6))]) 
 if strcmp(Sep,'/'), %on a *nix machine, then write machine details to our log...
   system('uname -a') 
 end 
 disp(['Script directory: ' ScriptDir])
 disp(['Code directory: ' FullPathCodeDir])

%% Do the stuff...

%Add path to Surfaces
 SurfacesPath = genpath(fullfile(FullPathCodeDir,'Surfaces'));
 path(SurfacesPath,path)
 
%Load surface
 ThisSurface = '213';
 load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles'); %Contains: 'Vertices', 'Triangles'
 
 % Connectivity
 options.Connectivity.WhichMatrix = 'O52R00_IRP2008';
 options.Connectivity.hemisphere = 'both';
 options.Connectivity.RemoveThalamus = true;
 options.Connectivity.invel = 1/4;
 options.Connectivity = GetConnectivity(options.Connectivity);
 options.Dynamics.WhichModel = 'BRRWtess';
 options.Dynamics.BrainState = 'ec';
 
 load(['SummaryInfo_' ThisSurface '.mat'], 'NumberOfVertices');
 options.Connectivity.NumberOfVertices = NumberOfVertices;
 clear NumberOfVertices
 
 %Mapping of Connectivity to Surface
 load(['RegionMapping_' ThisSurface '_' options.Connectivity.WhichMatrix '.mat'], 'RegionMapping');
 options.Connectivity.RegionMapping = RegionMapping;
 clear RegionMapping
 
 %Initialise defaults
 options.Dynamics = SetDynamicParameters(options.Dynamics);
 options = SetIntegrationParameters(options);
 options = SetDerivedParameters(options);
 options = SetInitialConditions(options);

 %Beltrami-Laplace operator
 load(['LapOp_n8_' ThisSurface '.mat'], 'LapOp');
 options.Dynamics.LapOp = LapOp;
 clear LapOp
 
 %Integrate teh network model
 [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRWtess_heun(options);

%% Save results to the directory of the invoking script
 ResultsPathFile = [ScriptDir Sep mfilename '.mat'];
 save(ResultsPathFile)
 disp(['Saved results of calculation to: ' ResultsPathFile])

%% When did we finish:
 CurrentTime = clock;
 disp(['Script ended on ' date ' at ' num2str(CurrentTime(4)) ':' num2str(CurrentTime(5)) ':' num2str(CurrentTime(6))])

%% Always exit at the end when batching... 
 exit
 
%%% EoF %%%
