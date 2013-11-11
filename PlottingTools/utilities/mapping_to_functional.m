%% Create a Mapping structure from Connectivity regions to functional regions.
%
%
% ARGUMENTS:
%        options -- Options structure.
%
% OUTPUT: 
%        Mapping -- Mapping structure.
%
% REQUIRES: 
%        GroupRegions() -- Create a structure that groups connectivity regions
%                          into larger functional regions.
%
% USAGE:
%{
    options.Connectivity.WhichMatrix = 'RM_AC';
    options.Connectivity = GetConnectivity(options.Connectivity);
    Mapping = mapping_to_functional(options);
%}
%


function Mapping = mapping_to_functional(options)
  
  %Unpack what we need from options.
  M = options.Connectivity.NumberOfNodes;
  NodeStr = options.Connectivity.NodeStr;
  ThisMatrix = options.Connectivity.WhichMatrix;
  if ~isfield(options.Connectivity, 'GroupBy'),
    options.Connectivity.GroupBy = 'RestStateNetwork';
  end
  
  %Cerate a Regions structure
  Regions = GroupRegions(ones(M,1), 1:M, NodeStr, ThisMatrix, options.Connectivity);
  
  %Convert Regions into a sparse ProjectionMatrix and create a Mapping structure
  RegionNames = fieldnames(Regions);
  N = length(RegionNames);
  NumNonZero = M;
  Mapping.ProjectionMatrix = spalloc(M, N, NumNonZero);
  for k=1:N,
    ThisRegionIndxs = logical(Regions.(RegionNames{k}));
    Mapping.ProjectionMatrix(ThisRegionIndxs,k) = 1./sum(ThisRegionIndxs); %approx normalise region area 
  end
  Mapping.ProjectionLables = RegionNames;

end %function mapping_to_functional()
