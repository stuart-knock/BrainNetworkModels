%% Tries to make Octave use fltk as the graphics toolkit, because gnuplot is
% excruciatingly slow... Although fltk does seem to have its issues...
%
% ARGUMENTS: none
% OUTPUT:    none
% REQUIRES:  none
%
% USAGE:
%{
    %At an Octave command prompt
    use_fltk()
%}
%


function use_fltk()
  
  if isoctave(),
    try
      graphics_toolkit('fltk')
    catch
      sys_msg = lasterror.message;
      x = dbstack();
      if (numel(x) > 1),
        caller = x(2).name;
      else
        caller = 'base';
      end 
      msg = 'Couldn''t make Octave use fltk, gnuplot is painfully slow...';
      warning(['BrainNetworkModels:PlottingTools:' caller ':NoFLTK'], msg);
      warning(['BrainNetworkModels:PlottingTools:' caller ':NoFLTK'], sys_msg)
    end
  else
    msg = 'This function is intended for use in Octave, not Matlab...';
    warning(['BrainNetworkModels:PlottingTools:' mfilename ':DontUseMeInMatlab'], msg);
  end

end %function use_fltk()
