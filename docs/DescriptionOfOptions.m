%% Description of the options data structure.
% Running this file will produce a complete but essentially empty
% structure called OptionsDescription.
%
% 0.0      => real; 
% 0        => integer; 
% false    => logical; 
% ''       => string;
% zeros(,) => array(iters,maxdelayiters,NumberOfNodes,NumberOfModes,Nu,Nv)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Just so this file can be run to generate a dummy structure...
iters         = 7; 
maxdelayiters = 6; 
NumberOfNodes = 5; 
Nu            = 4; 
NumberOfModes = 3; 
Nv            = 2; 
StateVariables{1} = 'StateVariableName';

%%
 OptionsDescription.Connectivity.WhichMatrix = '';
 OptionsDescription.Dynamics.WhichModel = '';
 
%% Integration 
 OptionsDescription.Integration.Integrator = '';
 OptionsDescription.Integration.dt         = 0.0;
 OptionsDescription.Integration.iters      = 0;

 
%% Generic to all matrices
 OptionsDescription.Connectivity.invel = 0.0;
 
%derived
 OptionsDescription.Connectivity.weights
 OptionsDescription.Connectivity.delay
 OptionsDescription.Connectivity.NodeStr
 OptionsDescription.Connectivity.Position
 OptionsDescription.Connectivity.NumberOfNodes = 0; 

%% ThisMatrix = 'for_Vik_July11';
 OptionsDescription.Connectivity.subject = 0;

%% ThisMatrix = 'O52R00_IRP2008';
 OptionsDescription.Connectivity.centres        = '';
 OptionsDescription.Connectivity.hemisphere     = '';
 OptionsDescription.Connectivity.RemoveThalamus = false;


%% Fitz-Hugh Nagumo Oscillators
 OptionsDescription.Dynamics.csf   = 0.0;
 OptionsDescription.Dynamics.StateVariables = {'',''};
 OptionsDescription.Dynamics.a   = 0.0;
 OptionsDescription.Dynamics.b   = 0.0;
 OptionsDescription.Dynamics.tau = 0.0;
%Noise
 OptionsDescription.Dynamics.Qf  = 0.0;
 OptionsDescription.Dynamics.Qs  = 0.0;

%% Reduced Fitz-Hugh Nagumo model 
 OptionsDescription.Dynamics.csf   = 0.0;
 OptionsDescription.Dynamics.StateVariables = {'','','',''};
 OptionsDescription.Dynamics.b     = 0.0;
 OptionsDescription.Dynamics.tau   = 0.0;
 OptionsDescription.Dynamics.K11   = 0.0;
 OptionsDescription.Dynamics.K12   = 0.0;
 OptionsDescription.Dynamics.K21   = 0.0;
%Intermediate for calc of coefficients
 OptionsDescription.Dynamics.mu    = 0.0;
 OptionsDescription.Dynamics.sigma = 0.0;
 OptionsDescription.Dynamics.Nv    = 0;
 OptionsDescription.Dynamics.Nu    = 0;
 OptionsDescription.Dynamics.g1    = zeros(1,Nv);
 OptionsDescription.Dynamics.g2    = zeros(1,Nu);
 OptionsDescription.Dynamics.V     = zeros(NumberOfModes,Nv);
 OptionsDescription.Dynamics.U     = zeros(NumberOfModes,Nu);
 OptionsDescription.Dynamics.Zu    = zeros(1,Nu);
 OptionsDescription.Dynamics.Zv    = zeros(1,Nv);
 OptionsDescription.Dynamics.a     = 0.0;
%Coefficients
 OptionsDescription.Dynamics.A    = zeros(NumberOfModes,NumberOfModes);
 OptionsDescription.Dynamics.B    = zeros(NumberOfModes,NumberOfModes);
 OptionsDescription.Dynamics.C    = zeros(NumberOfModes,NumberOfModes);
 OptionsDescription.Dynamics.e_i  = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.f_i  = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.IE_i = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.II_i = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.m_i  = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.n_i  = zeros(1,NumberOfModes);
%Noise
 OptionsDescription.Dynamics.Qx   = 0.0;
 OptionsDescription.Dynamics.Qy   = 0.0;
 OptionsDescription.Dynamics.Qz   = 0.0;
 OptionsDescription.Dynamics.Qw   = 0.0;

%% Reduced Hindmarsh-Rose model
 OptionsDescription.Dynamics.csf   = 0.0;
 OptionsDescription.Dynamics.StateVariables = {'','','','','',''};
 OptionsDescription.Dynamics.r     = 0.0;
 OptionsDescription.Dynamics.s     = 0.0;
 OptionsDescription.Dynamics.x0    = 0.0;
 OptionsDescription.Dynamics.a     = 0.0;
 OptionsDescription.Dynamics.b     = 0.0;
 OptionsDescription.Dynamics.c     = 0.0;
 OptionsDescription.Dynamics.d     = 0.0;
%Intermediate for calc of coefficients
 OptionsDescription.Dynamics.mu    = 0.0;
 OptionsDescription.Dynamics.sigma = 0.0;
 OptionsDescription.Dynamics.Nv    = 0;
 OptionsDescription.Dynamics.Nu    = 0;
 OptionsDescription.Dynamics.Iu    = zeros(1,Nu);
 OptionsDescription.Dynamics.Iv    = zeros(1,Nv);
 OptionsDescription.Dynamics.V     = zeros(NumberOfModes,Nv);
 OptionsDescription.Dynamics.U     = zeros(NumberOfModes,Nu);
 OptionsDescription.Dynamics.g1    = zeros(1,Nv);
 OptionsDescription.Dynamics.g2    = zeros(1,Nu);
%Coefficients
 OptionsDescription.Dynamics.A     = zeros(NumberOfModes,NumberOfModes);
 OptionsDescription.Dynamics.B     = zeros(NumberOfModes,NumberOfModes);
 OptionsDescription.Dynamics.C     = zeros(NumberOfModes,NumberOfModes);
 OptionsDescription.Dynamics.a_i   = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.e_i   = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.b_i   = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.f_i   = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.c_i   = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.h_i   = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.IE_i  = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.II_i  = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.d_i   = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.p_i   = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.m_i   = zeros(1,NumberOfModes);
 OptionsDescription.Dynamics.n_i   = zeros(1,NumberOfModes);
%Noise
 OptionsDescription.Dynamics.Qx    = 0.0;
 OptionsDescription.Dynamics.Qy    = 0.0;
 OptionsDescription.Dynamics.Qz    = 0.0;
 OptionsDescription.Dynamics.Qw    = 0.0;
 OptionsDescription.Dynamics.Qv    = 0.0;
 OptionsDescription.Dynamics.Qu    = 0.0;

%% CorticoThalamic RRW model (default values for EC)
 OptionsDescription.Dynamics.Theta_e =   0.0;       %(V)  - Mean neuronal threshold for Excitatory cortical population. 
 OptionsDescription.Dynamics.Theta_s =   0.015;     %(V)  - Mean neuronal threshold for specific thalamic population. 
 OptionsDescription.Dynamics.Theta_r =   0.015;     %(V)  - Mean neuronal threshold for reticular thalamic population.
 OptionsDescription.Dynamics.sigma_e =   0.006;     %(V)  - Threshold variability for Excitatory cortical population.
 OptionsDescription.Dynamics.sigma_s =   0.006;     %(V)  - Threshold variability for specific thalamic population.
 OptionsDescription.Dynamics.sigma_r =   0.006;     %(V)  - Threshold variability for reticular thalamic population.
 OptionsDescription.Dynamics.Qmax    = 250.0;       %     - Maximum firing rate
 OptionsDescription.Dynamics.v       =  10.00;      %(m/s)- Conduction velocity
 OptionsDescription.Dynamics.r_e     =   0.08;      %(m)  - Mean range of axons
 %%%Derived Parameter%%% OptionsDescription.Dynamics.gamma_e = 125.0;       %(/s) - Ratio of conduction velocity to mean range of axons
 OptionsDescription.Dynamics.alfa    =  60.0;       %(/s) - Inverse decay time of membrane potential... current values a=50; b=4*a; are consistent
 OptionsDescription.Dynamics.btta    = 240.0;%   4.0*alfa; %(/s) - Inverse rise time of membrane potential ... with parmaters relevant to sleep stage II.
 OptionsDescription.Dynamics.CTdelay =   0.04;      %(s)   - Corticothalamic delay
 OptionsDescription.Dynamics.TCdelay =   0.04;      %(s)   - Thalamocortical delay
 OptionsDescription.Dynamics.nu_ee   =  17.0e-4;    %(V s) - Excitatory corticocortical gain/coupling
 OptionsDescription.Dynamics.nu_ei   = -18.0e-4;    %(V s) - Inhibitory corticocortical gain/coupling
 OptionsDescription.Dynamics.nu_es   =  12.0e-4;    %(V s) - Specific thalamic nuclei to cortical gain/coupling
 OptionsDescription.Dynamics.nu_se   =  10.0e-4;    %(V s) - Cortical to specific thalamic nuclei gain/coupling... turn seizure on and off
 OptionsDescription.Dynamics.nu_sr   = -10.0e-4;    %(V s) - Thalamic reticular nucleus to specific thalamic nucleus gain/coupling
 OptionsDescription.Dynamics.nu_sn   =  10.0e-4;    %(V s) - Nonspecific subthalamic input onto specific thalamic nuclei gain/coupling 
 OptionsDescription.Dynamics.nu_re   =   4.0e-4;    %(V s) - Excitatory cortical to thalamic reticular nucleus gain/coupling
 OptionsDescription.Dynamics.nu_rs   =   2.0e-4;    %(V s) - Specific to reticular thalamic nuclei gain/coupling
 OptionsDescription.Dynamics.CorticalCircumference = 0.88; %(m)
%%%Derived Parameter%%%  OptionsDescription.Dynamics.Delta_x =   0.130;     %(m)  - distance between nodes (patches of brain) at cortex... enters through Laplacian operator
%Input
 OptionsDescription.Dynamics.phi_n = ones(iters,NumberOfNodes);

%% Initial Conditions
 OptionsDescription.Dynamics.InitialConditions.(StateVariables{:}) = zeros(maxdelayiters,NumberOfNodes,NumberOfModes);
 OptionsDescription.Dynamics.InitialConditions.StateRand           = 0;
 OptionsDescription.Dynamics.InitialConditions.StateRandN          = 0;

%% Bifurcation
 OptionsDescription.Bifurcation.BifurcationParameter          = '';
 OptionsDescription.Bifurcation.BifurcationParameterIncrement = 0.0;
 OptionsDescription.Bifurcation.InitialControlValue           = 0.0;
 OptionsDescription.Bifurcation.TargetControlValue            = 0.0;
 OptionsDescription.Bifurcation.MaxContinuations              = 0;
 OptionsDescription.Bifurcation.ErrorTolerance                = 0.0;
 OptionsDescription.Bifurcation.AttemptForceFixedPoint        = false;

%% Plotting
%PlotNodeBifurcation
 OptionsDescription.Plotting.PlotNodeBifurcation.FigureHandles = cell(1,length(StateVariables));
 OptionsDescription.Plotting.PlotNodeBifurcation.PlotOnlyNodes = {'','','',''};
%histConnectivity
 OptionsDescription.Plotting.histConnectivity.minD             = 0.0;
 OptionsDescription.Plotting.histConnectivity.maxD             = 0.0;
 OptionsDescription.Plotting.histConnectivity.stepD            = 0.0;
 OptionsDescription.Plotting.histConnectivity.rescale          = 0.0;
 OptionsDescription.Plotting.histConnectivity.WMS              = zeros(1,2);
%PlotConnectivity
 OptionsDescription.Plotting.PlotConnectivity.Order            = zeros(1,NumberOfNodes);
%inheadConnectivity
 OptionsDescription.Plotting.inheadConnectivity.EdgeCutoff     = 0.0;

%% 
 OptionsDescription.Other.verbose = 0;

%% EoF %% 