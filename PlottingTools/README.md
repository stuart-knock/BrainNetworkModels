## Plotting tools for BrainNetworkModels

### To Use

At an Octave or Matlab prompt in the BrainNetworkModels directory, run:

    addpath(genpath('./PlottingTools'))

Additionally, for PlotGraphMetrics(), you'll need run:
    
    addpath(genpath('./Metrics'))

see headers of individual files for usage.

If using Octave, run:

    use_fltk()

at the Octave command prompt, the default gnuplot is painfully slow...



### Directory/File structure:
    
    .
    ├── colourmaps
    │   ├── BlackToBlue.mat
    │   ├── BlueBigGreyRed.mat
    │   ├── BlueBlackRed.mat
    │   ├── BlueGreyRed.mat
    │   ├── BlueToBlack.mat
    │   ├── DarkBlueToLightBlue.mat
    │   ├── GreenBlackRed.mat
    │   ├── GreenToBlack.mat
    │   ├── LightBlueToDarkBlue.mat
    │   ├── RegionColours37.mat
    │   ├── RegionColours40.mat
    │   ├── RegionColours41.mat
    │   ├── RegionColours74.mat
    │   ├── RegionColours80b.mat
    │   ├── RegionColours80c.mat
    │   ├── RegionColours80d.mat
    │   ├── RegionColours80e.mat
    │   ├── RegionColours80f.mat
    │   ├── RegionColours80.mat
    │   ├── RegionColours82.mat
    │   └── SymJetZeroBlue.mat
    ├── histConnectivity3D.m
    ├── histConnectivity.m
    ├── inheadConnectivity.m
    ├── inspectdoi.m
    ├── PlotConnectivity3D.m
    ├── PlotConnectivity.m
    ├── plotfft.m
    ├── PlotGraphMetrics.m
    ├── PlotLocalSurface.m
    ├── PlotNodeBifurcation.m
    ├── PlotNodewiseCorrelation.m
    ├── PlotOverlayedHistograms.m
    ├── PlotRegionAveragedTimeSeries.m
    ├── PlotRegionColouredBars.m
    ├── PlotRegionColouredFFT.m
    ├── PlotRegionColouredTimeSeries.m
    ├── PlotReorder.m
    ├── PlotSpaceTime.m
    ├── PlotTimeSeries.m
    ├── README.md
    ├── script_CortexSensitivityMapOfElectrodes.m
    ├── SurfaceConnectivity.m
    ├── SurfaceMesh.m
    ├── SurfaceMovie.m
    ├── SurfaceRegions.m
    └── utilities
        ├── arrow3D.m
        ├── AxisToOrigin.m
        ├── GroupRegions.m
        ├── imrotateticklabel.m
        ├── makedoi.m
        ├── mpgwrite.mexa64
        ├── rotatePoints.m
        └── xticklabel_rotate.m

    2 directories, 54 files


