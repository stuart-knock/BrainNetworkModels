%% Map sensor "locations" to a triangle and point on a given surface.
% 
% EEG sensor locations are typically only given on a unit sphere, that is,
% they are effectively only identified by their orientation with respect to
% a coordinate system. This function can be used to map these sensor 
% "locations" to a specific location the surface of the skin. 
%
% Assumes coordinate systems are alligned, ie common x,y,z and origin. 
%
% ARGUMENTS:
%           Sensors -- sensor locations, [#ofSensors, 3] (x,y,z)
%           Surface -- TriRep object representation of the surface.
%           Neighbourhood -- Size of the patch of surface to consider when
%                            searching for the intersection. The 1-ring is
%                            usually sufficient for a regularised surface,
%                            but we default to the 2-ring to be safe. 
%
% OUTPUT: 
%           SensorTriangles -- Surface triangles corresponding to the 
%           SensorPoints    -- Points of intersection of the lines passing
%                              through the origin and the sensor
%                              "locations", and the Surface.
%
% REQUIRES:
%          GetLocalSurface() -- 
%
% USAGE:
%{
   %% Load some sensor "locations", allign with surface coordinate system.  
    load('../Sensors/BDI_EEGLab_electrode.mat')
    Sensors = [BDEEGlab_b(:,2), -BDEEGlab_b(:,1), BDEEGlab_b(:,3)]; %
     
   %% Load the surface corresponding to the outer skin
    ThisSurface = 'reg13';
    load(['OuterSkin.mat'], 'Vertices', 'Triangles', 'VertexNormals');
    Surface = TriRep(Triangles, Vertices); 

   %% Do the stuff...
    [SensorTriangles, SensorPoints] = GetSurfaceLocationOfSensors(Sensors, Surface);

   %% Check visually
    SurfaceMesh(Surface)
    hold on
    % Origin, for targeting.
    scatter3( 0,  0, 0, 'b'); %
  
    % Original sensor "locations"
    scatter3(Sensors(:,1), Sensors(:,2), Sensors(:,3), 'b*'); 

    % Location of sensors on the surface
    scatter3(SensorPoints(:,1), SensorPoints(:,2), SensorPoints(:,3), 'r*') 
    
    % Vertices of triangle containing intersection: 
    AllTriangleVertices = Triangles(SensorTriangles,:);
    AllTriangleVertices = AllTriangleVertices(:);
    scatter3(Vertices(AllTriangleVertices,1), Vertices(AllTriangleVertices,2), Vertices(AllTriangleVertices,3), 'g*')

    %%%for k = 1:length(ElectrodeLabels),
    %%%  text(SensorPoints(k,1)+0.003, SensorPoints(k,2), SensorPoints(k,3), ['\bf ' ElectrodeLabels{k}], 'color', [0 0 0]);
    %%%end

    % Lines extending from origin through Sensors and beyond...
    %%%plot3([zeros(size(Sensors,1),1) 13*Sensors(:,1)].', [zeros(size(Sensors,1),1) 13*Sensors(:,2)].', [zeros(size(Sensors,1),1) 13*Sensors(:,3)].', 'r')
 
%}
%
% MODIFICATION HISTORY:
%     SAK(30-03-2011) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SensorTriangles, SensorPoints]=GetSurfaceLocationOfSensors(Sensors,Surface,Neighbourhood)
%% Set any argument that weren't specified
 if nargin < 2,
   error('BrainNetworkModels:Surfaces:GetSurfaceLocationOfSensors:NotEnoughArguments', ...
         'Need 2 args...')
 end
 if nargin < 3,
   Neighbourhood = 2;
 end

%% Do the stuff...
 %Normalise sensor and vertex locations to unit vectors, we're only interested in allignment.
 Usensors = Sensors ./ repmat(sqrt(sum(Sensors.^2,2)), [1 3]);
 Uverts = Surface.X ./ repmat(sqrt(sum(Surface.X.^2,2)), [1 3]);
 
 SensorTriangles = zeros(1,size(Sensors,1));
 SensorPoints = zeros(size(Sensors,1), 3);
 for k = 1:size(Sensors,1),
   %Find the surface vertex most closely alligned with the current sensor.
   DirectionalAllignment = dot(repmat(Usensors(k,:),[size(Uverts,1),1]),Uverts,2);
   [~, Ix] = max(DirectionalAllignment);
   
   %Get set of triangles and vertices in the neighbourhood of that vertex. 
   %%%TrianglesOfClosestVertex = vertexAttachments(Surface, Ix); 
   %On rare occasions the intersection isn't within the 1-ring, usually 
   %because the intersection is close to the centre and just to the far 
   %side of a long edge which is part of the one ring of the closest 
   %vertex, so we use GetLocalSurface() as a quick fix...
   [~, ~, ~, TrianglesOfClosestVertex] = GetLocalSurface(Surface,Ix,Neighbourhood); %
   VertexIndices = Surface.Triangulation(TrianglesOfClosestVertex,:); %%%{:}
   
   %Calculate paramaterised plane line intersection [t,u,v] for the local 
   %set of triangles
   S_l = Sensors(k,:);
   tuv = zeros(size(VertexIndices,1),3);
   for Ti=1:size(VertexIndices,1),
     E_1 = Surface.X(VertexIndices(Ti,1),:) - Surface.X(VertexIndices(Ti,2),:);
     E_2 = Surface.X(VertexIndices(Ti,1),:) - Surface.X(VertexIndices(Ti,3),:);
     tuv(Ti, :) = ([S_l ; E_1 ; E_2].' \ Surface.X(VertexIndices(Ti,1),:).').';
   end
   
   %Find find which line-plane intersection falls within its triangle by 
   %imposing the condition that u, v, & u+v are contained in [0 1]:   
   temp = find((tuv(:,2) > 0)          & ...
               (tuv(:,2) < 1)          & ...
               (tuv(:,3) > 0)          & ... 
               (tuv(:,3) < 1)          & ... 
               (tuv(:,2)+tuv(:,3) > 0) & ...
               (tuv(:,2)+tuv(:,3) < 1));
             
   %Ensure only one triangle is found: 
   switch numel(temp),
     case {1}
       SensorTriangles(1,k) = temp;
     case {0}
       %%%error('BrainNetworkModels:Surfaces:GetSurfaceLocationOfSensors:NoIntersections', ...
       %%%      'Found no intersections: If surface is complete and surrounds all Sensors, try increasing Neighbourhood...')
       disp('Found no intersections: If surface is complete and surrounds all Sensors, try increasing Neighbourhood...')
       keyboard
     otherwise
       %%%error('BrainNetworkModels:Surfaces:GetSurfaceLocationOfSensors:MultipleIntersections', ...
       %%%      'Found multiple intersections: Surface is possibly too folded...')
       disp('Found multiple intersections: Surface is possibly too folded...')
       keyboard
   end
     
   %Scale sensor vector by t to place sensor at intersection with surface. 
   SensorPoints(k,:) = S_l .* tuv(SensorTriangles(1,k), 1);
   
   %Map local triangle index to global triangle index
   SensorTriangles(1,k) = TrianglesOfClosestVertex(SensorTriangles(1,k)); %%%{:}
   
 end
   
%% 

end %function GetSurfaceLocationOfSensors()
