%% Generate 4 seconds worth of time series for the RM_AC matrix at 64000Hz.
%
% NOTE: This is a batch script example and so there is an exit at the end.
%
% Approximate runtime: 1 minute on a Workstation circa 2010
% Approximate memory: 2GB
% Approximate storage: 330MB 
%
% Run without GUI: 
% batch -f ./run_ExampleScript_ReducedHMR &
%


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
 
 %Specify Connectivity to use
 options.Connectivity.WhichMatrix = 'RM_AC';
 options.Connectivity.invel = 1/7;
 
 %Specify Dynamics to use
 options.Dynamics.WhichModel = 'ReducedHMR';
 
 %Load default parameters for specified connectivity and dynamics
 options.Connectivity = GetConnectivity(options.Connectivity);
 options.Dynamics = SetDynamicParameters(options.Dynamics);
 
 %Over-ride some of the default dynamic parameters
   %Turn on some noise
   options.Dynamics.Qu = 0.001;
   options.Dynamics.Qv = 0.001;
   options.Dynamics.Qw = 0.001;
   options.Dynamics.Qx = 0.001;
   options.Dynamics.Qy = 0.001;
   options.Dynamics.Qz = 0.001;
   
 options = SetIntegrationParameters(options);
 
 %Default dt gives 64/ms, set iters to provide 4 s (4000 ms) of data.
 options.Integration.iters = 1000 * 2^8;
 
 options = SetDerivedParameters(options);
 options = SetInitialConditions(options);
 
 %Integrate the network 
 [Xi Eta Tau Alfa Btta Gamma t options] = ReducedHMR_heun(options);
      
      

%% Save results to the directory of the invoking script
 save([ScriptDir Sep mfilename '.mat'])

%% When did we finish:
 CurrentTime = clock;
 disp(['Script ended on ' date ' at ' num2str(CurrentTime(4)) ':' num2str(CurrentTime(5)) ':' num2str(CurrentTime(6))])

%% Always exit at the end when batching... 
 exit
 
%%%EoF%%%