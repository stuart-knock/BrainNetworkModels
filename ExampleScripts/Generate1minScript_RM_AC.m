%% Generate 6 seconds worth of time series for the RM_AC matrix at 10^6Hz. 
%
% NOTE: This is a batch script example and so there is an exit at the end.
%
% Default FHN paramters produce oscilators at ~140Hz. By setting Velocity to
% 70 and reinterpreting the oscilations as ~14Hz and Velocity as 7 we
% effectively have 60 seconds of data. The factor of 10 in this 
% reinterpretation plus downsampling by 100 leaves us with 1 minute worth
% of 1000Hz data, which we then save. 
%
% Approximate runtime: 10 minutes on a Workstation circa 2010
% Approximate memory: 4GB
% Approximate storage: 34MB 
%
% Run without GUI: 
% batch -f ./run_Generate1minScript_RM_AC &
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
%Set options 
 options.Connectivity.WhichMatrix = 'RM_AC';
 Velocity = 70;  %Defaults produce ~140Hz FHN oscillators, a reinterpretation of  Velocity = 70 as Velocity = 7 coresponds to ~14Hz FHN oscillators.
 options.Connectivity.invel = 1/Velocity;
 
%Load a connection matrix
 options.Connectivity = GetConnectivity(options.Connectivity);

%Initialise defaults, overiding noise and integration steps
 options.Dynamics.WhichModel = 'FHN';
 options.Dynamics = SetDynamicParameters(options.Dynamics);
 options.Dynamics.Qf = 0.001;
 options.Dynamics.Qs = 0.001;
 %options = SetIntegrationParameters(options);
 options.Integration.dt = 0.001;
 options.Integration.iters = 6000000; %With the dt(0.001) and reinterp intrinsic oscillations as ~10Hz this gives 1 minutes
 options = SetDerivedParameters(options);
 options = SetInitialConditions(options);

%Integrate the network 
 [V W t] = FHN_heun(options);

%Crude downsample
 N = size(V, 2); %Number of nodes
 DSF = 100;      %Down sample factor
 V = squeeze(mean(reshape(V, [DSF (options.Integration.iters/DSF) N])));
 W = squeeze(mean(reshape(W, [DSF (options.Integration.iters/DSF) N])));
 t = 10*t(((DSF/2)+1):DSF:end); %Factor of 10 is 
 
%% Save results to the directory of the invoking script
 save([ScriptDir Sep mfilename '.mat'])

%% When did we finish:
 CurrentTime = clock;
 disp(['Script ended on ' date ' at ' num2str(CurrentTime(4)) ':' num2str(CurrentTime(5)) ':' num2str(CurrentTime(6))])

%% Always exit at the end when batching... 
 exit
 
%%%EoF%%%