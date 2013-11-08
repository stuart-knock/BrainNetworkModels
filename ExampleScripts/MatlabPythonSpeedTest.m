%% Basic simulation for timing comparison with Python implementation
tic,

 options.Connectivity.WhichMatrix = 'for_Vik_July11';
 Velocity = 7.0;
 options.Connectivity.invel = 1/Velocity;
 
 %Load a connection matrix
 options.Connectivity = GetConnectivity(options.Connectivity);
 
 %Initialise defaults, overiding noise and integration steps
 options.Dynamics.WhichModel = 'FHN';
 options.Dynamics = SetDynamicParameters(options.Dynamics);
 
 options.Integration.dt = 2^-4;
 options.Integration.iters = 2^4 / options.Integration.dt;
 
 options = SetDerivedParameters(options);
 options = SetInitialConditions(options);

 [V W t] = FHN_heun(options); 

toc