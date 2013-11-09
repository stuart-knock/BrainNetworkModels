%Script to numerically calculate bifurcation for one (Inverse) Velocity 
%using Connectivity Scale Factor (csf) as the control parameter...
%NB. This script will take a few days to run and produce ~66 data files...
%
% NOTE: This is a batch script example, so there is a save and exit at the end.
%
% Approximate runtime: <?> minutes on a Workstation circa 2010
% Approximate memory:  <?>MB
% Approximate storage: <?>MB 
%
% Under *nix, run without GUI using: 
%     batch -f ./run_<batch_script_template> &
%

%% Some details of our environment...
%Where is the code
 CodeDir = '..';        %can be full or relative directory path
 ScriptDir = pwd;       %get full path to this script
 cd(CodeDir)            %Change to code directory
 FullPathCodeDir = pwd; %get full path of CodeDir

%When and Where did we start:
 disp(['Script started: ' when()]) 
 if strcmp(filesep,'/'), %on a *nix machine, write machine details to our log...
   system('uname -a') 
 end 
 disp(['Script directory: ' ScriptDir])
 disp(['Code directory: ' FullPathCodeDir])
 
%% Do the stuff... 


 
%% Save results to the directory of the invoking script
 save([ScriptDir filesep 'AppropriateFileName.mat'])
 
%% When did we finish:
 CurrentTime = clock;
 disp(['Script ended: ' when()])

%% Always exit at the end when batching... 
 exit

%%%EoF%%%
