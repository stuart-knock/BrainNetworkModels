%% Spatialize dynamic parameters of the model. To supports inhomogeneiety
% accross the cortical surface.
%
% ARGUMENTS:
%           options -- An initialised BrainNetworkModels options structure.
%           TheseParameters -- cell array of strings specifying parameters
%                              to spatialise
%
% OUTPUT: 
%           options -- input with requested parameters spatialised...
%
% REQUIRES: 
%           none
%
% USAGE:
%{
   %For epilepsy work...   
    TheseParameters = {'nu_se'};
    options = SpatializeDynamicParameters(options, TheseParameters);
%}
%
% MODIFICATION HISTORY:
%     SAK(24-10-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function options = SpatializeDynamicParameters(options, TheseParameters)  
%% Set defaults for any argument that weren't specified
 if nargin<2,
  error(['BrainNetworkModels:' mfilename ':ParamtersMustBeSpecified'],'The parameters you want Spatialized must be specified...');
 end
 
 for k = 1:length(TheseParameters),
   if ~isnumeric(options.Dynamics.(TheseParameters{k})),
     error(['BrainNetworkModels:' mfilename ':OnlyDefinedForNumericTypes'], ['The requested parameter ''' TheseParameters{k} ''' is not numeric... This operation doesn''t make sense for non-numeric.']);
   end
 end
 
%% Do the stuff...
 for k = 1:length(TheseParameters),
   if numel(options.Dynamics.(TheseParameters{k}))==1, %Check not already done
    options.Dynamics.(TheseParameters{k}) = repmat(options.Dynamics.(TheseParameters{k}), [1 options.Connectivity.NumberOfVertices]);
   else
     warning(['BrainNetworkModels:' mfilename ':AlreadySpatialised'], ['The requested parameter ''' TheseParameters{k} '''has already been spatialised ...']);
   end
 end
 
end %function SpatializeDynamicParameters()
