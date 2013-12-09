%% Set derived parameters for a specified model, that is paramters that
% are not supposed to be freely set but rather are calculated from other 
% parameters. 
%
% ARGUMENTS:
%           options -- BrainNetwrorkModels options structure, with
%                      parameters set via SetDynamciParameters(),
%                      SetIntegrationParameters(), and GetConnectivity().
%
% OUTPUT: 
%           options -- An updated BrainNetwrorkModels options structure,
%                      with new derived parameter fields filled.
%
% REQUIRES: 
%        GetLinearIndex() -- 
%        DiscreteLaplacian_1D() -- for Model=>BRRW
%        
%        
%
% USAGE:
%{
      %Specify a connectivty matrix
      options.Connectivity.WhichMatrix = 'RM_AC';
      options.Connectivity = GetConnectivity(options.Connectivity);

      %Specify a local dynamic model
      options.Dynamics.WhichModel = 'FHN';
      options.Dynamics = SetDynamicParameters(options.Dynamics);
      options = SetIntegrationParameters(options);
      
      options = SetDerivedParameters(options)
%}
%
% MODIFICATION HISTORY:
%     SAK(<dd-mm-yyyy>) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function options = SetDerivedParameters(options)
 
 options.Connectivity.maxdelay = max(options.Connectivity.delay(:));            %longest single step time delay
 options.Integration.maxdelayiters = round(options.Connectivity.maxdelay/options.Integration.dt)+1; %maxdelay in integration steps
 
 options.Integration.dtt = options.Integration.dt/2;
 
 %-----------------------------------------------------------------------%
 %%

 switch options.Dynamics.WhichModel
   case {'BRRWtess'}%%% Populations Sigma() acts on don't seem to make sense, but this is what MB's code did... %%% 
     options.Connectivity.maxdelay = max([options.Connectivity.delay(:).'  options.Dynamics.CTdelay  options.Dynamics.TCdelay]); %longest single step time delay
     options.Integration.maxdelayiters = round(options.Connectivity.maxdelay/options.Integration.dt)+1; %maxdelay in integration steps
     options.Dynamics.NumberOfModes = 1;
     
     options.Dynamics.Discretization = options.Connectivity.NumberOfNodes;
     
     options.Dynamics.gamma_e = options.Dynamics.v ./ options.Dynamics.r_e;
     options.Dynamics.axb     = options.Dynamics.alfa .* options.Dynamics.btta;
     options.Dynamics.apb     = options.Dynamics.alfa + options.Dynamics.btta;
     options.Dynamics.dtcsf   = options.Integration.dt*options.Dynamics.csf;
     
     options.Dynamics.phi_n = 1e-3.*ones(options.Integration.iters+options.Integration.maxdelayiters, options.Connectivity.NumberOfNodes);
     
     if numel(options.Dynamics.CTdelay) == 1,
       options.Dynamics.CTlidelay = GetLinearIndex(options.Dynamics.CTdelay.*ones(1,options.Connectivity.NumberOfVertices), options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt);
     else
       options.Dynamics.CTlidelay = GetLinearIndex(options.Dynamics.CTdelay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt);
     end
     if numel(options.Dynamics.TCdelay) == 1,
       options.Dynamics.TClidelay = GetLinearIndex(options.Dynamics.TCdelay.*ones(1,options.Connectivity.NumberOfVertices), options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt);
     else
       options.Dynamics.TClidelay = GetLinearIndex(options.Dynamics.TCdelay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt);
     end
    
     %%%keyboard
     %-----------------------------------------------------------------------%

     %% Convert the provided time delays into a linear index for use in integration...
     
     options.Integration.lidelay = GetLinearIndex(options.Connectivity.delay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt, options.Dynamics.NumberOfModes);
 
     %Explicitly rotate matrices to avoid implicit rotation within integration loop.
     options.Integration.lidelay = options.Integration.lidelay.';
     
     if ~isfield(options.Connectivity, 'HaveRotatedWeights') || ~(options.Connectivity.HaveRotatedWeights == true), %FIXME: UGLY HACK...
       options.Connectivity.weights = options.Connectivity.weights.'; 
       options.Connectivity.HaveRotatedWeights = true;
     end
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case {'BRRW'}%%% Populations Sigma() acts on don't seem to make sense, but this is what MB's code did... %%% 
     options.Connectivity.maxdelay = max([options.Connectivity.delay(:).'  options.Dynamics.CTdelay  options.Dynamics.TCdelay]); %longest single step time delay
     options.Integration.maxdelayiters = round(options.Connectivity.maxdelay/options.Integration.dt)+1; %maxdelay in integration steps
     options.Dynamics.NumberOfModes = 1;
     
     options.Dynamics.Discretization = options.Connectivity.NumberOfNodes;
     
     options.Dynamics.gamma_e = options.Dynamics.v ./ options.Dynamics.r_e;
     options.Dynamics.Delta_x = options.Dynamics.CorticalCircumference ./ options.Dynamics.Discretization;
     options.Dynamics.LapOp   = DiscreteLaplacian_1D(options.Connectivity.NumberOfNodes, 3) ./ options.Dynamics.Delta_x.^2;
     options.Dynamics.axb     = options.Dynamics.alfa .* options.Dynamics.btta;
     options.Dynamics.apb     = options.Dynamics.alfa + options.Dynamics.btta;
     options.Dynamics.dtcsf   = options.Integration.dt*options.Dynamics.csf;
    
     options.Dynamics.phi_n = 1e-3.*ones(options.Integration.iters+options.Integration.maxdelayiters, options.Connectivity.NumberOfNodes);
     
     if numel(options.Dynamics.CTdelay) == 1,
       options.Dynamics.CTlidelay = GetLinearIndex(options.Dynamics.CTdelay.*ones(1,options.Connectivity.NumberOfNodes), options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt);
     else
       options.Dynamics.CTlidelay = GetLinearIndex(options.Dynamics.CTdelay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt);
     end
     if numel(options.Dynamics.TCdelay) == 1,
       options.Dynamics.TClidelay = GetLinearIndex(options.Dynamics.TCdelay.*ones(1,options.Connectivity.NumberOfNodes), options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt);
     else
       options.Dynamics.TClidelay = GetLinearIndex(options.Dynamics.TCdelay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt);
     end
    
     %%%keyboard
     %-----------------------------------------------------------------------%

     %% Convert the provided time delays into a linear index for use in integration...
     
     options.Integration.lidelay = GetLinearIndex(options.Connectivity.delay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt, options.Dynamics.NumberOfModes);
 
     %Explicitly rotate matrices to avoid implicit rotation within integration loop.
     options.Integration.lidelay = options.Integration.lidelay.';
     
     if ~isfield(options.Connectivity, 'HaveRotatedWeights') || ~(options.Connectivity.HaveRotatedWeights == true), %FIXME: UGLY HACK...
       options.Connectivity.weights = options.Connectivity.weights.'; 
       options.Connectivity.HaveRotatedWeights = true;
     end
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'AFR'}
     options.Connectivity.maxdelay = max(1e-3.*options.Connectivity.delay(:)); %longest single step time delay
     options.Integration.maxdelayiters = round(options.Connectivity.maxdelay/options.Integration.dt)+1; %maxdelay in integration steps
     options.Dynamics.NumberOfModes = 1;
     
     options.Dynamics.Discretization = options.Connectivity.NumberOfNodes;
     
     options.Dynamics.gamma       = options.Dynamics.v ./ options.Dynamics.r_e;
     options.Dynamics.Delta_x       = options.Dynamics.CorticalCircumference ./ options.Dynamics.Discretization;
     load('LapOp_freesurftess.mat') ; % load('LapOp_AFR.mat')
     options.Dynamics.LapOp         = LapOp;
     options.Dynamics.axb           = options.Dynamics.alfa .* options.Dynamics.btta;
     options.Dynamics.apb           = options.Dynamics.alfa + options.Dynamics.btta;
     options.Dynamics.dtcsf         = options.Integration.dt*options.Dynamics.csf;
     
     options.Dynamics.phi_n = repmat(double(options.Connectivity.ThalamicNodes(options.Connectivity.RegionMapping)), [options.Integration.iters+options.Integration.maxdelayiters 1]); 
 
     %%%options.Dynamics.phi_n = zeros(options.Integration.iters+options.Integration.maxdelayiters, options.Connectivity.NumberOfVertices);
     %%%options.Dynamics.phi_n(options.Connectivity.ThalamicNodes) = 1;
     
     %%%keyboard
     %-----------------------------------------------------------------------%

     %% Convert the provided time delays into a linear index for use in integration...
     
     options.Integration.lidelay = GetLinearIndex(1e-3.*options.Connectivity.delay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt, options.Dynamics.NumberOfModes);
 
     %Explicitly rotate matrices to avoid implicit rotation within integration loop.
     options.Integration.lidelay = options.Integration.lidelay.';
     
     if ~isfield(options.Connectivity, 'HaveRotatedWeights') || ~(options.Connectivity.HaveRotatedWeights == true), %FIXME: UGLY HACK...
       options.Connectivity.weights = options.Connectivity.weights.'; 
       options.Connectivity.HaveRotatedWeights = true;
     end
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'SNX'}
     options.Dynamics.NumberOfModes = 1;
     options.Dynamics.dtcsf = options.Integration.dt*options.Dynamics.csf;
     %% Convert the provided time delays into a linear index for use in integration...
     
     options.Integration.lidelay = GetLinearIndex(options.Connectivity.delay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt, options.Dynamics.NumberOfModes);
 
     %Explicitly rotate matrices to avoid implicit rotation within integration loop.
     options.Integration.lidelay = options.Integration.lidelay.';
     
     if ~isfield(options.Connectivity, 'HaveRotatedWeights') || ~(options.Connectivity.HaveRotatedWeights == true), %FIXME: UGLY HACK...
       options.Connectivity.weights = options.Connectivity.weights.'; 
       options.Connectivity.HaveRotatedWeights = true;
     end
     
     options.Dynamics.sqrtQxdt = sqrt(options.Dynamics.Qx * options.Integration.dt);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'FHN','FHNtess'}
     options.Dynamics.NumberOfModes = 1;
     options.Dynamics.dttauc = options.Integration.dt*options.Dynamics.tau*options.Dynamics.csf;
     %% Convert the provided time delays into a linear index for use in integration...
     
     options.Integration.lidelay = GetLinearIndex(options.Connectivity.delay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt, options.Dynamics.NumberOfModes);
 
     %Explicitly rotate matrices to avoid implicit rotation within integration loop.
     options.Integration.lidelay = options.Integration.lidelay.';
     
     if ~isfield(options.Connectivity, 'HaveRotatedWeights') || ~(options.Connectivity.HaveRotatedWeights == true), %FIXME: UGLY HACK...
       options.Connectivity.weights = options.Connectivity.weights.'; 
       options.Connectivity.HaveRotatedWeights = true;
     end
     
     options.Dynamics.sqrtQfdt = sqrt(options.Dynamics.Qf * options.Integration.dt);
     options.Dynamics.sqrtQsdt = sqrt(options.Dynamics.Qs * options.Integration.dt);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'ReducedFHN','ReducedFHNtess' }
     options = reduced_coefficients(options);
     options.Dynamics.NumberOfModes = length(options.Dynamics.A);
     options.Dynamics.dttauc = options.Integration.dt*options.Dynamics.tau*options.Dynamics.csf;

     %% Convert the provided time delays into a linear index for use in integration...
     
     options.Integration.lidelay = GetLinearIndex(options.Connectivity.delay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt, options.Dynamics.NumberOfModes);
 
     options.Dynamics.sqrtQxdt = sqrt(options.Dynamics.Qx * options.Integration.dt);
     options.Dynamics.sqrtQydt = sqrt(options.Dynamics.Qy * options.Integration.dt);
     options.Dynamics.sqrtQzdt = sqrt(options.Dynamics.Qz * options.Integration.dt);
     options.Dynamics.sqrtQwdt = sqrt(options.Dynamics.Qw * options.Integration.dt);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'ReducedHMR', 'ReducedHMRtess'}
     options = reduced_coefficients(options);
     options.Dynamics.NumberOfModes = length(options.Dynamics.A);
     options.Dynamics.dtcsf = options.Integration.dt*options.Dynamics.csf;

     %% Convert the provided time delays into a linear index for use in integration...
     
     options.Integration.lidelay = GetLinearIndex(options.Connectivity.delay, options.Integration.iters, options.Integration.maxdelayiters, options.Integration.dt, options.Dynamics.NumberOfModes);
 
     options.Dynamics.sqrtQxdt = sqrt(options.Dynamics.Qx * options.Integration.dt);
     options.Dynamics.sqrtQydt = sqrt(options.Dynamics.Qy * options.Integration.dt);
     options.Dynamics.sqrtQzdt = sqrt(options.Dynamics.Qz * options.Integration.dt);
     options.Dynamics.sqrtQwdt = sqrt(options.Dynamics.Qw * options.Integration.dt);
     options.Dynamics.sqrtQvdt = sqrt(options.Dynamics.Qv * options.Integration.dt);
     options.Dynamics.sqrtQudt = sqrt(options.Dynamics.Qu * options.Integration.dt);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     
   otherwise
 end

end %function SetDerivedParameters()
