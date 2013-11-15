%% 
%
% ARGUMENTS:
%
% OUTPUT: 
%                             .MaxContinuations -- number of times to run the 
%                                                  integration fhn_net_rk in
%                                                  search of asymptotically stable
%                                                  behaviour...use 2|5|9|14|20|27|... 
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(OctNov-2009) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [TheseFxdPts NumberOfFxdPts options StableSolutionFlag] = IntegrateUntilStable(options)
%%
 NumberOfStateVariables = length(options.Dynamics.StateVariables);
 IntegrationCommand = ['[' sprintf('%s ',options.Dynamics.StateVariables{:})  '] = ' options.Bifurcation.Integrator '(options);'];
 
%Start under the assumption that solution will stabilise...
 if nargout > 3,
   StableSolutionFlag = true;
 end
 
 if (options.Bifurcation.MaxContinuations==0), 
   disp('Running in interactive mode, turning on maximum verbosity...');
   options.Other.verbosity = 42;
 elseif options.Other.verbosity == 0,
   fprintf(1,'Will try a maximum of %d continued integrations, currently on attempt:   ', options.Bifurcation.MaxContinuations);
 end
 
%%

%Intial inegration to set state variables
 if options.Other.verbosity > 0,
   disp(['Integrations will be performed using: ' IntegrationCommand ]);
 end
 tic,
 eval(IntegrationCommand);
 EstimatedTimePerIntegration = toc;
 if options.Other.verbosity > 1,
   disp(['which takes approximately ' num2str(ceil(EstimatedTimePerIntegration)) ' seconds at each call...']);
   disp(['That means ' mfilename '() could take up to ' num2str(ceil(EstimatedTimePerIntegration*(2*options.Bifurcation.MaxContinuations)/60)) ' minutes to complete...']);
 else
   EstimatedMaxTimeToRun = EstimatedTimePerIntegration*(2*options.Bifurcation.MaxContinuations);
   if EstimatedMaxTimeToRun > 3600,
     warning(['BrainNetworkModels:' mfilename ':LongRunTime'],['Potential run time for ' mfilename '() is greater than an hour...']);
   end
 end
 
%Initialise cell array for bifurcation results
 TheseFxdPts = cell(options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes, NumberOfStateVariables);
 NumberOfFxdPts     = zeros(1,NumberOfStateVariables);
 PrevNumberOfFxdPts = zeros(1,NumberOfStateVariables);
 Fluctuations = 42;
 AttemptsAtThisValue = 0;
 
 ThinkItsAFixedPoint = 0;
 ContinuationsBeforeFPguess = 1;
 
 while any(abs(Fluctuations(:)) > options.Bifurcation.ErrorTolerance), %Not-A-Stable-Solution
%%%keyboard
   AttemptsAtThisValue = AttemptsAtThisValue + 1;
   if options.Other.verbosity==0,
     fprintf(1,'\b\b%2d', AttemptsAtThisValue);
   elseif options.Other.verbosity > 2,
     fprintf(1,'Will try a maximum of %d continued integrations, currently on attempt: %d \n', options.Bifurcation.MaxContinuations, AttemptsAtThisValue);
   end
   
   %update InitialConditions
   if options.Bifurcation.AttemptForceFixedPoint,
     if all(NumberOfFxdPts<=PrevNumberOfFxdPts),
       ThinkItsAFixedPoint = ThinkItsAFixedPoint+1;
     end
     if ThinkItsAFixedPoint==ContinuationsBeforeFPguess,
       if options.Other.verbosity > 0,
         disp('Guessing it''s a fixed point, so using guestimate of fixed point for continued integration...')
       end
       for tsv = 1:NumberOfStateVariables,
         options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{tsv}) = eval(['repmat(mean(' options.Dynamics.StateVariables{tsv} ', 1), [options.Integration.maxdelayiters 1]);']);
       end
       ThinkItsAFixedPoint = 0; %reset
       ContinuationsBeforeFPguess = ContinuationsBeforeFPguess + 1;
     else
       if options.Other.verbosity > 0,
         disp('using actual history for continued integration...');
       end
%%%keyboard
       for tsv = 1:NumberOfStateVariables,
         options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{tsv}) = eval([options.Dynamics.StateVariables{tsv} '((end-options.Integration.maxdelayiters+1):end, :, :)']);
       end
     end
   else
     for tsv = 1:NumberOfStateVariables,
       options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{tsv}) = eval([options.Dynamics.StateVariables{tsv} '((end-options.Integration.maxdelayiters+1):end, :, :)']);
     end
   end
     
   %Integrate
   eval(IntegrationCommand);
   
   %Get extrema of time series returned by integration
   for tsv = 1:NumberOfStateVariables,
     [TheseFxdPts{:,:,tsv}] = FindUniqueExtrema(eval(options.Dynamics.StateVariables{tsv}), options.Bifurcation.ErrorTolerance*1e3);
   end

   %Count the extrema we just found
   for tsv = 1:NumberOfStateVariables,
     NumberOfFxdPts(tsv) = length([TheseFxdPts{:,:,tsv}]);
   end

   %How much have our fixed points moved
   if all(NumberOfFxdPts==PrevNumberOfFxdPts), %we have the same number of fixed points,
     Fluctuations = [TheseFxdPts{:}] - [PrevFxdPts{:}];
     if options.Other.verbosity > 1,
       disp(['Since previous integration step, movement of fixed points has ranged from ' num2str(min(Fluctuations(:))) ' to ' num2str(max(Fluctuations(:)))]);
     end
   end

   if (AttemptsAtThisValue == options.Bifurcation.MaxContinuations),
     if nargout > 3, 
       StableSolutionFlag = false; %The solution failed to stablise
     end
     
     if options.Other.verbosity > 0,
       disp(['Solution hadn''t stabalised... there were ' num2str(NumberOfFxdPts) ' fixed points for this integration and ' num2str(PrevNumberOfFxdPts) ' for the previous integration...']);
       disp(['Will do ' num2str(options.Bifurcation.MaxContinuations) ' more integrations, merge the results and bail...'])
     end
     
     PrevFxdPts = TheseFxdPts;
     PrevNumberOfFxdPts = NumberOfFxdPts;
     FxdPtsToMerge = cell(options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes, NumberOfStateVariables);
     for itmfn = 2:options.Bifurcation.IntegrationsToMergeForNonstable,
       %Integrate
       eval(IntegrationCommand);
       %update InitialConditions
       for tsv = 1:NumberOfStateVariables,
         options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{tsv}) = eval([options.Dynamics.StateVariables{tsv} '((end-options.Integration.maxdelayiters+1):end, :, :)']);
       end

       %Get extrema of time series returned by integration
       for tsv = 1:NumberOfStateVariables,
         [FxdPtsToMerge{:,:,tsv}] = FindUniqueExtrema(eval(options.Dynamics.StateVariables{tsv}), options.Bifurcation.ErrorTolerance*1e3);
       end
       
       %Concatenate fixed points from repeated integrations
       TheseFxdPts = MergeExtrema(TheseFxdPts, FxdPtsToMerge, options.Bifurcation.ErrorTolerance*1e3, 0);
       
     end

     %Obtain unique extrema given requested ErrorTolerance
     TheseFxdPts = MergeExtrema(TheseFxdPts, cell(options.Connectivity.NumberOfNodes, options.Dynamics.NumberOfModes, NumberOfStateVariables), options.Bifurcation.ErrorTolerance*1e3, 1);
     
     %Count the extrema we just found
     for tsv = 1:NumberOfStateVariables,
       NumberOfFxdPts(tsv) = length([TheseFxdPts{:,:,tsv}]);
     end

     if options.Other.verbosity > 1,
       disp(['Change in number of fixed points after merging ' num2str(options.Bifurcation.IntegrationsToMergeForNonstable) ' integrations is: ' num2str(NumberOfFxdPts-PrevNumberOfFxdPts)]);
     end
     
     break %from the while-Not-A-Stable-Solution loop
   end
     
  %Plot stuff for interactive mode...
   if options.Bifurcation.MaxContinuations==0 || options.Other.verbosity>=42, %Interactive
     %Plot
     for tsv = 1:NumberOfStateVariables,
       figure(111*tsv), 
       if options.Dynamics.NumberOfModes==1,
         plot(eval(options.Dynamics.StateVariables{tsv})), title(options.Dynamics.StateVariables{tsv})
       else
         for tm = 1:options.Dynamics.NumberOfModes,
           subplot(options.Dynamics.NumberOfModes,1,tm)
           plot(eval([options.Dynamics.StateVariables{tsv} '(:,:,tm)'])), title([options.Dynamics.StateVariables{tsv} ': Mode ' num2str(tm)])
         end
       end
     end
     %Wait
     disp('Any key to continue or <Ctrl>c to quit...'); pause,
   end
   
   PrevFxdPts = TheseFxdPts;
   PrevNumberOfFxdPts = NumberOfFxdPts;
 end

 %update initial conditions to return full state of final integration
 for tsv = 1:NumberOfStateVariables,
   options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{tsv}) = eval(options.Dynamics.StateVariables{tsv});
   %%%IF MEMORY BECOMES A PROBLEM FOR THIS STEP%%% clear(StateVariables{tsv})
 end
     
 if options.Other.verbosity==0,
   fprintf(1,'\n');
 end

end %function IntegrateUntilStable()
