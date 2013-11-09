%% Set dynamic parameters for a specified model.
%
% ARGUMENTS:
%           Dynamics -- The dynamics field of a BrainNetwrorkModels options
%                       structure. At least Dynamics.WhichModel must be set
%                       and for BRRW and AFR models Dynamics.BrainState
%                       must also be set.
%
% OUTPUT: 
%           Dynamics -- The dynamics field of a BrainNetwrorkModels options
%                       structure with default parameter fields filled.
%
% USAGE:
%{
      %Specify a local dynamic model
      options.Dynamics.WhichModel = 'FHN';
      options.Dynamics = SetDynamicParameters(options.Dynamics);
%}
%
% MODIFICATION HISTORY:
%     SAK(06-01-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Dynamics = SetDynamicParameters(Dynamics)

 switch Dynamics.WhichModel
   case {'BRRWtess' 'AFRtess'}
     defaults.csf   = 0.00;
     switch lower(Dynamics.BrainState)
       case{'eo'} %Rest-state eyes open
         defaults.Theta_e =  15.0;   %(mV)    - Mean neuronal threshold for Excitatory cortical population.
         defaults.Theta_s =  15.0;   %(mV)    - Mean neuronal threshold for specific thalamic population.
         defaults.Theta_r =  15.0;   %(mV)    - Mean neuronal threshold for reticular thalamic population.
         defaults.sigma_e =   6.0;   %(mV)    - Threshold variability for Excitatory cortical population.
         defaults.sigma_s =   6.0;   %(mV)    - Threshold variability for specific thalamic population.
         defaults.sigma_r =   6.0;   %(mV)    - Threshold variability for reticular thalamic population.
         defaults.Qmax    =   0.250; %?(/ms)  - Maximum firing rate
         defaults.v       =  10.00;  %(mm/ms) - Conduction velocity
         defaults.r_e     =  80.0;   %(mm)    - Mean range of axons
         %%%DERIVED%%% defaults.gamma_e = 0.125;         %(/ms) - Ratio of conduction velocity to mean range of axons
         defaults.alfa    =   0.060; %(/ms)   - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
         defaults.btta    =   4.0*defaults.alfa; %(/ms) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
         defaults.CTdelay =  40.0;   %(ms)    - Corticothalamic delay
         defaults.TCdelay =  40.0;   %(ms)    - Thalamocortical delay
         defaults.nu_ee   =  17.0e2; %(mV ms) - Excitatory corticocortical gain/coupling
         defaults.nu_ei   = -18.0e2; %(mV ms) - Inhibitory corticocortical gain/coupling
         defaults.nu_es   =  12.0e2; %(mV ms) - Specific thalamic nuclei to cortical gain/coupling
         defaults.nu_se   =  10.0e2; %(mV ms) - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
         defaults.nu_sr   = -10.0e2; %(mV ms) - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
         defaults.nu_sn   =  10.0e2; %(mV ms) - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
         defaults.nu_re   =   4.0e2; %(mV ms) - Excitatory cortical to thalamic reticular nucleus gain/coupling
         defaults.nu_rs   =   2.0e2; %(mV ms) - Specific to reticular thalamic nuclei gain/coupling
         
       case{'ec'} %Rest-state eyes closed
         defaults.Theta_e =  15.0;   %(mV)    - Mean neuronal threshold for Excitatory cortical population.
         defaults.Theta_s =  15.0;   %(mV)    - Mean neuronal threshold for specific thalamic population.
         defaults.Theta_r =  15.0;   %(mV)    - Mean neuronal threshold for reticular thalamic population.
         defaults.sigma_e =   6.0;   %(mV)    - Threshold variability for Excitatory cortical population.
         defaults.sigma_s =   6.0;   %(mV)    - Threshold variability for specific thalamic population.
         defaults.sigma_r =   6.0;   %(mV)    - Threshold variability for reticular thalamic population.
         defaults.Qmax    =   0.250; %?(/ms)  - Maximum firing rate
         defaults.v       =  10.00;  %(mm/ms) - Conduction velocity
         defaults.r_e     =  80.0;   %(mm)    - Mean range of axons
         %%%DERIVED%%% defaults.gamma_e = 0.125;   %(/ms) - Ratio of conduction velocity to mean range of axons
         defaults.alfa    =   0.060; %(/ms)   - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
         defaults.btta    =   4.0*defaults.alfa; %(/ms) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
         defaults.CTdelay =  40.0;   %(ms)    - Corticothalamic delay
         defaults.TCdelay =  40.0;   %(ms)    - Thalamocortical delay
         defaults.nu_ee   =  12.0e2; %(mV ms) - Excitatory corticocortical gain/coupling
         defaults.nu_ei   = -18.0e2; %(mV ms) - Inhibitory corticocortical gain/coupling
         defaults.nu_es   =  14.0e2; %(mV ms) - Specific thalamic nuclei to cortical gain/coupling
         defaults.nu_se   =  10.0e2; %(mV ms) - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
         defaults.nu_sr   = -10.0e2; %(mV ms) - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
         defaults.nu_sn   =  10.0e2; %(mV ms) - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
         defaults.nu_re   =   2.0e2; %(mV ms) - Excitatory cortical to thalamic reticular nucleus gain/coupling
         defaults.nu_rs   =   2.0e2; %(mV ms) - Specific to reticular thalamic nuclei gain/coupling
         
       case{'sleepstage1' 'ss1'}
         error(['BrainNetworkModels:' mfilename ':NotImplemented'], ['The default parameters for the BrainState ' Dynamics.BrainState '  are not implemented yet...']);
       
       case{'sleepstage3' 'ss2'}
         error(['BrainNetworkModels:' mfilename ':NotImplemented'], ['The default parameters for the BrainState ' Dynamics.BrainState '  are not implemented yet...']);
       
       case{'sleepstage2' 'ss3'}
         error(['BrainNetworkModels:' mfilename ':NotImplemented'], ['The default parameters for the BrainState ' Dynamics.BrainState '  are not implemented yet...']);
        
       case{'absence' 'petitmal'} %Epilepsy -- Absence seizure
         defaults.Theta_e =  15.0;   %(mV)    - Mean neuronal threshold for Excitatory cortical population.
         defaults.Theta_s =  15.0;   %(mV)    - Mean neuronal threshold for specific thalamic population.
         defaults.Theta_r =  15.0;   %(mV)    - Mean neuronal threshold for reticular thalamic population.
         defaults.sigma_e =   6.0;   %(mV)    - Threshold variability for Excitatory cortical population.
         defaults.sigma_s =   6.0;   %(mV)    - Threshold variability for specific thalamic population.
         defaults.sigma_r =   6.0;   %(mV)    - Threshold variability for reticular thalamic population.
         defaults.Qmax    =   0.250; %?(/ms)  - Maximum firing rate
         defaults.v       =  10.00;  %(mm/ms) - Conduction velocity
         defaults.r_e     =  80.0;   %(mm)    - Mean range of axons
         %%%DERIVED%%% defaults.gamma_e =   0.125; %(/ms) - Ratio of conduction velocity to mean range of axons
         defaults.alfa    =   0.050; %(/ms)   - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
         defaults.btta    =   4.0*defaults.alfa; %(/ms) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
         defaults.CTdelay =  40.0;   %(ms)    - Corticothalamic delay
         defaults.TCdelay =  40.0;   %(ms)    - Thalamocortical delay
         defaults.nu_ee   =  10.0e2; %(mV ms) - Excitatory corticocortical gain/coupling
         defaults.nu_ei   = -18.0e2; %(mV ms) - Inhibitory corticocortical gain/coupling
         defaults.nu_es   =  32.0e2; %(mV ms) - Specific thalamic nuclei to cortical gain/coupling
         defaults.nu_se   =  44.0e2; %(mV ms) - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
         defaults.nu_sr   = -8.0e2;  %(mV ms) - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
         defaults.nu_sn   =  20.0e2; %(mV ms) - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
         defaults.nu_re   =  16.0e2; %(mV ms) - Excitatory cortical to thalamic reticular nucleus gain/coupling
         defaults.nu_rs   =   6.0e2; %(mV ms) - Specific to reticular thalamic nuclei gain/coupling
         
       case{'tonicclonic' 'grandmal'} %Epilepsy -- Tonic-clonic seizure
         defaults.Theta_e =  15.0;   %(mV)    - Mean neuronal threshold for Excitatory cortical population.
         defaults.Theta_s =  15.0;   %(mV)    - Mean neuronal threshold for specific thalamic population.
         defaults.Theta_r =  15.0;   %(mV)    - Mean neuronal threshold for reticular thalamic population.
         defaults.sigma_e =   6.0;   %(mV)    - Threshold variability for Excitatory cortical population.
         defaults.sigma_s =   6.0;   %(mV)    - Threshold variability for specific thalamic population.
         defaults.sigma_r =   6.0;   %(mV)    - Threshold variability for reticular thalamic population.
         defaults.Qmax    =   0.250; %?(/ms)  - Maximum firing rate
         defaults.v       =  10.00;  %(mm/ms) - Conduction velocity
         defaults.r_e     =  80.0;   %(mm)    - Mean range of axons
         %%%DERIVED%%% defaults.gamma_e = 0.125;   %(/ms) - Ratio of conduction velocity to mean range of axons
         defaults.alfa    =   0.060; %(/ms)   - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
         defaults.btta    =   4.0*defaults.alfa; %(/ms) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
         defaults.CTdelay =  40.0;   %(ms)    - Corticothalamic delay
         defaults.TCdelay =  40.0;   %(ms)    - Thalamocortical delay
         defaults.nu_ee   =  12.0e2; %(mV ms) - Excitatory corticocortical gain/coupling
         defaults.nu_ei   = -18.0e2; %(mV ms) - Inhibitory corticocortical gain/coupling
         defaults.nu_es   =  14.0e2; %(mV ms) - Specific thalamic nuclei to cortical gain/coupling
         defaults.nu_se   =  10.0e2; %(mV ms) - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
         defaults.nu_sr   = -10.0e2; %(mV ms) - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
         defaults.nu_sn   =  10.0e2; %(mV ms) - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
         defaults.nu_re   =   2.0e2; %(mV ms) - Excitatory cortical to thalamic reticular nucleus gain/coupling
         defaults.nu_rs   =   2.0e2; %(mV ms) - Specific to reticular thalamic nuclei gain/coupling
         
       otherwise
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'BRRW' 'AFR'}
%% Default parameters BRRW
     defaults.csf   = 0.00;
     defaults.CorticalCircumference = 880.0; % (mm)
     switch lower(Dynamics.BrainState)
       case{'eo'} %Rest-state eyes open
         defaults.Theta_e =  15.0;   %(mV)    - Mean neuronal threshold for Excitatory cortical population.
         defaults.Theta_s =  15.0;   %(mV)    - Mean neuronal threshold for specific thalamic population.
         defaults.Theta_r =  15.0;   %(mV)    - Mean neuronal threshold for reticular thalamic population.
         defaults.sigma_e =   6.0;   %(mV)    - Threshold variability for Excitatory cortical population.
         defaults.sigma_s =   6.0;   %(mV)    - Threshold variability for specific thalamic population.
         defaults.sigma_r =   6.0;   %(mV)    - Threshold variability for reticular thalamic population.
         defaults.Qmax    =   0.250; %(/ms)   - Maximum firing rate
         defaults.v       =  10.00;  %(mm/ms) - Conduction velocity
         defaults.r_e     =  80.0;   %(mm)    - Mean range of axons
         %%%DERIVED%%% defaults.gamma_e = 0.125;         %(/ms) - Ratio of conduction velocity to mean range of axons
         defaults.alfa    =   0.06;  %(/ms)   - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
         defaults.btta    =   4.0*defaults.alfa; %(/ms) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
         defaults.CTdelay =  40.0;   %(ms)    - Corticothalamic delay
         defaults.TCdelay =  40.0;   %(ms)    - Thalamocortical delay
         defaults.nu_ee   =  17.0e2; %(mV ms) - Excitatory corticocortical gain/coupling
         defaults.nu_ei   = -18.0e2; %(mV ms) - Inhibitory corticocortical gain/coupling
         defaults.nu_es   =  12.0e2; %(mV ms) - Specific thalamic nuclei to cortical gain/coupling
         defaults.nu_se   =  10.0e2; %(mV ms) - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
         defaults.nu_sr   = -10.0e2; %(mV ms) - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
         defaults.nu_sn   =  10.0e2; %(mV ms) - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
         defaults.nu_re   =   4.0e2; %(mV ms) - Excitatory cortical to thalamic reticular nucleus gain/coupling
         defaults.nu_rs   =   2.0e2; %(mV ms) - Specific to reticular thalamic nuclei gain/coupling
         
       case{'ec'} %Rest-state eyes closed
         defaults.Theta_e =  15.0;   %(mV)    - Mean neuronal threshold for Excitatory cortical population.
         defaults.Theta_s =  15.0;   %(mV)    - Mean neuronal threshold for specific thalamic population.
         defaults.Theta_r =  15.0;   %(mV)    - Mean neuronal threshold for reticular thalamic population.
         defaults.sigma_e =   6.0;   %(mV)    - Threshold variability for Excitatory cortical population.
         defaults.sigma_s =   6.0;   %(mV)    - Threshold variability for specific thalamic population.
         defaults.sigma_r =   6.0;   %(mV)    - Threshold variability for reticular thalamic population.
         defaults.Qmax    =   0.250; %?(/ms)  - Maximum firing rate
         defaults.v       =  10.00;  %(mm/ms) - Conduction velocity
         defaults.r_e     =  80.0;   %(mm)    - Mean range of axons
         %%%DERIVED%%% defaults.gamma_e = 0.125;         %(/ms) - Ratio of conduction velocity to mean range of axons
         defaults.alfa    =   0.060;%(/ms)   - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
         defaults.btta    =   4.0*defaults.alfa; %(/ms) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
         defaults.CTdelay =  40.0;   %(ms)    - Corticothalamic delay
         defaults.TCdelay =  40.0;   %(ms)    - Thalamocortical delay
         defaults.nu_ee   =  12.0e2; %(mV ms) - Excitatory corticocortical gain/coupling
         defaults.nu_ei   = -18.0e2; %(mV ms) - Inhibitory corticocortical gain/coupling
         defaults.nu_es   =  14.0e2; %(mV ms) - Specific thalamic nuclei to cortical gain/coupling
         defaults.nu_se   =  10.0e2; %(mV ms) - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
         defaults.nu_sr   = -10.0e2; %(mV ms) - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
         defaults.nu_sn   =  10.0e2; %(mV ms) - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
         defaults.nu_re   =   2.0e2; %(mV ms) - Excitatory cortical to thalamic reticular nucleus gain/coupling
         defaults.nu_rs   =   2.0e2; %(mV ms) - Specific to reticular thalamic nuclei gain/coupling
         
       case{'sleepstage1' 'ss1'}
         error(['BrainNetworkModels:' mfilename ':NotImplemented'], ['The default parameters for the BrainState ' Dynamics.BrainState '  are not implemented yet...']);
       
       case{'sleepstage3' 'ss2'}
         error(['BrainNetworkModels:' mfilename ':NotImplemented'], ['The default parameters for the BrainState ' Dynamics.BrainState '  are not implemented yet...']);
       
       case{'sleepstage2' 'ss3'}
         error(['BrainNetworkModels:' mfilename ':NotImplemented'], ['The default parameters for the BrainState ' Dynamics.BrainState '  are not implemented yet...']);
       
         
       case{'absence' 'petitmal'} %Epilepsy -- Absence seizure
         defaults.Theta_e =  15.0;   %(mV)    - Mean neuronal threshold for Excitatory cortical population.
         defaults.Theta_s =  15.0;   %(mV)    - Mean neuronal threshold for specific thalamic population.
         defaults.Theta_r =  15.0;   %(mV)    - Mean neuronal threshold for reticular thalamic population.
         defaults.sigma_e =   6.0;   %(mV)    - Threshold variability for Excitatory cortical population.
         defaults.sigma_s =   6.0;   %(mV)    - Threshold variability for specific thalamic population.
         defaults.sigma_r =   6.0;   %(mV)    - Threshold variability for reticular thalamic population.
         defaults.Qmax    =   0.250; %?(/ms)  - Maximum firing rate
         defaults.v       =  10.00;  %(mm/ms) - Conduction velocity
         defaults.r_e     =  80.0;   %(mm)    - Mean range of axons
         %%%DERIVED%%% defaults.gamma_e =   0.125;         %(/ms) - Ratio of conduction velocity to mean range of axons
         defaults.alfa    =   0.050; %(/ms)   - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
         defaults.btta    =   4.0*defaults.alfa; %(/ms) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
         defaults.CTdelay =  40.0;   %(ms)    - Corticothalamic delay
         defaults.TCdelay =  40.0;   %(ms)    - Thalamocortical delay
         defaults.nu_ee   =  10.0e2; %(mV ms) - Excitatory corticocortical gain/coupling
         defaults.nu_ei   = -18.0e2; %(mV ms) - Inhibitory corticocortical gain/coupling
         defaults.nu_es   =  32.0e2; %(mV ms) - Specific thalamic nuclei to cortical gain/coupling
         defaults.nu_se   =  44.0e2; %(mV ms) - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
         defaults.nu_sr   =  -8.0e2; %(mV ms) - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
         defaults.nu_sn   =  20.0e2; %(mV ms) - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
         defaults.nu_re   =  16.0e2; %(mV ms) - Excitatory cortical to thalamic reticular nucleus gain/coupling
         defaults.nu_rs   =   6.0e2; %(mV ms) - Specific to reticular thalamic nuclei gain/coupling
         
       case{'tonicclonic' 'grandmal'} %Epilepsy -- Tonic-clonic seizure
         defaults.Theta_e =  15.0;   %(mV)    - Mean neuronal threshold for Excitatory cortical population.
         defaults.Theta_s =  15.0;   %(mV)    - Mean neuronal threshold for specific thalamic population.
         defaults.Theta_r =  15.0;   %(mV)    - Mean neuronal threshold for reticular thalamic population.
         defaults.sigma_e =   6.0;   %(mV)    - Threshold variability for Excitatory cortical population.
         defaults.sigma_s =   6.0;   %(mV)    - Threshold variability for specific thalamic population.
         defaults.sigma_r =   6.0;   %(mV)    - Threshold variability for reticular thalamic population.
         defaults.Qmax    =   0.25;  %(/ms)   - Maximum firing rate
         defaults.v       =  10.00;  %(mm/ms) - Conduction velocity
         defaults.r_e     =  80.0;   %(mm)    - Mean range of axons
         %%%DERIVED%%% defaults.gamma_e = 125;         %(/s) - Ratio of conduction velocity to mean range of axons
         defaults.alfa    =   0.06;  %(/ms)   - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
         defaults.btta    = 4.0*defaults.alfa; %(/s) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
         defaults.CTdelay =   40.0;  %(ms)    - Corticothalamic delay
         defaults.TCdelay =   40.0;  %(ms)    - Thalamocortical delay
         defaults.nu_ee   =  12.0e2; %(mV ms) - Excitatory corticocortical gain/coupling
         defaults.nu_ei   = -18.0e2; %(mV ms) - Inhibitory corticocortical gain/coupling
         defaults.nu_es   =  14.0e2; %(mV ms) - Specific thalamic nuclei to cortical gain/coupling
         defaults.nu_se   =  10.0e2; %(mV ms) - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
         defaults.nu_sr   = -10.0e2; %(mV ms) - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
         defaults.nu_sn   =  10.0e2; %(mV ms) - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling
         defaults.nu_re   =   2.0e2; %(mV ms) - Excitatory cortical to thalamic reticular nucleus gain/coupling
         defaults.nu_rs   =   2.0e2; %(mV ms) - Specific to reticular thalamic nuclei gain/coupling
         
       otherwise
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'SNX'}
%% Default parameters SNX
     defaults.a     = 1.0;
     defaults.csf   = 0.076;
     defaults.Qx    = 0.00;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'FHN','FHNtess'}
%% Default parameters FHN
     defaults.d     = 1.0; %TODO: set this to ~0.02; and get rid of all rescaling reinterpretations
     defaults.a     = 1.05;
     defaults.b     = 0.2;
     defaults.tau   = 1.25;
     defaults.csf   = 0.016;
     defaults.Qf    = 0;
     defaults.Qs    = 0;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'ReducedFHN','ReducedFHNtess'}
%% Default parameters ReducedFHN
    %Dynamics
     defaults.a   = 0.45;
     defaults.b   = 0.9;
     defaults.tau = 3;
     defaults.K11 = 0.5;          %Internal coupling: Excitatory->Excitatory
     defaults.K12 = 0.15;         %Internal coupling: Excitatory->Inhibitory
     defaults.K21 = defaults.K11; %Internal coupling: Inhibitory->Excitatory
     
     defaults.csf = 0.00042;
     
     defaults.mu    = 0;    %Mean of the Normal distribution
     defaults.sigma = 0.35; %standard deviation of the Normal Distribution
     defaults.Nv = 1500;    %Resolution of Excitatory distribution (chosen in paper to match neuron count of "neuron level" simulation)
     defaults.Nu = 1500;    %Resolution of Inhibitory distribution (chosen in paper to match neuron count of "neuron level" simulation)
     
    %Noise
     defaults.Qx  = 0;      %
     defaults.Qy  = 0;      %
     defaults.Qz  = 0;      %
     defaults.Qw  = 0;      %

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'ReducedHMR','ReducedHMRtess'}
%% Default parameters ReducedHMR
     defaults.r  =  0.006;
     defaults.s  =  4; 
     defaults.x0 = -1.6;
     defaults.a  =  1;
     defaults.b  =  3; 
     defaults.c  =  1;
     defaults.d  =  5;
     defaults.K11 = 0.5;
     defaults.K12 = 0.15;
     defaults.K21 = defaults.K11;
     
     defaults.csf = 0.00042;
     
     defaults.mu    = 2.2; %Mean of the Normal distribution
     defaults.sigma = 0.3; %standard deviation of the Normal Distribution
     defaults.Nv = 1500;   %Resolution of Excitatory distribution 
     defaults.Nu = 1500;   %Resolution of Inhibitory distribution 
     
    %Noise
     defaults.Qx = 0; 
     defaults.Qy = 0;
     defaults.Qz = 0;
     defaults.Qw = 0;
     defaults.Qv = 0;
     defaults.Qu = 0;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
% % %    case {'<WhichModel>'}
% % % %% Default parameters 
% % %      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     
   otherwise
 end

 Dynamics = MergeStructures(Dynamics, defaults);
 
end %function SetDynamicParameters()
