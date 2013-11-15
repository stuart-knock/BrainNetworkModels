%% Node wse "bifurcation" diagrams
% 
%
% ARGUMENTS:
%           weights -- Matrix of connection weights between nodes
%           delay   -- Matrix of time delays between nodes in milliseconds
%           options -- 
%                  .Integrator -- 
%   options.BifurcationOptions -- same as fhn_net_rk, plus:
%                             .ErrorTolerance   -- Value below which peaktopeak
%                                                  variability must be for us to
%                                                  consider it "Stable behaviour"
%                             .BifurcationParameter    -- 
%                             .BifurcationParameterIncrement    --  
%                             .TargetControlValue
%                      
%
% OUTPUT: 
%          
%          options -- with added V and W timeseries produced by the 
%                     integration, useful for subsequent continuation
%
% USAGE:
%{
      %Specify Connectivity to use
       options.Connectivity.WhichMatrix = 'RM_AC';
       options.Connectivity.invel = 1/7;

      %Specify Dynamics to use
       options.Dynamics.WhichModel = 'BRRW';
       options.Dynamics.BrainState = 'absence';

      %Load default parameters for specified connectivity and dynamics
       options.Connectivity = GetConnectivity(options.Connectivity);
       options.Dynamics = SetDynamicParameters(options.Dynamics);
       options = SetIntegrationParameters(options);
       options = SetDerivedParameters(options);
       options = SetInitialConditions(options);

       options = SetBifurcationOptions(options);

       [ForwardFxdPts BackwardFxdPts options] = NodeBifurcation(options)

%}
%
% MODIFICATION HISTORY:
%     SAK(21-09-2009) -- Original.
%     SAK(20-10-2009) -- Use movement of fixed points rather than just 
%                        PeakToPeak amplitude for stable result decission. 
%                        Add support for solutions other than fixed points
%                        and limit cycles...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ForwardFxdPts BackwardFxdPts options] = NodeBifurcation(options)

% % % %Set integration defaults
% % %  defaults.verbosity = 0;
% % % %
% % %  if ~isfield(options.Other),
% % %    options.Other = CompleteOptions(defaults, options.Other);
% % %  else 
% % %    options.Other = CompleteOptions(defaults);
% % %  end

 options.Dynamics.(options.Bifurcation.BifurcationParameter) = options.Bifurcation.InitialControlValue;
 TrackBackwardUntil = options.Bifurcation.InitialControlValue;
 NumberOfFalseStableSolutionFlags = 0; %initialise

 NumberOfStateVariables = length(options.Dynamics.StateVariables);
 
 MaxBifSteps = floor((options.Bifurcation.TargetControlValue-options.Bifurcation.InitialControlValue)./options.Bifurcation.BifurcationParameterIncrement + eps) + 1;
 
 for tsv = 1:NumberOfStateVariables,
   ForwardFxdPts.(options.Dynamics.StateVariables{tsv})  = cell(options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes, MaxBifSteps+1);
   BackwardFxdPts.(options.Dynamics.StateVariables{tsv}) = cell(options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes, MaxBifSteps+1);
 end
 NumberIfAllAreFixedPoints = options.Connectivity.NumberOfNodes * options.Dynamics.NumberOfModes;
 PrevNumberOfForwardFxdPts = NumberIfAllAreFixedPoints*ones(1,          NumberOfStateVariables);
 NumberOfForwardFxdPts     = NumberIfAllAreFixedPoints*ones(MaxBifSteps,NumberOfStateVariables);%
 NumberOfBackwardFxdPts    = NumberIfAllAreFixedPoints*ones(MaxBifSteps,NumberOfStateVariables);%
 
 if isfield(options.Bifurcation,'AttemptForceFixedPoint'),
   WorthForcingFixedPoint = options.Bifurcation.AttemptForceFixedPoint;
 else 
   WorthForcingFixedPoint = true;
 end
 
%%
%%%keyboard
 CurrentBifStep = 1;
 while (options.Dynamics.(options.Bifurcation.BifurcationParameter) <= options.Bifurcation.TargetControlValue),
   if options.Other.verbosity >=0,
     disp(['options.Bifurcation.' options.Bifurcation.BifurcationParameter ' = ' num2str(options.Dynamics.(options.Bifurcation.BifurcationParameter))])
   end
   
   %Integrate
   options.Bifurcation.AttemptForceFixedPoint = WorthForcingFixedPoint;
   [TheseFxdPts NumberOfForwardFxdPts(CurrentBifStep,:) options ForwardStableSolutionFlag] = IntegrateUntilStable(options);
   if all(NumberOfForwardFxdPts(CurrentBifStep,:) > NumberIfAllAreFixedPoints),
     WorthForcingFixedPoint = false;
     if options.Other.verbosity> 0,
       disp('All state variables appear to have bifurcated. Giving up on trying to force a fixed point...');
     end
   end
   if options.Other.verbosity>=33,%42
     figure(CurrentBifStep), 
       plot(options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{1})(:,:,1), options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{2})(:,:,1),'.','MarkerSize',3), legend(options.Connectivity.NodeStr)
       %Wait
       disp('Any key to continue or <Ctrl>c to quit...'); pause,
   end
   if ForwardStableSolutionFlag,
     if options.Other.verbosity > 0,
       disp(['Forward result stable to within requested ErrorTolerance of ' num2str(options.Bifurcation.ErrorTolerance)  '...']);
     end
   else
     disp(['WARNING: Forward result for ' options.Bifurcation.BifurcationParameter '=' options.Dynamics.(options.Bifurcation.BifurcationParameter) 'is NOT stable to within the requested ErrorTolerance of ' num2str(options.Bifurcation.ErrorTolerance) '...']);
   end
   %Start next BifurcationParameter with a psuedo-fixed-point as history
   for tsv = 1:NumberOfStateVariables,
     options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{tsv}) = repmat(mean(options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{tsv}), 1), [options.Integration.maxdelayiters 1]);
   end
%%%keyboard
  %Store
   for tsv = 1:NumberOfStateVariables,
     ForwardFxdPts.(options.Dynamics.StateVariables{tsv})(:,:,CurrentBifStep) = TheseFxdPts(:,:,tsv);
   end
   if options.Other.verbosity >=0,
     disp(['NumberOfForwardFxdPts = ' num2str(NumberOfForwardFxdPts(CurrentBifStep,:))]);
   end
   
   if nargout>1 && any(NumberOfForwardFxdPts(CurrentBifStep,:) ~= PrevNumberOfForwardFxdPts), %there was a bifurcation for at least one StateVariable
     if options.Other.verbosity > 0,
       disp(['System appears to have bifurcated... There are ' num2str(NumberOfForwardFxdPts(CurrentBifStep,:)-PrevNumberOfForwardFxdPts) ' new fixed points...']);
     end
    %capture current state
     ThisBifStep = CurrentBifStep;
     ThisBifurcation = options.Dynamics.(options.Bifurcation.BifurcationParameter);
     TheseInitialConditions = options.Dynamics.InitialConditions;
    
    % Set parameters depending on whether IntegrateUntilStable() acheived its goal...
     if ForwardStableSolutionFlag, 
       TrackBackwardUntil = InitialControlValue;
       NumberOfFalseStableSolutionFlags = 0; %reset
     else
       if NumberOfFalseStableSolutionFlags,
         TrackBackwardUntil = options.Dynamics.(options.Bifurcation.BifurcationParameter) - options.Bifurcation.BifurcationParameterIncrement;
       end
       NumberOfFalseStableSolutionFlags = NumberOfFalseStableSolutionFlags+1;
     end
%%%keyboard
    %Check for hysteresis...
     while (options.Dynamics.(options.Bifurcation.BifurcationParameter)>TrackBackwardUntil && any(NumberOfBackwardFxdPts(CurrentBifStep,:)~=NumberOfForwardFxdPts(CurrentBifStep,:)) && CurrentBifStep>=2),
       CurrentBifStep = CurrentBifStep - 1;
       options.Dynamics.(options.Bifurcation.BifurcationParameter) = options.Dynamics.(options.Bifurcation.BifurcationParameter) - options.Bifurcation.BifurcationParameterIncrement;
       if options.Other.verbosity > 0,
         disp(['Stepping backwards to options.' options.Bifurcation.BifurcationParameter ' = ' num2str(options.Dynamics.(options.Bifurcation.BifurcationParameter)) '...']);
       end
       
       options.BifurcationOptions.AttemptForceFixedPoint = false;
       [TheseFxdPts NumberOfBackwardFxdPts(CurrentBifStep,:) options BackwardStableSolutionFlag] = IntegrateUntilStable(options);
       if BackwardStableSolutionFlag,
         if options.Other.verbosity > 0,
           disp(['Backward result stable to within requested ErrorTolerance of ' num2str(options.Bifurcation.ErrorTolerance)  '...']);
         end
       else
         warning(['BrainNetworkModels:' mfilename ':NotStableWithinErrorTolerance'],['Backward result NOT stable to within requested ErrorTolerance of ' num2str(options.Bifurcation.ErrorTolerance) '...']);
       end

      %Store in a structure
       for tsv = 1:NumberOfStateVariables,
         for m = 1:options.Dynamics.NumberOfModes,
           for n = 1:options.Connectivity.NumberOfNodes,
             BackwardFxdPts.(options.Dynamics.StateVariables{tsv}){n,m,CurrentBifStep} = [BackwardFxdPts.(options.Dynamics.StateVariables{tsv}){n,m,CurrentBifStep} TheseFxdPts{n,m,tsv}];
           end
         end
       end
       if options.Other.verbosity >= 0,
         disp(['NumberOfBackwardFxdPts = ' num2str(NumberOfBackwardFxdPts(CurrentBifStep,:))]);
       end

     end
     if options.Other.verbosity >= 0,
       if all(NumberOfBackwardFxdPts(CurrentBifStep,:)==NumberOfForwardFxdPts(CurrentBifStep,:)),
         disp('Have returned to previous number of bifurcation branches, reseting and continuing from where we were up to...');
       else
         disp('Appear to have reach the TrackBackwardUntil value without returning to bifurcation state...');
       end
     end
     
     CurrentBifStep = ThisBifStep;
     options.Dynamics.(options.Bifurcation.BifurcationParameter) = ThisBifurcation;
     options.Dynamics.InitialConditions = TheseInitialConditions;
   end

   %Update and Reset
   PrevNumberOfForwardFxdPts = NumberOfForwardFxdPts(CurrentBifStep,:);
   options.Dynamics.(options.Bifurcation.BifurcationParameter) = options.Dynamics.(options.Bifurcation.BifurcationParameter) + options.Bifurcation.BifurcationParameterIncrement;
   CurrentBifStep = CurrentBifStep+1;
   
 end
     
%%
end % function NodeBifurcation()
