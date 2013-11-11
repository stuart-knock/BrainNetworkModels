%% Updates intitial conditions based of state variables available in the 
% caller's namespace. Used for simulation continuation, outputs from *_heun()
% must exist and have their standard names.
%
% ARGUMENTS:
%        options -- <description>
%
% OUTPUT: 
%        options-- <description>
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(<dd-mm-yyyy>) -- Original.
%     SAK(05-08-2010 -- added conditional for not all state variables
%                       having delay.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function options = UpdateInitialConditions(options)

  for SVj = 1:length(options.Dynamics.StateVariables),
    try
      ThisStateVariable = evalin('caller', options.Dynamics.StateVariables{SVj});
    catch
      sys_msg = lasterror.message;
      error(['BrainNetworkModels:' mfilename ':Hackery'], ['This function expects parent namespace variables to be options.Dynamics.StateVariables']);
      rethrow(sys_msg)
    end
    PreviousInitialConditions = options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{SVj});
    if size(PreviousInitialConditions,1)~=1, %there are time delays on this variable
      CurrentState = cat(1,PreviousInitialConditions,ThisStateVariable);
      options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{SVj}) = CurrentState((end-options.Integration.maxdelayiters+1):end,:,:);
    else
      options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{SVj}) = ThisStateVariable(end,:,:);
    end
  end
 
end %function UpdateInitialConditions()
