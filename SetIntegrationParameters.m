%% Set integration parameters for a specified model
%
% ARGUMENTS:
%           options -- BrainNetwrorkModels options structure, where at
%                      least the options.Dynamics.WhichModel field has been
%                      filled.
%
% OUTPUT: 
%           options -- An updated BrainNetwrorkModels options structure,
%                      with new Integration parameter fields filled.
%
% REQUIRES: 
%        MergeStructures() --
%
% USAGE:
%{
      options.Dynamics.WhichModel = 'FHN';
      options = SetIntegrationParameters(options);
%}
%
% MODIFICATION HISTORY:
%     SAK(<dd-mm-yyyy>) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function options = SetIntegrationParameters(options)
  
  %Set integration defaults
  defaults.verbosity = 0;
  %
  if isfield(options,'Other'),
    options.Other = MergeStructures(options.Other, defaults);
  else 
    options.Other = MergeStructures(defaults);
  end
  
  %
  switch options.Dynamics.WhichModel
    case {'BRRWtess'} 
      %128 milliseconds @ 8e3Hz
      options.Integration.dt = 2^-3;
      options.Integration.iters = 2^10;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'AFRtess'}
      %64 milliseconds @ 16e3Hz
      options.Integration.dt = 2^-4;
      options.Integration.iters = 2^10;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'BRRW'} 
      %1024 milliseconds @ 64e3Hz
      options.Integration.dt = 2^-5;
      options.Integration.iters = 2^15;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'AFR'}
      %4 seconds @ 4096Hz
      options.Integration.dt = 2^-12;
      options.Integration.iters = 2^14;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'SNX'}
      %256 milliseconds @ 64e3 Hz
      options.Integration.dt = 2^-6;
      options.Integration.iters = 2^14;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'FHN'}
      %256 milliseconds @ 256e3 Hz
      options.Integration.dt = 2^-8;
      options.Integration.iters = 2^16;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'FHNtess'}
      %16 milliseconds @ 64e3Hz
      options.Integration.dt = 2^-6;
      options.Integration.iters = 2^10;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'ReducedFHN'}
      %256 milliseconds @ 64e3 Hz
      options.Integration.dt = 2^-6;
      options.Integration.iters = 2^14;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'ReducedFHNtess'}
      %16 milliseconds @ 64e3Hz
      options.Integration.dt = 2^-6;
      options.Integration.iters = 2^10;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'ReducedHMR'}
      %256 milliseconds @ 64e3 Hz
      options.Integration.dt = 2^-6;
      options.Integration.iters = 2^14;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'ReducedHMRtess'}
      %16 milliseconds @ 64e3Hz
      options.Integration.dt = 2^-6;
      options.Integration.iters = 2^10;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    otherwise
  end

end %function SetIntegrationParameters()
