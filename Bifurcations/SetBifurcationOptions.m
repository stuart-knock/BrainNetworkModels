%% <Description>
%
% ARGUMENTS:
%           BrainState -- <description>
%
% OUTPUT: 
%           defaults -- <description>
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(06-01-2010) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function options = SetBifurcationOptions(options)

 switch options.Dynamics.WhichModel
   case {'BRRW'}
     defaults.Integrator           = 'BRRW_heun';
     switch lower(options.Dynamics.BrainState)
       case{'eo'}
         defaults.BifurcationParameter = 'csf';
         
       case{'ec'}
         defaults.BifurcationParameter = 'csf';
         
       case{'sleepstage1' 'ss1'}
       case{'sleepstage3' 'ss2'}
       case{'sleepstage2' 'ss3'}
         
       case{'absence' 'petitmal'}
         defaults.BifurcationParameter          = 'nu_se';
         defaults.InitialControlValue           = 10e-4; %Must be strongly stable fixed point...
         defaults.BifurcationParameterIncrement = 5e-4;
         defaults.TargetControlValue            = 40e-4;
         defaults.ErrorTolerance                = 1.0e-6;
         
         defaults.MaxContinuations = 65; %set to 0 for interactive
         defaults.IntegrationsToMergeForNonstable = 10; 
         defaults.AttemptForceFixedPoint = false;
         
       case{'tonicclonic' 'grandmal'}
         defaults.BifurcationParameter = 'csf';
         
       otherwise
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'FHN'}
%% 
     defaults.Integrator           = 'FHN_heun';
     defaults.BifurcationParameter = 'csf';
     defaults.BifurcationParameterIncrement = 0.0005;
     defaults.InitialControlValue  = 0.013;
     defaults.TargetControlValue   = 0.023;
     defaults.ErrorTolerance       = 1.000e-6; 
     
     defaults.MaxContinuations = 20; %set to 0 for interactive
     defaults.IntegrationsToMergeForNonstable = 10; 
     defaults.AttemptForceFixedPoint = false;

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'ReducedFHN'}
     defaults.Integrator           = 'ReducedFHN_heun';
     defaults.BifurcationParameter = 'csf';
     defaults.BifurcationParameterIncrement = 0.0005;
 options.Bifurcation.ErrorTolerance = 1e-6;
     
     defaults.MaxContinuations = 20; %set to 0 for interactive
     defaults.IntegrationsToMergeForNonstable = 10; 
     defaults.AttemptForceFixedPoint = false;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'ReducedHMR'}
     defaults.Integrator           = 'ReducedHMR_heun';
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
% % %    case {'<WhichModel>'}
% % % %% Default parameters 
% % %      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     
   otherwise
 end

 if isfield(options,'Bifurcation'),
   options.Bifurcation = MergeStructures(options.Bifurcation, defaults);
 else
   options.Bifurcation = defaults;
 end
 
end %function SetBifurcationOptions()
