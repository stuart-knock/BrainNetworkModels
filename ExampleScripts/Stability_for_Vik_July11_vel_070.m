%Script to numerically calculate bifurcation for one (Inverse) Velocity 
%using Connectivity Scale Factor (csf) as the control parameter...
%NB. This script will take a few days to run and produce ~66 data files...

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


 
%% Save results to the directory of the invoking script
 save([ScriptDir Sep 'AppropriateFileName.mat'])
 
%% When did we finish:
 CurrentTime = clock;
 disp(['Script ended on ' date ' at ' num2str(CurrentTime(4)) ':' num2str(CurrentTime(5)) ':' num2str(CurrentTime(6))])

%% Always exit at the end when batching... 
 exit

%%%EoF%%%
