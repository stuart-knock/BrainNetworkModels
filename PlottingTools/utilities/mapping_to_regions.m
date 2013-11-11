%% Create a Mapping structure from surface to Connectivity regions.
%
%
% ARGUMENTS:
%        options -- Options structure.
%
% OUTPUT: 
%        Mapping -- Mapping structure.
%
% REQUIRES: 
%        none
%
% USAGE:
%{
    ThisSurface = 'reg13';
    options.Connectivity.WhichMatrix = O52R00_IRP2008';
    options.Connectivity = GetConnectivity(options.Connectivity);
    %Region mapping data
    load(['RegionMapping_' ThisSurface '_' ThisConnectivity '.mat'])
    options.Connectivity.RegionMapping = RegionMapping;
    Mapping = mapping_to_regions(options);
%}
%


function Mapping = mapping_to_regions(options)
  
  %Unpack what we need from options.
  M = length(options.Connectivity.RegionMapping);
  ThisMatrix = options.Connectivity.WhichMatrix;
  if ~isfield(options.Connectivity, 'GroupBy'),
    options.Connectivity.GroupBy = 'RestStateNetwork';
  end
  
  %Create a sparse ProjectionMatrix and create a Mapping structure
  RegionNames = options.Connectivity.NodeStr;
  N = length(RegionNames);
  NumNonZero = M;
  Mapping.ProjectionMatrix = spalloc(M, N, NumNonZero);
  for k=1:N,
    ThisRegionVertices = options.Connectivity.RegionMapping==k;
    Mapping.ProjectionMatrix(ThisRegionVertices,k) = 1./sum(ThisRegionVertices); %approx normalise region area 
  end
  Mapping.ProjectionLables = RegionNames;

end %function mapping_to_functional()
