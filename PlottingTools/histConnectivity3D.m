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


function histConnectivity3D(ThisMatrix,options)

%%
 if nargin == 1, %No options specified
   [weights delay] = GetConnectivity(ThisMatrix);
 else
   [weights delay] = GetConnectivity(ThisMatrix,options);
 end
 
 minD = min(delay(:));
 maxD = max(delay(:));
 stepD = (maxD-minD)/10;
 

%%

%NB: subsequent sort on delay for RM_AC bias "weak" to short delay &
%"Strong" toward long delays...plot(dxw(:,2)) and notice wstep~200.

 dxw = sortrows([weights(weights~=0) delay(weights~=0)]); 
 
 wstep = fix(length(dxw)/3);
 
 if nargin==1,
   N1 = hist(dxw(1:wstep,2));             % weak
   N2 = hist(dxw((wstep+1):(2*wstep),2)); % medium
   N3 = hist(dxw((2*wstep+1):end,2));     % strong
 else 
   if isfield(options,'WMS'),
      WMS = options.WMS;
   else
      WMS(1) = wstep;
      WMS(2) = 2*wstep;
   end
   N1 = hist(dxw(1:WMS(1),2));            % weak
   N2 = hist(dxw((WMS(1)+1):WMS(2),2));   % medium
   N3 = hist(dxw((WMS(2)+1):end,2));      % strong
 end
 
%% colourmap to Emphasise large numbers
 figure 
 load('LightBlueToDarkBlue'); 
 set(gcf,'Colormap',LightBlueToDarkBlue);    
 
 bar3(stepD:stepD:maxD, [N3 ; N2 ; N1].')
 set(gca,'ZColor',[0.2471 0.2471 0.2471],...
         'YColor',[0.2471 0.2471 0.2471],...
         'XColor',[0.2471 0.2471 0.2471],...
         'Color',[0 0 0],'FontSize',16);
 view([-114 20]);      

%% Pruuutttyyyy... 
 if nargin == 1,
   title(ThisMatrix,'FontWeight','bold','FontSize',16,'interpreter','none')
 end

 set(gca,'XTick', 1:3);
 set(gca,'XTickLabel', {'Strong' 'Medium' 'Weak'});
 xlabel('Connection Strength','FontWeight','bold','FontSize',14);
 ylabel('Delay (ms)','FontWeight','bold','FontSize',14);
 %lighting phong;
 %camlight right; 
 alpha(.33);

 hold off
 
end %function histConnectivity3D()
