

ThisMatrix = 'O52R00_IRP2008';
options.RemoveThalamus = true;
[weights delay NodeStr] = GetConnectivity(ThisMatrix,options);
N = length(NodeStr);

options.dt = 2^-16;    %2^-16
options.iters = 2^19; %2^18
options.csf = 0;
options.invel = 1; %with csf =0 this is just to avoid current issue with maxdelay...
options.verbose = 3;

options.BifurcationOptions.Integrator = 'brrw_net_heun';
options.BifurcationOptions.BifurcationParameter = 'nu_se';
options.BifurcationOptions.InitialControlValue  = 10e-4; %Must be strongly stable fixed point...
options.BifurcationOptions.BifurcationParameterIncrement = 5e-5;
options.BifurcationOptions.TargetControlValue  = 60e-4;
options.BifurcationOptions.ErrorTolerance = 1.0e-6;
options.BifurcationOptions.MaxContinuations = 35;


%%
[ForwardFxdPts BackwardFxdPts options] = NodeBifurcation(ThisMatrix,options);



%%
options.TCdelay =  (sin(2*pi*(1:N)./N))*.01 + 0.05;
options.CTdelay =  (sin(2*pi*(1:N)./N))*.01 + 0.05;

[ForwardFxdPts BackwardFxdPts options] = NodeBifurcation(ThisMatrix,options);