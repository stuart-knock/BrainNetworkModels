# Brain Network Models

BrainNetworkModels is a collection of Matlab functions for integrating networks
of local neural-field or neural-mass models coupled through anatomically
derived structure. Data representing large scale connectivity, such as
connection weights, region centres, etc, are contained in the directory
*ConnectivityData*. The *Surfaces* directory contains tessellated surfaces
representing the folded cortical surface as well as skull and skin for use in 
calculating ForwardSolutions. There are also some basic plotting and analysis
tools included. Most of the .m files include a header with a basic description
of function arguments as well as a usage example. There are also some demo
scripts in the *ExampleScripts* directory.

This code was mainly developed for my own research, which is why it's a bit 
rough around the edges in places. However, it also served as the basis for the 
[simulator library](https://github.com/the-virtual-brain/scientific_library) 
of [TheVirtualBrain](https://github.com/the-virtual-brain/), which is a far
more well developed large-scale brain simulator, written in Python. If you're 
interested in this sort of modelling, I'd strongly recommend that you use 
[TVB](https://github.com/the-virtual-brain/) rather than the code in this repo.

That being said, if you're still interested in looking into it a bit, the basic
usage is described below.


## Basic Usage:

1) Specify and then load a Connectivity dataset using something like:
```Matlab
options.Connectivity.WhichMatrix = 'RM_AC'
speed = 7.0;
options.Connectivity.invel = 1.0 / speed;
options.Connectivity = GetConnectivity(options.Connectivity);
```

2) Specify a model and set default parameters, using:
```Matlab
%Use Fitz-Hugh Nagumo model
options.Dynamics.WhichModel = 'FHN';

%Load default parameters for the specified model
options.Dynamics = SetDynamicParameters(options.Dynamics);
 
%Set default integration parameters, defaults depend on the chosen Model.
options = SetIntegrationParameters(options)

%Calculate parameters that depend on a combination of Connectivity+Model+Integration
options = SetDerivedParameters(options);

%Set initial conditions for the simulation
options = SetInitialConditions(options);
```

3) Integrate your chosen model and network using the appropriate *_heun()
 function:
```Matlab
[V W t] = FHN_heun(options);
```

4) Take a look at what you've done:
```Matlab
PlotTimeSeries(V, t, options.Connectivity.NodeStr)
```

For more detailed usage, see the scripts in *ExampleScripts* and the headers in
specific .m files.
