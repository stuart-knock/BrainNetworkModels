%% <Description>
%
% ARGUMENTS:
%          Discretization
%          Cortex  -- <description>
%          Thalamus  -- <description>
%
% OUTPUT: 
%          Cortex  -- <description>
%          Thalamus  -- <description>
%
% USAGE:
%{
      options.Dynamics.Discretization = 23;
      [Cortex Thalamus] = PhysicsBrain(options.Dynamics.Discretization);

      ce = round(options.Dynamics.Discretization./2); %Cortical-equator...
      CorticoThalmicDistance = dis([Cortex.X(ce,:) ; Cortex.Y(ce,:) ; Cortex.Z(ce,:)], [Thalamus.X(ce,:) ; Thalamus.Y(ce,:) ; Thalamus.Z(ce,:)]);
      figure, plot(CorticoThalmicDistance)
%}
%
% MODIFICATION HISTORY:
%     SAK(30-03-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Cortex Thalamus vertCortex trianCortex vertnormCortex] = PhysicsBrain(Discretization,Cortex,Thalamus)
%% Set any argument that weren't specified
 if nargin < 1,
   Discretization = 43;
 end
 if nargin < 2,
   %http://faculty.washington.edu/chudler/facts.html
   Cortex.rX = 70;   %mm
   Cortex.rY = 83.5; %mm
   Cortex.rZ = 46.5; %mm
   Cortex.cX = 0;   %mm
   Cortex.cY = 0; %mm
   Cortex.cZ = 0; %mm
 end
 if nargin < 3,
   %Marzinzik etal 2008, Journal of Cognitive Neuroscience 20:10, pp. 1903–1914 
   %"The Human Thalamus is Crucially Involved in Executive Control Operations" 
   Thalamus.rX = 0.156509561522117*70;   %mm %% Average of Cortex/Thalamus ration for width and height... %%
   Thalamus.rY = 12.4; %mm
   Thalamus.rZ = 7.65; %mm
   Thalamus.cX = 0;   %mm
   Thalamus.cY = 0.5*Thalamus.rY; %mm
   Thalamus.cZ = -Thalamus.rZ; %mm
 end

%%
 [Cortex.X,Cortex.Y,Cortex.Z] = ellipsoid(Cortex.cX,Cortex.cY,Cortex.cZ,Cortex.rX,Cortex.rY,Cortex.rZ, Discretization-1);
 [Thalamus.X,Thalamus.Y,Thalamus.Z] = ellipsoid(Thalamus.cX,Thalamus.cY,Thalamus.cZ,Thalamus.rX,Thalamus.rY,Thalamus.rZ, Discretization-1);

%% 3D
 figure,
  surf(Cortex.X,Cortex.Y,Cortex.Z, 'FaceColor', [0.69 0.67 0.67], 'EdgeColor', [0.42 0.42 0.42]);
  daspect([1 1 1])
  hold on
  surf(Thalamus.X,Thalamus.Y,Thalamus.Z, 'FaceColor', [0.69 0.67 0.67], 'EdgeColor', [0.42 0.42 0.42]);
  alpha(.3);
  
  plot3(Cortex.X(round(Discretization./2),:),Cortex.Y(round(Discretization./2),:),Cortex.Z(round(Discretization./2),:), 'r')
  plot3(Thalamus.X(round(Discretization./2),:),Thalamus.Y(round(Discretization./2),:),Thalamus.Z(round(Discretization./2),:), 'g')
  
  AxisToOrigin(gcf,gca,{'Right Ear' 'Nose' 'Top'})
  
%% 2D, approx... 
%  figure,
%   plot(Cortex.X(round(Discretization./2),:),Cortex.Y(round(Discretization./2),:), 'r')
%   daspect([1 1 1])
%   hold on
%   plot(Thalamus.X(round(Discretization./2),:),Thalamus.Y(round(Discretization./2),:), 'g')

%% Extract (delaunay) triangulated cortical surface.

%keyboard
 if nargout>2,
   DT = DelaunayTri(Cortex.X(:), Cortex.Y(:), Cortex.Z(:)); % NB. The returned "Triangles" will be 4 sided polygons... 
   [tri Xb] = freeBoundary(DT);
   tr = TriRep(tri, Xb);
   vertCortex = tr.X;
   trianCortex = tr.Triangulation;
   fn = faceNormals(tr);
   temp = vertexAttachments(tr,(1:length(tr.X)).');
   vertnormCortex = zeros(size(vertCortex));
   for k =1:length(tr.X),
     vertnormCortex(k,:) = mean(fn(temp{k},:));
   end
 end
%
%
%
  
end %function PhysicsBrain()
