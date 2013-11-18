%% Calculate data for node-wise "bifurcation" diagrams.
%
% NOTE: This is a fairly crude brute-force approach. It is yet to be validated
%       against well tested bifurcation tools such as xppaut. Even if correct
%       it'll be much slower and less robust than such specialised tools. The
%       main/only advantages of this is that it runs on the exact same code used
%       for simulation and doesn't require a reimplementation of the BNM.
%
% Some rules of thumb -- it's a balancing act:
%        + (dt * iters): needs to be several times the characteristic time-scale.
%        + dt: needs to be small enough to resolve the sharpest features.
%        + InitialControlValue: must produce a strongly stable fixed point.
%        + BifurcationParameterIncrement: small changes produce shorter reconvergence.
%        + ErrorTolerance smaller than what dt resolves will make single extrema show up as many.
%        + ErrorTolerance too big will merge points that should be distinct.
%        + MaxContinuations * (dt * iters) should exceed longest transient time. WARNING: ~Inf @ bif point
%        + larger MaxContinuations and smaller iters is faster when not near a bifurcation.
%        + to guarantee finding all branches, it's necessary that 
%          IntegrationsToMergeForNonstable * (dt * iters) exceed longest time constant of the BNM
%        + ...
%
% ARGUMENTS:
%        weights -- Matrix of connection weights between nodes
%        delay   -- Matrix of time delays between nodes in milliseconds
%        options -- 
%            .Bifurcation
%                .Integrator -- A string specifying the integration function to
%                        use, it needs to be consistent with the chosen
%                        options.Dynamics.WhichModel, and to be deterministic.
%                .BifurcationParameter -- the model parameter to use as the 
%                        bifurcation control parameter.
%                .InitialControlValue -- value to start at
%                .BifurcationParameterIncrement -- step-size for varying the
%                        bifurcation parameter.
%                .TargetControlValue -- continue stepping the bifurcation 
%                        parameter until reaching this value. 
%                .MaxContinuations -- number of times to run the integration
%                        in search of asymptotically stable behaviour...
%                        use 2|5|9|14|20|27|... ie: 0.5 * (n^2 + 3*n)
%                .ErrorTolerance -- Value below which peak to peak variability 
%                                   must be to consider it "Stable behaviour".
%                .AttemptForceFixedPoint -- if set to true the continuation 
%                        sets initial conditions using a temporal average over
%                        the previous history. This can speed things up
%                        particularly as we approach a bifurcation from a 
%                        single fixed point state
%                .IntegrationsToMergeForNonstable -- if the system doesn't
%                        seem to be stabilising, how many integration blocks 
%                        should we merge together to represent the state.
%                      
%
% OUTPUT:
%        ForwardFxdPts -- A structure containing cell arrays of the extrema 
%                found while stepping the bifurcation parameter forward.
%        BackwardFxdPts -- A structure containing cell arrays of the extrema 
%                found while stepping the bifurcation parameter backward.
%        options -- input structure updated to current state
%
% REQUIRES: 
%        IntegrateUntilStable() -- 
%
% USAGE:
%{
      %Specify Connectivity to use
       options.Connectivity.WhichMatrix = 'RM_AC';
       options.Connectivity.invel = 1.0/7.0;

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

       [ForwardFxdPts BackwardFxdPts options] = NodeBifurcation(options);

%}
%
% MODIFICATION HISTORY:
%     SAK(21-09-2009) -- Original.
%     SAK(20-10-2009) -- Use movement of fixed points rather than just 
%                        PeakToPeak amplitude for stable result decision. 
%                        Add support for solutions other than fixed points
%                        and limit cycles...
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ForwardFxdPts BackwardFxdPts options] = NodeBifurcation(options)
  if isoctave(),
    initial_more_state = page_screen_output;
    more off
  end
  
  options.Dynamics.(options.Bifurcation.BifurcationParameter) = options.Bifurcation.InitialControlValue;
  options = SetDerivedParameters(options); %Not efficient but necessary with current structure as csf is a common bifurcation parameter... 
  TrackBackwardUntil = options.Bifurcation.InitialControlValue;
  NumberOfFalseStableSolutionFlags = 0; %initialise
  
  NumberOfStateVariables = length(options.Dynamics.StateVariables);
  
  MaxBifSteps = floor((options.Bifurcation.TargetControlValue-options.Bifurcation.InitialControlValue)./options.Bifurcation.BifurcationParameterIncrement + eps) + 1;
  
  for tsv = 1:NumberOfStateVariables,
    ForwardFxdPts.(options.Dynamics.StateVariables{tsv})  = cell(options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes, MaxBifSteps+1);
    BackwardFxdPts.(options.Dynamics.StateVariables{tsv}) = cell(options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes, MaxBifSteps+1);
  end
  NumberIfAllAreFixedPoints = options.Connectivity.NumberOfNodes * options.Dynamics.NumberOfModes;
  PrevNumberOfForwardFxdPts = NumberIfAllAreFixedPoints*ones(1,           NumberOfStateVariables);
  NumberOfForwardFxdPts     = NumberIfAllAreFixedPoints*ones(MaxBifSteps, NumberOfStateVariables);%
  NumberOfBackwardFxdPts    = NumberIfAllAreFixedPoints*ones(MaxBifSteps, NumberOfStateVariables);%
  
  if isfield(options.Bifurcation,'AttemptForceFixedPoint'),
    WorthForcingFixedPoint = options.Bifurcation.AttemptForceFixedPoint;
  else 
    WorthForcingFixedPoint = true;
  end
  
%%%keyboard
  CurrentBifStep = 1;
  while (options.Dynamics.(options.Bifurcation.BifurcationParameter) <= options.Bifurcation.TargetControlValue),
    if options.Other.verbosity >=0,
      disp(['options.Bifurcation.' options.Bifurcation.BifurcationParameter ' = ' num2str(options.Dynamics.(options.Bifurcation.BifurcationParameter))])
    end
    
    %Integrate
    options.Bifurcation.AttemptForceFixedPoint = WorthForcingFixedPoint;
    [TheseFxdPts NumberOfForwardFxdPts(CurrentBifStep,:) options ForwardStableSolutionFlag] = IntegrateUntilStable(options);
    if WorthForcingFixedPoint && all(NumberOfForwardFxdPts(CurrentBifStep,:) > NumberIfAllAreFixedPoints),
      WorthForcingFixedPoint = false;
      if options.Other.verbosity > 0,
        disp('All state variables appear to have bifurcated. Giving up on trying to force a fixed point...');
      end
    end
    if options.Other.verbosity>=33,%42
      figure(CurrentBifStep), 
        plot(options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{1})(:,:,1), options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{2})(:,:,1),'.','MarkerSize', 8), legend(options.Connectivity.NodeStr)
        %Wait
        disp('Any key to continue or <Ctrl>c to quit...'); pause,
    end
    if ForwardStableSolutionFlag,
      if options.Other.verbosity > 0,
        disp(['Forward result stable to within requested ErrorTolerance of ' num2str(options.Bifurcation.ErrorTolerance)  '...']);
      end
    else
      disp(['WARNING: Forward result for ' options.Bifurcation.BifurcationParameter '=' num2str(options.Dynamics.(options.Bifurcation.BifurcationParameter)) ' is NOT stable to within the requested ErrorTolerance of ' num2str(options.Bifurcation.ErrorTolerance) '...']);
    end
    if WorthForcingFixedPoint,
      %Start next BifurcationParameter with a pseudo-fixed-point as history
      for tsv = 1:NumberOfStateVariables,
        options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{tsv}) = repmat(mean(options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{tsv}), 1), [options.Integration.maxdelayiters 1]);
      end
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
        disp(['System appears to have bifurcated... There are ' num2str(NumberOfForwardFxdPts(CurrentBifStep,:)-PrevNumberOfForwardFxdPts) ' new extrema...']);
      end
      %capture current state
      ThisBifStep = CurrentBifStep;
      ThisBifurcation = options.Dynamics.(options.Bifurcation.BifurcationParameter);
      TheseInitialConditions = options.Dynamics.InitialConditions;
      
      % Set parameters depending on whether IntegrateUntilStable() achieved its goal...
      if ForwardStableSolutionFlag, 
        TrackBackwardUntil = options.Bifurcation.InitialControlValue;
        NumberOfFalseStableSolutionFlags = 0; %reset
      else
        if NumberOfFalseStableSolutionFlags,
          TrackBackwardUntil = options.Dynamics.(options.Bifurcation.BifurcationParameter) - options.Bifurcation.BifurcationParameterIncrement;
        end
        NumberOfFalseStableSolutionFlags = NumberOfFalseStableSolutionFlags+1;
      end
%%%keyboard
      %Check for hysteresis...
      %TODO: Still missing some branches, it's not sufficient to track back to number of branches, need values to match as well... Do MergeExtrema of Fwd and bckwd for CurrentBifStep, then count...
      while (options.Dynamics.(options.Bifurcation.BifurcationParameter)>TrackBackwardUntil && any(NumberOfBackwardFxdPts(CurrentBifStep,:)~=NumberOfForwardFxdPts(CurrentBifStep,:)) && CurrentBifStep>=2),
        CurrentBifStep = CurrentBifStep - 1;
        options.Dynamics.(options.Bifurcation.BifurcationParameter) = options.Dynamics.(options.Bifurcation.BifurcationParameter) - options.Bifurcation.BifurcationParameterIncrement;
        options = SetDerivedParameters(options); %Not efficient but necessary with current structure as csf is a common bifurcation parameter... 
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
        
      end %while step backward
      if options.Other.verbosity >= 0,
        if all(NumberOfBackwardFxdPts(CurrentBifStep,:)==NumberOfForwardFxdPts(CurrentBifStep,:)),
          disp('Have returned to previous number of bifurcation branches, resetting and continuing from where we were up to...');
        else
          disp('Appear to have reach the TrackBackwardUntil value without returning to bifurcation state...');
        end
      end
     
      CurrentBifStep = ThisBifStep;
      options.Dynamics.(options.Bifurcation.BifurcationParameter) = ThisBifurcation;
      options = SetDerivedParameters(options); %Not efficient but necessary with current structure as csf is a common bifurcation parameter... 
      options.Dynamics.InitialConditions = TheseInitialConditions;
    end % if there was a bifurcation
    
    %Update and Reset
    PrevNumberOfForwardFxdPts = NumberOfForwardFxdPts(CurrentBifStep,:);
    options.Dynamics.(options.Bifurcation.BifurcationParameter) = options.Dynamics.(options.Bifurcation.BifurcationParameter) + options.Bifurcation.BifurcationParameterIncrement;
    options = SetDerivedParameters(options); %Not efficient but necessary with current structure as csf is a common bifurcation parameter... 
    CurrentBifStep = CurrentBifStep+1;
  
  end % while haven't reached TargetControlValue

  if isoctave() && initial_more_state,
    more on
  end
end % function NodeBifurcation()
