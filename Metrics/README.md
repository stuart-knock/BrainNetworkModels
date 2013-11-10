# Metrics

This directory provides *high level* functions for calculating weighted graph
metrics. The sub-directory Weighted_Graph contains the basic graph metric
functions. Most of the basic functions represent a small, and old, subset of 
Olaf's [Brain Connectivity Toolbox](https://sites.google.com/site/bctnet/), 
with some minor modifications for the current purposes. 

If you want to do any significant graph analysis, I suggest you obtain and use
[BCT](https://sites.google.com/site/bctnet/). These functions are here, 
primarily, to support the PlotGraphMetrics() plotting tool, which is intended
to provide a quick over of a Connectivity's graph properties.

These *high level* functions were originally written to operate on functional
connectivity matrices produced from experimental work, so they include an 
allowance for handling multiple graphs as *epochs*, ie derived from data of
different time periods...


### Usage:

See the headers for individual files as well as PlotGraphMetrics.m in the 
PlottingTools directory.


### Directory Contents:
    
    tree
    .
    ├── BetweenessCentrality.m
    ├── ClusteringCoefficients.m
    ├── Degrees.m
    ├── PathLengths.m
    ├── README.md
    └── Weighted_Graph
        ├── BCwei.m
        ├── diacut.m
        ├── Dwei.m
        ├── latrand.m
        ├── randedges.m
        ├── randmiod.m
        ├── README.md
        └── weiCC.m

    1 directory, 13 files
