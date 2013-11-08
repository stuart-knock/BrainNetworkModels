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
%     SAK(09-04-2009) -- Original.
%     SAK(06-05-2009) -- Modified to (ThisMatrix,options) calling format.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function histConnectivity(ThisMatrix,options)

%%
 if nargin == 1, %No options specified
   [weights delay] = GetConnectivity(ThisMatrix);
 else
   [weights delay] = GetConnectivity(ThisMatrix,options);
 end
 
 if nargin==1,
   minD = min(delay(:));
   maxD = max(delay(:));
   stepD = (maxD-minD)/10;
 else
   if isfield(options,'minD'),
     minD = options.minD;
   else
     minD = min(delay(:));
   end
   if isfield(options,'maxD'),
     maxD = options.maxD;
   else
     maxD = max(delay(:));
   end
   if isfield(options,'stepD'),
     stepD = options.stepD;
   else
     stepD = (maxD-minD)/10;
   end
 end
 
 if nargin>1,
   if isfield(options,'rescale'),
     delay = delay.*options.rescale;
   end
 end
 
 ThisTitle = ThisMatrix;

%%

%NB: subsequent sort on delay for RM_AC bias "weak" to short delay &
%"Strong" toward long delays...plot(dxw(:,2)) and notice wstep~200.

 dxw = sortrows([weights(weights~=0) delay(weights~=0)]); 
 
 wstep = fix(length(dxw)/3);
 
 if nargin==1,
   N1 = hist(dxw(1:wstep,2),stepD:stepD:maxD);             % weak
   N2 = hist(dxw((wstep+1):(2*wstep),2),stepD:stepD:maxD); % medium
   N3 = hist(dxw((2*wstep+1):end,2),stepD:stepD:maxD);     % strong
 else 
   if isfield(options,'WMS'),
      WMS = options.WMS;
   else
      WMS(1) = wstep;
      WMS(2) = 2*wstep;
   end
   N1 = hist(dxw(1:WMS(1),2),stepD:stepD:maxD);            % weak
   N2 = hist(dxw((WMS(1)+1):WMS(2),2),stepD:stepD:maxD);   % medium
   N3 = hist(dxw((WMS(2)+1):end,2),stepD:stepD:maxD);      % strong
 end
 
%% colourmap to Emphasise large numbers
 figure 
 load('LightBlueToDarkBlue'); 
 set(gcf,'Colormap',LightBlueToDarkBlue);    
 
 bar(stepD:stepD:maxD, [N3 ; N2 ; N1].','stacked') 

 legend({'Strong' 'Medium' 'Weak'});
 
 if nargin==1,
   ThisXlabel = 'Delay (ms)';
 else
   if isfield(options,'invel'),
     if options.invel==1,
       ThisXlabel = 'Delay (mm)';
     else
       ThisTitle = [ThisTitle ' for V=' num2str(1./options.invel) ' m/s'];
       ThisXlabel = 'Delay (ms)';
     end
   else
     ThisXlabel = 'Delay (ms)';
   end
   if isfield(options,'rescale'),
     ThisTitle = ['RESCALED BY ' num2str(options.rescale) ': ' ThisTitle];
   end
 end
 
 title(ThisTitle,'FontWeight','bold','FontSize',16,'interpreter','none')
 xlabel(ThisXlabel,'FontWeight','bold','FontSize',14);

 hold off
 
end %function histConnectivity3D()
