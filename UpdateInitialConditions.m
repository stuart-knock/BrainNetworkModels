%% <Description>
%
% ARGUMENTS:
%           <arg1> -- <description>
%
% OUTPUT: 
%           <output1> -- <description>
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function options = UpdateInitialConditions(options)

 for SVj = 1:length(options.Dynamics.StateVariables),
   ThisStateVariable = evalin('caller', options.Dynamics.StateVariables{SVj});
   PreviousInitialConditions = options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{SVj});
   if size(PreviousInitialConditions,1)~=1, %there are time delays on this variable
     CurrentState = cat(1,PreviousInitialConditions,ThisStateVariable);
     options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{SVj}) = CurrentState((end-options.Integration.maxdelayiters+1):end,:,:);
   else
     options.Dynamics.InitialConditions.(options.Dynamics.StateVariables{SVj}) = ThisStateVariable(end,:,:);
   end
 end
 
end %function UpdateInitialConditions()
