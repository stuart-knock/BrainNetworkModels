%% Set Initial Conditions based on Connectivity+Model+Integrator
%
% ARGUMENTS:
%           options -- usual options structure
%
% OUTPUT: 
%           options -- input structure updated with InitialConditions
%
% REQUIRES: 
%        Sigma() -- for BRRW and AFR Models
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(<dd-mm-yyyy>) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function options = SetInitialConditions(options)
  
  if isfield(options.Dynamics,'InitialConditions'),
    options.Dynamics = rmfield(options.Dynamics,'InitialConditions');
  end
  
  %Set RandStream to a state consistent with InitialConditions.
  options.Dynamics.InitialConditions.StateRand  = 5489;
  if isoctave(),
    rand('seed', options.Dynamics.InitialConditions.StateRand);
    temp = rand(625, 1); % This can't be the only way to simply seed a state...
    rand('state', temp);
    options.Dynamics.InitialConditions.ThisRandomStream.State = rand('state');
    options.Dynamics.InitialConditions.StateRand = rand('state');
  else %Presumably Matlab
    options.Dynamics.InitialConditions.ThisRandomStream = RandStream.create('mt19937ar','seed', options.Dynamics.InitialConditions.StateRand);
    RandStream.setDefaultStream(options.Dynamics.InitialConditions.ThisRandomStream);
    options.Dynamics.InitialConditions.StateRand  = options.Dynamics.InitialConditions.ThisRandomStream.State;
  end
  
  NumberOfNodes = options.Connectivity.NumberOfNodes;
  NumberOfModes = options.Dynamics.NumberOfModes;
  maxdelayiters = options.Integration.maxdelayiters;

%%
  switch options.Dynamics.WhichModel
    case {'BRRWtess'}%%% Populations Sigma() acts on don't seem to make sense, but this is what MB's code did... %%% 
      options.Dynamics.StateVariables = {'phi_e', 'dphi_e', 'V_e', 'dV_e', 'V_s', 'dV_s', 'V_r', 'dV_r'};
     
      switch options.Dynamics.BrainState
        case{'absence','petitmal'}
          MagicNumber1 = 0.005;
          MagicNumber2 = 0.004;
        case{'tonicclonic','grandmal'}
          MagicNumber1 = 0.010;
          MagicNumber2 = 0.009;
        case{'ec'}
          MagicNumber1 = 0.0093;
          MagicNumber2 = 0.0087;
        case{'eo'}
          MagicNumber1 = 0.0063;
          MagicNumber2 = 0.0055;
        otherwise
      end
      
      %Calculate at region level
      rV = MagicNumber1 + 0.1e-3*rand(maxdelayiters,NumberOfNodes)./2;
      SigrVi = Sigma(rV, options.Dynamics.Qmax, options.Dynamics.Theta_e, options.Dynamics.sigma_e, 'inverse');
      options.Dynamics.InitialConditions.phi_e  = rV;
      options.Dynamics.InitialConditions.dphi_e = zeros(1,NumberOfNodes);
      options.Dynamics.InitialConditions.V_e    = SigrVi;
      options.Dynamics.InitialConditions.dV_e   = zeros(1,NumberOfNodes);
      options.Dynamics.InitialConditions.V_s    = vs(SigrVi, options);
      options.Dynamics.InitialConditions.dV_s   = zeros(1,NumberOfNodes);
      options.Dynamics.InitialConditions.V_r    = options.Dynamics.nu_re.*Sigma(Sigma(MagicNumber2, options.Dynamics.Qmax, options.Dynamics.Theta_e, options.Dynamics.sigma_e, 'inverse'), options.Dynamics.Qmax,options.Dynamics.Theta_r,options.Dynamics.sigma_r) ...
                               +options.Dynamics.nu_rs.*Sigma(options.Dynamics.nu_re.*Sigma(SigrVi, options.Dynamics.Qmax,options.Dynamics.Theta_r,options.Dynamics.sigma_r), options.Dynamics.Qmax,options.Dynamics.Theta_r,options.Dynamics.sigma_r);
      options.Dynamics.InitialConditions.dV_r   = zeros(1,NumberOfNodes);
      
      %Map to surface
      options.Dynamics.phi_n = 1e-3.*ones(options.Integration.iters,options.Connectivity.NumberOfVertices);
      
      options.Dynamics.InitialConditions.dphi_e = zeros(1,options.Connectivity.NumberOfVertices);
      options.Dynamics.InitialConditions.dV_e   = zeros(1,options.Connectivity.NumberOfVertices);
      options.Dynamics.InitialConditions.dV_s   = zeros(1,options.Connectivity.NumberOfVertices);
      options.Dynamics.InitialConditions.dV_r   = zeros(1,options.Connectivity.NumberOfVertices);
      
      tempphi_e = options.Dynamics.InitialConditions.phi_e ;
      options.Dynamics.InitialConditions.phi_e = zeros(options.Integration.maxdelayiters,options.Connectivity.NumberOfVertices);
      for n = 1:options.Connectivity.NumberOfNodes,
        options.Dynamics.InitialConditions.phi_e(:,options.Connectivity.RegionMapping==n) = repmat(tempphi_e(:,n), [1 sum(options.Connectivity.RegionMapping==n)]);
      end
      clear tempphi_e
      
      tempV_e = options.Dynamics.InitialConditions.V_e ;
      options.Dynamics.InitialConditions.V_e = zeros(options.Integration.maxdelayiters,options.Connectivity.NumberOfVertices);
      for n = 1:options.Connectivity.NumberOfNodes,
        options.Dynamics.InitialConditions.V_e(:,options.Connectivity.RegionMapping==n) = repmat(tempV_e(:,n), [1 sum(options.Connectivity.RegionMapping==n)]);
      end
      clear tempV_e
      
      tempV_s = options.Dynamics.InitialConditions.V_s ;
      options.Dynamics.InitialConditions.V_s = zeros(options.Integration.maxdelayiters,options.Connectivity.NumberOfVertices);
      for n = 1:options.Connectivity.NumberOfNodes,
        options.Dynamics.InitialConditions.V_s(:,options.Connectivity.RegionMapping==n) = repmat(tempV_s(:,n), [1 sum(options.Connectivity.RegionMapping==n)]);
      end
      clear tempV_s
      
      tempV_r = options.Dynamics.InitialConditions.V_r ;
      options.Dynamics.InitialConditions.V_r = zeros(options.Integration.maxdelayiters,options.Connectivity.NumberOfVertices);
      for n = 1:options.Connectivity.NumberOfNodes,
        options.Dynamics.InitialConditions.V_r(:,options.Connectivity.RegionMapping==n) = repmat(tempV_r(:,n), [1 sum(options.Connectivity.RegionMapping==n)]);
      end
      clear tempV_r
      
      options.Dynamics.InitialConditions.V_e = options.Dynamics.InitialConditions.V_e(end, :);
      options.Dynamics.InitialConditions.V_r = options.Dynamics.InitialConditions.V_r(end, :);
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case {'BRRW'}%%% Populations Sigma() acts on don't seem to make sense, but this is what MB's code did... %%% 
      options.Dynamics.StateVariables = {'phi_e', 'dphi_e', 'V_e', 'dV_e', 'V_s', 'dV_s', 'V_r', 'dV_r'};
     
      switch options.Dynamics.BrainState
        case{'absence','petitmal'}
          MagicNumber1 = 0.005;
          MagicNumber2 = 0.004;
        case{'tonicclonic','grandmal'}
          MagicNumber1 = 0.010;
          MagicNumber2 = 0.009;
        case{'ec'}
          MagicNumber1 = 0.0093;
          MagicNumber2 = 0.0087;
        case{'eo'}
          MagicNumber1 = 0.0063;
          MagicNumber2 = 0.0055;
        otherwise
      end
      
      rV = MagicNumber1 + rand(maxdelayiters, NumberOfNodes) * ((options.Dynamics.Qmax - MagicNumber1) / 10.0);
      SigrVi = Sigma(rV, options.Dynamics.Qmax, options.Dynamics.Theta_e, options.Dynamics.sigma_e, 'inverse');
      options.Dynamics.InitialConditions.phi_e  = rV;
      options.Dynamics.InitialConditions.dphi_e = zeros(1,NumberOfNodes);
      options.Dynamics.InitialConditions.V_e    = SigrVi;
      options.Dynamics.InitialConditions.dV_e   = zeros(1,NumberOfNodes);
      options.Dynamics.InitialConditions.V_s    = vs(SigrVi, options);
      options.Dynamics.InitialConditions.dV_s   = zeros(1,NumberOfNodes);
      options.Dynamics.InitialConditions.V_r    = options.Dynamics.nu_re.*Sigma(Sigma(MagicNumber2, options.Dynamics.Qmax, options.Dynamics.Theta_e, options.Dynamics.sigma_e, 'inverse'), options.Dynamics.Qmax,options.Dynamics.Theta_r,options.Dynamics.sigma_r) ...
                               +options.Dynamics.nu_rs.*Sigma(options.Dynamics.nu_re.*Sigma(SigrVi, options.Dynamics.Qmax,options.Dynamics.Theta_r,options.Dynamics.sigma_r), options.Dynamics.Qmax,options.Dynamics.Theta_r,options.Dynamics.sigma_r);
      options.Dynamics.InitialConditions.dV_r   = zeros(1,NumberOfNodes);
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'AFR'}
      options.Dynamics.StateVariables = {'phi', 'dphi', 'V', 'dV'};
      
      MagicNumber1 = 0.012;
      MagicNumber2 = 0.011;
      
      rV = MagicNumber1 + rand(maxdelayiters,options.Connectivity.NumberOfVertices)./2;
      SigrVi = Sigma(rV, options.Dynamics.Qmax, options.Dynamics.Theta_e, options.Dynamics.sigma_e, 'inverse');
      options.Dynamics.InitialConditions.phi  = rV;
      options.Dynamics.InitialConditions.dphi = zeros(1,options.Connectivity.NumberOfVertices);
      options.Dynamics.InitialConditions.V    = SigrVi;
      options.Dynamics.InitialConditions.dV   = zeros(1,options.Connectivity.NumberOfVertices);
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'FHN'}
      options.Dynamics.StateVariables = {'V', 'W'};
      
      options.Dynamics.InitialConditions.V = rand(maxdelayiters,NumberOfNodes) + 0.5;
      options.Dynamics.InitialConditions.W = rand(1,NumberOfNodes)             - 0.5;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'FHNtess'}
      options.Dynamics.StateVariables = {'V', 'W'};
      
      options.Dynamics.InitialConditions.V = rand(maxdelayiters, options.Connectivity.NumberOfVertices) + 0.5;
      options.Dynamics.InitialConditions.W = rand(1,             options.Connectivity.NumberOfVertices) - 0.5;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'SNX'}
      options.Dynamics.StateVariables = {'X'};
      
      options.Dynamics.InitialConditions.X = randn(maxdelayiters,NumberOfNodes) .* 0.125;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'ReducedFHN'}
      options.Dynamics.StateVariables = {'Xi', 'Eta', 'Alfa', 'Btta'};
      
      options.Dynamics.InitialConditions.Xi   = rand(maxdelayiters,NumberOfNodes,NumberOfModes) - 0.5;
      options.Dynamics.InitialConditions.Eta  = rand(1,NumberOfNodes,NumberOfModes);
      options.Dynamics.InitialConditions.Alfa = rand(1,NumberOfNodes,NumberOfModes)         .*2 - 1.0;
      options.Dynamics.InitialConditions.Btta = rand(1,NumberOfNodes,NumberOfModes)             - 0.2;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'ReducedFHNtess'}
      options.Dynamics.StateVariables = {'Xi', 'Eta', 'Alfa', 'Btta'};
      
      options.Dynamics.InitialConditions.Xi   = rand(maxdelayiters,options.Connectivity.NumberOfVertices,NumberOfModes) - 0.5;
      options.Dynamics.InitialConditions.Eta  = rand(1,options.Connectivity.NumberOfVertices,NumberOfModes);
      options.Dynamics.InitialConditions.Alfa = rand(1,options.Connectivity.NumberOfVertices,NumberOfModes)         .*2 - 1.0;
      options.Dynamics.InitialConditions.Btta = rand(1,options.Connectivity.NumberOfVertices,NumberOfModes)             - 0.2;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'ReducedHMR'}
      options.Dynamics.StateVariables = {'Xi', 'Eta', 'Tau', 'Alfa', 'Btta', 'Gamma'};
      
      options.Dynamics.InitialConditions.Xi    = rand(maxdelayiters,NumberOfNodes,NumberOfModes) - 0.7;
      options.Dynamics.InitialConditions.Eta   = rand(1,NumberOfNodes,NumberOfModes)             - 0.5;
      options.Dynamics.InitialConditions.Tau   = rand(1,NumberOfNodes,NumberOfModes)             + 2.5;
      options.Dynamics.InitialConditions.Alfa  = rand(1,NumberOfNodes,NumberOfModes)             - 0.8;
      options.Dynamics.InitialConditions.Btta  = rand(1,NumberOfNodes,NumberOfModes)             - 0.5;
      options.Dynamics.InitialConditions.Gamma = rand(1,NumberOfNodes,NumberOfModes)             + 2.25;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case {'ReducedHMRtess'}
      options.Dynamics.StateVariables = {'Xi', 'Eta', 'Tau', 'Alfa', 'Btta', 'Gamma'};
      
      options.Dynamics.InitialConditions.Xi    = rand(maxdelayiters,options.Connectivity.NumberOfVertices,NumberOfModes) - 0.7;
      options.Dynamics.InitialConditions.Eta   = rand(1,options.Connectivity.NumberOfVertices,NumberOfModes)             - 0.5;
      options.Dynamics.InitialConditions.Tau   = rand(1,options.Connectivity.NumberOfVertices,NumberOfModes)             + 2.5;
      options.Dynamics.InitialConditions.Alfa  = rand(1,options.Connectivity.NumberOfVertices,NumberOfModes)             - 0.8;
      options.Dynamics.InitialConditions.Btta  = rand(1,options.Connectivity.NumberOfVertices,NumberOfModes)             - 0.5;
      options.Dynamics.InitialConditions.Gamma = rand(1,options.Connectivity.NumberOfVertices,NumberOfModes)             + 2.25;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    otherwise
  end

end %function SetInitialConditions()


%% Direct translation MB's code
function f=vs(V,options)
  nmax = 30;
  root = 0;
  for j=1:nmax
    x = options.Dynamics.nu_re.*Sigma(V, options.Dynamics.Qmax,options.Dynamics.Theta_r,options.Dynamics.sigma_r) ... 
       +options.Dynamics.nu_rs.*Sigma(root,options.Dynamics.Qmax,options.Dynamics.Theta_r,options.Dynamics.sigma_r);
    ff = -root + options.Dynamics.nu_sn.*options.Dynamics.phi_n(1:options.Integration.maxdelayiters,:) ... 
               + options.Dynamics.nu_se.*Sigma(V,options.Dynamics.Qmax,options.Dynamics.Theta_s,options.Dynamics.sigma_s) ... 
               + options.Dynamics.nu_sr.*Sigma(x,options.Dynamics.Qmax,options.Dynamics.Theta_s,options.Dynamics.sigma_s);
    fp = -1 + options.Dynamics.nu_sr.*options.Dynamics.nu_rs.*Sigma(x,options.Dynamics.Qmax,options.Dynamics.Theta_s,options.Dynamics.sigma_s, 'derivative').*Sigma(root,options.Dynamics.Qmax,options.Dynamics.Theta_s,options.Dynamics.sigma_s, 'derivative');
    root = root - ff./fp;
  end
  f = root; %%% real(root); %HACK:TODO: NEED TO FIGURE OUT WHY WE'RE GETTING COMPLEX root HERE...
end
