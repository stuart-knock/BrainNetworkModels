
%%
 ThisHead = '4096';
 ThisCortex = 'reg13';
 
%%
 load(['Surfaces/Cortex_' ThisCortex '.mat']);
 Cortex = TriRep(Triangles, Vertices);
 
 load(['Surfaces/OuterSkull_' ThisHead '.mat']);
 Head = TriRep(Triangles, Vertices);
 
%%
 load(['Surfaces/ProjectionMatrix_' ThisCortex '_' ThisHead '.mat'])
 
%%
 BDI_EEGlab_Electrodes_64;
 Sensors = [ElectrodePositions_3D(:,2), -ElectrodePositions_3D(:,1), ElectrodePositions_3D(:,3)];
 [SensorTriangles, SensorPoints] = GetSurfaceLocationOfSensors(Sensors, Head);

%%
 ThisChannel = 'Oz';
 
 [tf ThisChannelIndex] = ismember('Oz', ElectrodeLabels);
 
 SurfaceMesh(Cortex, ProjectionMatrix(2*size(Head.Triangulation,1)+SensorTriangles(ThisChannelIndex), :))
 colormap('jet')

 hold on
 scatter3(Head.X(Head.Triangulation(SensorTriangles(ThisChannelIndex), :), 1), ...
          Head.X(Head.Triangulation(SensorTriangles(ThisChannelIndex), :), 2), ...
          Head.X(Head.Triangulation(SensorTriangles(ThisChannelIndex), :), 3), ...
          142, 'k', 'filled')
        
 title(ThisChannel)
       
       
%% All sensors sensitivity map
 SurfaceMesh(tr, sum(ProjectionMatrix(2*size(Head.Triangulation,1)+SensorTriangles, :)))
 colormap('jet')
 
 hold on
 scatter3(Head.X(Head.Triangulation(SensorTriangles, :), 1), ...
          Head.X(Head.Triangulation(SensorTriangles, :), 2), ...
          Head.X(Head.Triangulation(SensorTriangles, :), 3), ...
          142, 'k', 'filled')
