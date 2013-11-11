%% <concise-description-of-scripts-purpose>
%
% NOTE: This is a batch script example, so there is a save and exit at the end.
%
% <more-detailed-description-and-other-important-info-if-necessary>
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
  
  %Structure, ie Connectivity and Surface
  
  %Dynamic Model

  %Default Dynamic Parameters

  %Some non-default Model parameters

  %Default Integration Parameters

  %Parameters depending on the combination of Connectivity, Dynamics, and Integration

  %InitialConditions for this BrainNetworkModel

  %Run the simulation


%% Save results to the directory of the invoking script
  %NOTE: Remember to do incremental saves for long running scripts.
  save([ScriptDir filesep '<AppropriateFileName>.mat'])

%% When did we finish:
  disp(['Script ended: ' when()])

%% Always exit at the end when batching... 
  exit

%%%EoF%%%
