%% isoctave() determnines if the code is being running in octave.
%
% Returns Boolean:
%   true: if running in Octave.
%   false: if not running in Octave -- so pressumably Matlab...
%


function yesno = isoctave()
  persistent oorm;

  if isempty(oorm),
    oorm = exist('OCTAVE_VERSION', 'builtin') ~= 0;
  end;
  yesno = oorm;

 return;
