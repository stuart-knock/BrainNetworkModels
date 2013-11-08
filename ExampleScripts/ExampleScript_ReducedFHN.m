%% Generate 0.6 seconds worth of time series for the RM_AC matrix at 10^6Hz.
%
% NOTE: This is a batch script example and so there is an exit at the end.
%
% Default FHN paramters produce oscilators at ~140Hz. By setting Velocity
% to 70 and reinterpreting the oscilations as ~14Hz and Velocity as 7 we
% effectively have 6 seconds of data. The factor of 10 in this 
% reinterpretation plus downsampling by 100 leaves us with 6 seconds worth 
% of 1000Hz data, which we then save. 
%
% Approximate runtime: 3 minutes on a Workstation circa 2010
% Approximate memory: 3GB
% Approximate storage: 4MB 
%
% Run without GUI: 
% batch -f ./run_ExampleScript_ReducedFHN &
%
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
   !uname -a 
 end 
 disp(['Script directory: ' ScriptDir])
 disp(['Code directory: ' FullPathCodeDir])
 
%% Do the stuff... 

 %Specify Connectivity to use
 options.Connectivity.WhichMatrix = 'RM_AC';
 Velocity = 70;  %Defaults produce ~140Hz FHN oscillators, a reinterpretation of  Velocity = 70 as Velocity = 7 coresponds to ~14Hz FHN oscillators.
 options.Connectivity.invel = 1.0 / Velocity;

 %Specify Dynamics to use
 options.Dynamics.WhichModel = 'ReducedFHN';
 
 %Load default parameters for specified connectivity and dynamics
 options.Connectivity = GetConnectivity(options.Connectivity);
 options.Dynamics = SetDynamicParameters(options.Dynamics);
 
 %Over-ride some of the default dynamic parameters
   %Coupling with reduced population model
   options.K11 = 3;
   options.K12 = 0.6;
   options.K21 = options.K11;

   %Turn on some noise
   options.Dynamics.Qx = 0.001;
   options.Dynamics.Qy = 0.001;
   options.Dynamics.Qz = 0.001;
   options.Dynamics.Qw = 0.001;
 
 %Set non-default integration parmeters
 options.Integration.dt = 0.001;
 options.Integration.iters = 60000;
 
 %
 options = SetDerivedParameters(options);
 options = SetInitialConditions(options);
 
 %Integrate the network
 [Xi Eta Alfa Btta t options] = ReducedFHN_heun(options);
 

%Crude downsample
 N = options.Connectivity.NumberOfNodes; 
 NM = options.Dynamics.NumberOfModes;
 DSF = 100;      %Down sample factor
 Xi = squeeze(mean(reshape(Xi, [DSF (options.Integration.iters/DSF) N, NM])));
 Eta = squeeze(mean(reshape(Eta, [DSF (options.Integration.iters/DSF) N, NM])));
 Alfa = squeeze(mean(reshape(Alfa, [DSF (options.Integration.iters/DSF) N, NM])));
 Btta = squeeze(mean(reshape(Btta, [DSF (options.Integration.iters/DSF) N, NM])));
 
 t = 10*t(((DSF/2)+1):DSF:end); %Factor of 10 is 


%% Save results to the directory of the invoking script
 save([ScriptDir Sep mfilename '.mat'])

%% When did we finish:
 CurrentTime = clock;
 disp(['Script ended on ' date ' at ' num2str(CurrentTime(4)) ':' num2str(CurrentTime(5)) ':' num2str(CurrentTime(6))])

%% Always exit at the end when batching... 
 exit
 
%%%EoF%%%