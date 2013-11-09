%% Merge two structures into one, assuming 
%
% ARGUMENTS:
%           options  -- Structure containing fields that take precedence.
%           defaults -- Structure containing fields to be added to options 
%                       if they're missing. 
%
% OUTPUT: 
%           options  -- Structure containing original contents of options 
%                       plus defaults in place of any unspecified options.
%
% USAGE:
%{
  %Within a function that has options.iters etc as an argument
  %Set default option values
   defaults.Dynamics.BRRW = BRRW_ParameterDefaults('absence');

  %
   options.Dynamics.BRRW.nu_se = 42e-4;

   options.Dynamics.BRRW = MergeStructures(options.Dynamics.BRRW, defaults.Dynamics.BRRW);
%}
%
% MODIFICATION HISTORY:
%     SAK(06-01-2010) -- Original (Modified from CompleteOptions()).
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function options = MergeStructures(options, defaults)

%% 
if nargin>1,
  PossibleOptions = unique([fieldnames(options) ; fieldnames(defaults)]); %
  %Assign defaults to any necessary but unsupplied options...
  for ThisOption = 1:length(PossibleOptions),
    if ~isfield(options, PossibleOptions{ThisOption}),
      options.(PossibleOptions{ThisOption}) = defaults.(PossibleOptions{ThisOption});
    end
  end
end

%% 

end %function MergeStructures()