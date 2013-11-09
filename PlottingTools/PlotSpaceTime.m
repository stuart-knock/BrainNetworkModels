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
      
%}
%
% MODIFICATION HISTORY:
%     SAK(17-03-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlotSpaceTime(TimeSeries,options)

 ThisStateVariable = inputname(1);

 [TimeSteps NumberOfNodes NumberOfModes ] = size(TimeSeries);
 
 for nom=1:NumberOfModes,
   figure,
    surf(options.Connectivity.dx*(1:NumberOfNodes), options.Integration.dt*(1:TimeSteps), TimeSeries,'FaceColor','interp','EdgeColor','none');
    axis tight
    camlight left;
    lighting phong
    view(21,77);
    colormap hsv;
    title(['Space-time plot of neural field "' ThisStateVariable '", Mode ' num2str(nom) ' of ' num2str(NumberOfModes)]);
    xlabel('Space()');
    ylabel('Time()');
 end

end  %PlotSpaceTime()
