%% Calculate coefficientrs for a Reduced FitzHugh-Nagumo oscillator based 
% neural field model.
%
% Implements equations for calculating coefficients found in the 
% supplemental material to (see ./docs directory):  
%    Stefanescu RA, Jirsa VK (2008), Neurons. PLoS Comput Biol 4(11).
%    "A Low Dimensional Description of Globally Coupled Heterogeneous Neural 
%     Networks of Excitatory and Inhibitory" 
%
% Uses Heun method
%
% ARGUMENTS:
%           options
%                  .WhichModel -- 
%           options.fhn -- A structure which can specify the arguments below:
%                      .g1(1,Discretisation) -- 
%                      .g2(1,Discretisation) -- 
%                      .V(NumberOfModes,Discretisation) --
%                      .U(NumberOfModes,Discretisation) --
%                      .Zv(1,Discretisation) -- 
%                      .Zu(1,Discretisation) -- 
%                      .a -- 
%           options.hmr -- A structure which can specify the arguments below: 
%                      .g1(1,Discretisation) -- 
%                      .g2(1,Discretisation) -- 
%                      .V(NumberOfModes,Discretisation) --
%                      .U(NumberOfModes,Discretisation) --
%                      .Iv(1,Discretisation) -- 
%                      .Iu(1,Discretisation) -- 
%                      .r -- 
%                      .s -- 
%                      .x0 --
%                      .a -- 
%                      .b -- 
%                      .c -- 
%                      .d -- 
%
% OUTPUT: 
%          options.(options.WhichModel) -- A structure which can specify the arguments below:
%                     .A(NumberOfModes,NumberOfModes) -- 
%                     .B(NumberOfModes,NumberOfModes) -- 
%                     .C(NumberOfModes,NumberOfModes) --   
%                     .a_i(NumberOfModes,1)  -- 
%                     .e_i(NumberOfModes,1)  --
%                     .b_i(NumberOfModes,1)  --
%                     .f_i(NumberOfModes,1)  --
%                     .c_i(NumberOfModes,1)  --
%                     .h_i(NumberOfModes,1)  -- 
%                     .IE_i(NumberOfModes,1) --
%                     .II_i(NumberOfModes,1) -- 
%                     .d_i(NumberOfModes,1)  --
%                     .p_i(NumberOfModes,1)  --   
%                     .m_i(NumberOfModes,1)  --  
%                     .n_i(NumberOfModes,1)  -- 
%
% USAGE:
%{
      %
       options = reduced_coefficients(options);
%}
%
% MODIFICATION HISTORY:
%     SAK(7-09-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function options = reduced_coefficients(options)

 
%% 
 switch options.Dynamics.WhichModel,
   case {'ReducedFHN','ReducedFHNtess'}
%%
    %Get sampling based on the inverse CDF for a Normal PDF (~equiv of ordering Normally distributed random variates...) 
     stepu = 1/(options.Dynamics.Nu+2-1);
     stepv = 1/(options.Dynamics.Nv+2-1);
     options.Dynamics.Zu = NormCDFinv(stepu:stepu:(1-stepu), options.Dynamics.mu, options.Dynamics.sigma); %
     options.Dynamics.Zv = NormCDFinv(stepv:stepv:(1-stepv), options.Dynamics.mu, options.Dynamics.sigma); %
       
    % 
     ModesSupplied = isfield(options.Dynamics,{'V','U'});
     if ~all(ModesSupplied),
       %warning(['BrainNetworkModels:' mfilename ':UnspecifiedOptions'],['Not all options needed to calculate the coefficients for the ReducedFHN model, missing the options: ' sprintf('%s, ', NecessaryOptions{~OptionsSupplied}) ' under options.Dynamics.' options.Dynamics.WhichModel '...']);
       
       %Define the modes
       options.Dynamics.V(1,:) = [ ones(options.Dynamics.Nv/3,1) ; zeros(options.Dynamics.Nv/3,1) ; zeros(options.Dynamics.Nv/3,1)];
       options.Dynamics.V(2,:) = [zeros(options.Dynamics.Nv/3,1) ;  ones(options.Dynamics.Nv/3,1) ; zeros(options.Dynamics.Nv/3,1)];
       options.Dynamics.V(3,:) = [zeros(options.Dynamics.Nv/3,1) ; zeros(options.Dynamics.Nv/3,1) ;  ones(options.Dynamics.Nv/3,1)];
       options.Dynamics.U(1,:) = [ ones(options.Dynamics.Nu/3,1) ; zeros(options.Dynamics.Nu/3,1) ; zeros(options.Dynamics.Nu/3,1)];
       options.Dynamics.U(2,:) = [zeros(options.Dynamics.Nu/3,1) ;  ones(options.Dynamics.Nu/3,1) ; zeros(options.Dynamics.Nu/3,1)];
       options.Dynamics.U(3,:) = [zeros(options.Dynamics.Nu/3,1) ; zeros(options.Dynamics.Nu/3,1) ;  ones(options.Dynamics.Nu/3,1)];  
     end
     
     %Normalise the modes
     options.Dynamics.V = options.Dynamics.V ./ repmat(sqrt(trapz(options.Dynamics.Zv, options.Dynamics.V .* options.Dynamics.V, 2)), [1 options.Dynamics.Nv]);
     options.Dynamics.U = options.Dynamics.U ./ repmat(sqrt(trapz(options.Dynamics.Zu, options.Dynamics.U .* options.Dynamics.U, 2)), [1 options.Dynamics.Nu]);
       
     %Get Normal PDF's evaluated with sampling Zv and Zu
     options.Dynamics.g1 = NormPDF(options.Dynamics.Zv, options.Dynamics.mu, options.Dynamics.sigma); %
     options.Dynamics.g2 = NormPDF(options.Dynamics.Zu, options.Dynamics.mu, options.Dynamics.sigma); %
     
     NumberOfModes = size(options.Dynamics.V, 1);
     
     switch options.Dynamics.WhichModel,
       case {'ReducedFHN'}
         NumberOfNodes = options.Connectivity.NumberOfNodes;
       case {'ReducedFHNtess'}
         NumberOfNodes = options.Connectivity.NumberOfVertices;
     end
     
     %If parameters aren't by node/vertex repmat them
     %If these aren't a single value they need to be repmatted by number of
     %modes and number of nodes.
     ModesNodesParams = {'b', 'tau', 'K11', 'K12', 'K21'};
                       
     for k=1:length(ModesNodesParams),
       if size(options.Dynamics.(ModesNodesParams{k}) , 1) == 1,
         options.Dynamics.(ModesNodesParams{k}) = repmat(options.Dynamics.(ModesNodesParams{k}), [NumberOfModes 1]);
       end
       if size(options.Dynamics.(ModesNodesParams{k}) , 2) == 1,
         options.Dynamics.(ModesNodesParams{k}) = repmat(options.Dynamics.(ModesNodesParams{k}), [1 NumberOfNodes]);
       end
     end
     
    %
     G1 = repmat(options.Dynamics.g1, [NumberOfModes 1]);
     G2 = repmat(options.Dynamics.g2, [NumberOfModes 1]);
     V  = options.Dynamics.V;
     U  = options.Dynamics.U;
     Zv = options.Dynamics.Zv;
     Zu = options.Dynamics.Zu;
     a  = options.Dynamics.a;
     
     RegionableParams = {'a'};
     for k=1:length(RegionableParams),
       if size(eval(RegionableParams{k}) , 1) == 1,
         eval([RegionableParams{k} '= repmat(' RegionableParams{k} ', [NumberOfModes 1]);']);
       end
       if size(eval(RegionableParams{k}) , 2) == 1,
         eval([RegionableParams{k} '= repmat(' RegionableParams{k} ', [1 NumberOfNodes]);']);
       end
     end

    %Precalculate repeated terms
     cV = conj(V);
     cU = conj(U);
     intcVdZ  = trapz(Zv, cV, 2);
     intG1VdZ = trapz(Zv, G1.*V, 2).';
     intcUdZ  = trapz(Zu, cU, 2);
     
    %Calculate coefficients 
     A = intcVdZ * intG1VdZ;
     B = intcVdZ * trapz(Zu, G2.*U, 2).';
     C = intcUdZ * intG1VdZ;

     e_i = repmat(trapz(Zv, cV.*V.^3, 2), [1 NumberOfNodes]);
     f_i = repmat(trapz(Zu, cU.*U.^3, 2), [1 NumberOfNodes]);

     IE_i = repmat(trapz(Zv, repmat(Zv, [NumberOfModes 1]).*cV, 2), [1 NumberOfNodes]);
     II_i = repmat(trapz(Zu, repmat(Zu, [NumberOfModes 1]).*cU, 2), [1 NumberOfNodes]);

     m_i = a .* repmat(intcVdZ, [1 NumberOfNodes]);
     n_i = a .* repmat(intcUdZ, [1 NumberOfNodes]);
     
     
%      switch options.Dynamics.WhichModel,
%        case {'ReducedFHN'}
%          %Expand 1D coefficients so we can .* them during integration
%          e_i  = repmat(e_i, [1 options.Connectivity.NumberOfNodes]);
%          f_i  = repmat(f_i, [1 options.Connectivity.NumberOfNodes]);
%          IE_i = repmat(IE_i,[1 options.Connectivity.NumberOfNodes]);
%          II_i = repmat(II_i,[1 options.Connectivity.NumberOfNodes]);
%          m_i  = repmat(m_i, [1 options.Connectivity.NumberOfNodes]);
%          n_i  = repmat(n_i, [1 options.Connectivity.NumberOfNodes]);
%        case {'ReducedFHNtess'}
%          %Expand 1D coefficients so we can .* them during integration
%          e_i  = repmat(e_i, [1 options.Connectivity.NumberOfVertices]);
%          f_i  = repmat(f_i, [1 options.Connectivity.NumberOfVertices]);
%          IE_i = repmat(IE_i,[1 options.Connectivity.NumberOfVertices]);
%          II_i = repmat(II_i,[1 options.Connectivity.NumberOfVertices]);
%          m_i  = repmat(m_i, [1 options.Connectivity.NumberOfVertices]);
%          n_i  = repmat(n_i, [1 options.Connectivity.NumberOfVertices]);
%      end
%keyboard
    %Assign coefficients to options structure for return
     options.Dynamics.A    = A;
     options.Dynamics.B    = B;
     options.Dynamics.C    = C;
     options.Dynamics.e_i  = e_i;
     options.Dynamics.f_i  = f_i;
     options.Dynamics.IE_i = IE_i;
     options.Dynamics.II_i = II_i;
     options.Dynamics.m_i  = m_i;
     options.Dynamics.n_i  = n_i;
  %-------------------------end case FHN----------------------------------%
     
  
   case {'ReducedHMR','ReducedHMRtess'}
%%
    %Check options for this model
     NecessaryOptions = {'g1', 'g2', 'V', 'U', 'Iv', 'Iu', 'r', 's', 'x0', 'a', 'b', 'c', 'd'};
     OptionsSupplied = isfield(options.Dynamics,NecessaryOptions);
     if ~all(OptionsSupplied),
       warning(['BrainNetworkModels:' mfilename ':UnspecifiedOptions'],['To calculate the coefficients for the Hindmarsh-Rose reduced model you need to specify the options: ' sprintf('%s, ', NecessaryOptions{~OptionsSupplied}) ' under ' options.Dynamics.WhichModel '...']);
       %Get sampling based on the inverse CDF for a Normal PDF (~equiv of ordering Normally distributed random variates...)
       Nu = options.Dynamics.Nu;
       Nv = options.Dynamics.Nv;
       stepu = 1/(Nu+2-1);
       stepv = 1/(Nv+2-1);
       options.Dynamics.Iu = NormCDFinv(stepu:stepu:(1-stepu), options.Dynamics.mu, options.Dynamics.sigma); %uniform in the CDF of I
       options.Dynamics.Iv = NormCDFinv(stepv:stepv:(1-stepv), options.Dynamics.mu, options.Dynamics.sigma); %uniform in the CDF of I
       
       %Define the modes
       options.Dynamics.V(1,:) = [ ones(Nv/3,1) ; zeros(Nv/3,1) ; zeros(Nv/3,1)];
       options.Dynamics.V(2,:) = [zeros(Nv/3,1) ;  ones(Nv/3,1) ; zeros(Nv/3,1)];
       options.Dynamics.V(3,:) = [zeros(Nv/3,1) ; zeros(Nv/3,1) ;  ones(Nv/3,1)];
       options.Dynamics.U(1,:) = [ ones(Nu/3,1) ; zeros(Nu/3,1) ; zeros(Nu/3,1)];
       options.Dynamics.U(2,:) = [zeros(Nu/3,1) ;  ones(Nu/3,1) ; zeros(Nu/3,1)];
       options.Dynamics.U(3,:) = [zeros(Nu/3,1) ; zeros(Nu/3,1) ;  ones(Nu/3,1)];
       
       %Normalise the modes
       options.Dynamics.V = options.Dynamics.V ./ repmat(sqrt(trapz(options.Dynamics.Iv, options.Dynamics.V .* options.Dynamics.V, 2)), [1 Nv]);
       options.Dynamics.U = options.Dynamics.U ./ repmat(sqrt(trapz(options.Dynamics.Iu, options.Dynamics.U .* options.Dynamics.U, 2)), [1 Nu]);
       
       %Get Normal PDF's evaluated with sampling Iv and Iu
       options.Dynamics.g1 = NormPDF(options.Dynamics.Iv, options.Dynamics.mu, options.Dynamics.sigma); %
       options.Dynamics.g2 = NormPDF(options.Dynamics.Iu, options.Dynamics.mu, options.Dynamics.sigma); %
     end
     
     NumberOfModes = size(options.Dynamics.V, 1);
     
     switch options.Dynamics.WhichModel,
       case {'ReducedHMR'}
         NumberOfNodes = options.Connectivity.NumberOfNodes;
       case {'ReducedHMRtess'}
         NumberOfNodes = options.Connectivity.NumberOfVertices;
     end
     
     %If parameters aren't by node/vertex repmat them
     %If these aren't a single value they need to be repmatted by number of
     %modes and number of nodes.
     ModesNodesParams = {'r', 's', 'K11', 'K12', 'K21'};
                       
     for k=1:length(ModesNodesParams),
       if size(options.Dynamics.(ModesNodesParams{k}) , 1) == 1,
         options.Dynamics.(ModesNodesParams{k}) = repmat(options.Dynamics.(ModesNodesParams{k}), [NumberOfModes 1]);
       end
       if size(options.Dynamics.(ModesNodesParams{k}) , 2) == 1,
         options.Dynamics.(ModesNodesParams{k}) = repmat(options.Dynamics.(ModesNodesParams{k}), [1 NumberOfNodes]);
       end
     end
     
    %
     G1 = repmat(options.Dynamics.g1, [NumberOfModes 1]);
     G2 = repmat(options.Dynamics.g2, [NumberOfModes 1]);
     V    = options.Dynamics.V;
     U    = options.Dynamics.U;
     Iu   = options.Dynamics.Iu;
     Iv   = options.Dynamics.Iv;
     rsx0 = options.Dynamics.r .* options.Dynamics.s .* options.Dynamics.x0;
     a    = options.Dynamics.a;
     b    = options.Dynamics.b;
     c    = options.Dynamics.c;
     d    = options.Dynamics.d;
     
     RegionableParams = {'a', 'b', 'c', 'd', 'rsx0'};
     for k=1:length(RegionableParams),
       if size(eval(RegionableParams{k}) , 1) == 1,
         eval([RegionableParams{k} '= repmat(' RegionableParams{k} ', [NumberOfModes 1]);']);
       end
       if size(eval(RegionableParams{k}) , 2) == 1,
         eval([RegionableParams{k} '= repmat(' RegionableParams{k} ', [1 NumberOfNodes]);']);
       end
     end
     

    %Precalculate repeated terms
     cV = conj(V);
     cU = conj(U);
     intcVdI  = trapz(Iv, cV, 2);
     intcUdI  = trapz(Iu, cU, 2);
     intG1VdI = trapz(Iv, G1.*V, 2).';

    %Calculate coefficients 
     A = intcVdI * intG1VdI;
     B = intcVdI * trapz(Iu, G2.*U, 2).';
     C = intcUdI * intG1VdI;

     a_i = a .* repmat(trapz(Iv, cV.*V.^3, 2), [1 NumberOfNodes]);
     e_i = a .* repmat(trapz(Iu, cU.*U.^3, 2), [1 NumberOfNodes]);

     b_i = b .* repmat(trapz(Iv, cV.*V.^2, 2), [1 NumberOfNodes]);
     f_i = b .* repmat(trapz(Iu, cU.*U.^2, 2), [1 NumberOfNodes]);

     c_i = c .* repmat(intcVdI, [1 NumberOfNodes]);
     h_i = c .* repmat(intcUdI, [1 NumberOfNodes]);

     IE_i = repmat(trapz(Iv, repmat(Iv, [NumberOfModes 1]).*cV, 2), [1 NumberOfNodes]);
     II_i = repmat(trapz(Iu, repmat(Iu, [NumberOfModes 1]).*cU, 2), [1 NumberOfNodes]);

     d_i = d .* repmat(intcVdI, [1 NumberOfNodes]);
     p_i = d .* repmat(intcUdI, [1 NumberOfNodes]);

     m_i = rsx0 .* repmat(intcVdI, [1 NumberOfNodes]);
     n_i = rsx0 .* repmat(intcUdI, [1 NumberOfNodes]);
     
%      %TODO: Conditionally repmat these, only if not already the right size.
%      %      if node/vertex level paramaters are specified they'll already
%      %      be the right size...
%      switch options.Dynamics.WhichModel,
%        case {'ReducedHMR'}
%          %Expand 1D coefficients so we can .* them during integration
%          a_i  = repmat(a_i, [1 options.Connectivity.NumberOfNodes]);
%          e_i  = repmat(e_i, [1 options.Connectivity.NumberOfNodes]);
%          b_i  = repmat(b_i, [1 options.Connectivity.NumberOfNodes]);
%          f_i  = repmat(f_i, [1 options.Connectivity.NumberOfNodes]);
%          c_i  = repmat(c_i, [1 options.Connectivity.NumberOfNodes]);
%          h_i  = repmat(h_i, [1 options.Connectivity.NumberOfNodes]);
%          IE_i = repmat(IE_i,[1 options.Connectivity.NumberOfNodes]);
%          II_i = repmat(II_i,[1 options.Connectivity.NumberOfNodes]);
%          d_i  = repmat(d_i, [1 options.Connectivity.NumberOfNodes]);
%          p_i  = repmat(p_i, [1 options.Connectivity.NumberOfNodes]);
%          m_i  = repmat(m_i, [1 options.Connectivity.NumberOfNodes]);
%          n_i  = repmat(n_i, [1 options.Connectivity.NumberOfNodes]);
%        case {'ReducedHMRtess'}
%          %Expand 1D coefficients so we can .* them during integration
%          a_i  = repmat(a_i, [1 options.Connectivity.NumberOfVertices]);
%          e_i  = repmat(e_i, [1 options.Connectivity.NumberOfVertices]);
%          b_i  = repmat(b_i, [1 options.Connectivity.NumberOfVertices]);
%          f_i  = repmat(f_i, [1 options.Connectivity.NumberOfVertices]);
%          c_i  = repmat(c_i, [1 options.Connectivity.NumberOfVertices]);
%          h_i  = repmat(h_i, [1 options.Connectivity.NumberOfVertices]);
%          IE_i = repmat(IE_i,[1 options.Connectivity.NumberOfVertices]);
%          II_i = repmat(II_i,[1 options.Connectivity.NumberOfVertices]);
%          d_i  = repmat(d_i, [1 options.Connectivity.NumberOfVertices]);
%          p_i  = repmat(p_i, [1 options.Connectivity.NumberOfVertices]);
%          m_i  = repmat(m_i, [1 options.Connectivity.NumberOfVertices]);
%          n_i  = repmat(n_i, [1 options.Connectivity.NumberOfVertices]);
%      end
% keyboard
     
    %Assign coefficients to options structure
     options.Dynamics.A    = A;
     options.Dynamics.B    = B;
     options.Dynamics.C    = C;
     options.Dynamics.a_i  = a_i;
     options.Dynamics.e_i  = e_i;
     options.Dynamics.b_i  = b_i;
     options.Dynamics.f_i  = f_i;
     options.Dynamics.c_i  = c_i;
     options.Dynamics.h_i  = h_i;
     options.Dynamics.IE_i = IE_i;
     options.Dynamics.II_i = II_i;
     options.Dynamics.d_i  = d_i;
     options.Dynamics.p_i  = p_i;
     options.Dynamics.m_i  = m_i;
     options.Dynamics.n_i  = n_i;

                       
  %---------------------------end case HMR--------------------------------%

%%
   otherwise
     error(['BrainNetworkModels:' mfilename ':UnknownModel'],'Unknown model specified to options variable ''WhichModel''...');
 end

end %function reduced_coefficients()
