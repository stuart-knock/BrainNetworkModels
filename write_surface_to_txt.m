%% Write surface data to bzip2'd text files for use as test data in the 
% tvb.simulator, also write suplimentary info, but don't bzip2 it. 

%% Load cortical surface data
load('Surfaces/Cortex_reg13.mat')

%% Write it as bzip2'd text files 
fid = fopen('Surfaces/vertices_cortex_reg13.txt','wt');
fprintf(fid, '%10.6f %10.6f %10.6f \n', Vertices.')
fclose(fid);
system('bzip2 Surfaces/vertices_cortex_reg13.txt')

fid = fopen('Surfaces/vertex_normals_cortex_reg13.txt','wt');
fprintf(fid, '%10.6f %10.6f %10.6f \n', VertexNormals.')
fclose(fid);
system('bzip2 Surfaces/vertex_normals_cortex_reg13.txt')

fid = fopen('Surfaces/triangles_cortex_reg13.txt','wt');
fprintf(fid, '%d %d %d \n', Triangles.' - 1)
fclose(fid);
system('bzip2 Surfaces/triangles_cortex_reg13.txt')

clear all


%% Load region mapping data
load('Surfaces/RegionMapping_reg13_O52R00_IRP2008.mat')

%% Write it as bzip2'd text files 
fid = fopen('Surfaces/region_mapping_reg13_o52r00_irp2008.txt','wt');
fprintf(fid, '%d ', RegionMapping - 1)
fclose(fid);
system('bzip2 Surfaces/region_mapping_reg13_o52r00_irp2008.txt')

clear all


%%

%% Load supplimentary information
load('Surfaces/SummaryInfo_Cortex_cortex_reg13.mat')

%% Write it as a text file
fid = fopen('Surfaces/info_cortex_reg13.txt','wt');

  fprintf(fid, '%s', 'NumberOfVertices: ')
  fprintf(fid, '%d \n', NumberOfVertices)

  fprintf(fid, '%s', 'NumberOfTriangles: ')
  fprintf(fid, '%d \n', NumberOfTriangles)

  fprintf(fid, '%s', 'TotalSurfaceArea: ')
  fprintf(fid, '%10.6f \n', TotalSurfaceArea)

  fprintf(fid, '%s', 'meanTriangleArea: ')
  fprintf(fid, '%10.6f \n', meanTriangleArea)

  fprintf(fid, '%s', 'minTriangleArea: ')
  fprintf(fid, '%10.6f \n', minTriangleArea)

  fprintf(fid, '%s', 'maxTriangleArea: ')
  fprintf(fid, '%10.6f \n', maxTriangleArea)

  fprintf(fid, '%s', 'meanEdgeLength: ')
  fprintf(fid, '%10.6f \n', meanEdgeLength)

  fprintf(fid, '%s', 'minEdgeLength: ')
  fprintf(fid, '%10.6f \n', minEdgeLength)

  fprintf(fid, '%s', 'maxEdgeLength: ')
  fprintf(fid, '%10.6f \n', maxEdgeLength)

  fprintf(fid, '%s', 'medianDegree: ')
  fprintf(fid, '%d \n', medianDegree)

  fprintf(fid, '%s', 'minDegree: ')
  fprintf(fid, '%d \n', minDegree)

  fprintf(fid, '%s', 'maxDegree: ')
  fprintf(fid, '%d \n', maxDegree)

fclose(fid);



%% Load head surface data
 load('Surfaces/OuterSkin_4096.mat')

%% Write it as bzip2'd text files 
 fid = fopen('Surfaces/vertices_outer_skin_4096.txt','wt');
 fprintf(fid, '%10.6f %10.6f %10.6f \n', Vertices.')
 fclose(fid);
 system('bzip2 Surfaces/vertices_outer_skin_4096.txt')
 
 fid = fopen('Surfaces/vertex_normals_outer_skin_4096.txt','wt');
 fprintf(fid, '%10.6f %10.6f %10.6f \n', VertexNormals.')
 fclose(fid);
 system('bzip2 Surfaces/vertex_normals_outer_skin_4096.txt')
 
 fid = fopen('Surfaces/triangles_outer_skin_4096.txt','wt');
 fprintf(fid, '%d %d %d \n', Triangles.' - 1)
 fclose(fid);
 system('bzip2 Surfaces/triangles_outer_skin_4096.txt')
 
 clear all



%% Load supplimentary information
load('Surfaces/SummaryInfo_OuterSkin_4096.mat')

%% Write it as a text file
fid = fopen('Surfaces/info_outer_skin_4096.txt','wt');

  fprintf(fid, '%s', 'NumberOfVertices: ')
  fprintf(fid, '%d \n', NumberOfVertices)

  fprintf(fid, '%s', 'NumberOfTriangles: ')
  fprintf(fid, '%d \n', NumberOfTriangles)

  fprintf(fid, '%s', 'TotalSurfaceArea: ')
  fprintf(fid, '%10.6f \n', TotalSurfaceArea)

  fprintf(fid, '%s', 'meanTriangleArea: ')
  fprintf(fid, '%10.6f \n', meanTriangleArea)

  fprintf(fid, '%s', 'minTriangleArea: ')
  fprintf(fid, '%10.6f \n', minTriangleArea)

  fprintf(fid, '%s', 'maxTriangleArea: ')
  fprintf(fid, '%10.6f \n', maxTriangleArea)

  fprintf(fid, '%s', 'meanEdgeLength: ')
  fprintf(fid, '%10.6f \n', meanEdgeLength)

  fprintf(fid, '%s', 'minEdgeLength: ')
  fprintf(fid, '%10.6f \n', minEdgeLength)

  fprintf(fid, '%s', 'maxEdgeLength: ')
  fprintf(fid, '%10.6f \n', maxEdgeLength)

  fprintf(fid, '%s', 'medianDegree: ')
  fprintf(fid, '%d \n', medianDegree)

  fprintf(fid, '%s', 'minDegree: ')
  fprintf(fid, '%d \n', minDegree)

  fprintf(fid, '%s', 'maxDegree: ')
  fprintf(fid, '%d \n', maxDegree)

fclose(fid);

%% Load head surface data and sensors
 load('Surfaces/OuterSkin_4096.mat')
 Surface = TriRep(Triangles, Vertices);
 
 BDI_EEGlab_Electrodes_64
 Sensors = [ElectrodePositions_3D(:,2), -ElectrodePositions_3D(:,1), ElectrodePositions_3D(:,3)];
 
 [SensorTriangles, SensorPoints] = GetSurfaceLocationOfSensors(Sensors, Surface);
 
 %% Write it as bzip2'd text files 
 fid = fopen('Surfaces/sensors_OuterSkin_4096_bdi_eeglab_64.txt','wt');
 for k = 1:length(ElectrodeLabels),
   fprintf(fid, '%s %d %10.6f %10.6f %10.6f \n', ElectrodeLabels{k}, SensorTriangles(k), SensorPoints(k,:))
 end
 fclose(fid);
 
 system('bzip2 Surfaces/sensors_OuterSkin_4096_bdi_eeglab_64.txt')
 
 fid = fopen('Surfaces/sensors_OuterSkin_4096_bdi_eeglab_64_2D.txt','wt');
 fprintf(fid, '%10.6f %10.6f \n', ElectrodePositions_2D.')
 fclose(fid);
 
 system('bzip2 Surfaces/sensors_OuterSkin_4096_bdi_eeglab_64_2D.txt')
 
 
 
 
 

%% Load skull surface data
 load('Surfaces/OuterSkull_4096.mat')

%% Write it as bzip2'd text files 
 fid = fopen('Surfaces/vertices_outer_skull_4096.txt','wt');
 fprintf(fid, '%10.6f %10.6f %10.6f \n', Vertices.')
 fclose(fid);
 system('bzip2 Surfaces/vertices_outer_skull_4096.txt')
 
 fid = fopen('Surfaces/vertex_normals_outer_skull_4096.txt','wt');
 fprintf(fid, '%10.6f %10.6f %10.6f \n', VertexNormals.')
 fclose(fid);
 system('bzip2 Surfaces/vertex_normals_outer_skull_4096.txt')
 
 fid = fopen('Surfaces/triangles_outer_skull_4096.txt','wt');
 fprintf(fid, '%d %d %d \n', Triangles.' - 1)
 fclose(fid);
 system('bzip2 Surfaces/triangles_outer_skull_4096.txt')
 
 clear all



%% Load supplimentary information
load('Surfaces/SummaryInfo_OuterSkull_4096.mat')

%% Write it as a text file
fid = fopen('Surfaces/info_outer_skull_4096.txt','wt');

  fprintf(fid, '%s', 'NumberOfVertices: ')
  fprintf(fid, '%d \n', NumberOfVertices)

  fprintf(fid, '%s', 'NumberOfTriangles: ')
  fprintf(fid, '%d \n', NumberOfTriangles)

  fprintf(fid, '%s', 'TotalSurfaceArea: ')
  fprintf(fid, '%10.6f \n', TotalSurfaceArea)

  fprintf(fid, '%s', 'meanTriangleArea: ')
  fprintf(fid, '%10.6f \n', meanTriangleArea)

  fprintf(fid, '%s', 'minTriangleArea: ')
  fprintf(fid, '%10.6f \n', minTriangleArea)

  fprintf(fid, '%s', 'maxTriangleArea: ')
  fprintf(fid, '%10.6f \n', maxTriangleArea)

  fprintf(fid, '%s', 'meanEdgeLength: ')
  fprintf(fid, '%10.6f \n', meanEdgeLength)

  fprintf(fid, '%s', 'minEdgeLength: ')
  fprintf(fid, '%10.6f \n', minEdgeLength)

  fprintf(fid, '%s', 'maxEdgeLength: ')
  fprintf(fid, '%10.6f \n', maxEdgeLength)

  fprintf(fid, '%s', 'medianDegree: ')
  fprintf(fid, '%d \n', medianDegree)

  fprintf(fid, '%s', 'minDegree: ')
  fprintf(fid, '%d \n', minDegree)

  fprintf(fid, '%s', 'maxDegree: ')
  fprintf(fid, '%d \n', maxDegree)

fclose(fid);

clear all
 
 

%% Load skull surface data
 load('Surfaces/InnerSkull_4096.mat')

%% Write it as bzip2'd text files 
 fid = fopen('Surfaces/vertices_inner_skull_4096.txt','wt');
 fprintf(fid, '%10.6f %10.6f %10.6f \n', Vertices.')
 fclose(fid);
 system('bzip2 Surfaces/vertices_inner_skull_4096.txt')
 
 fid = fopen('Surfaces/vertex_normals_inner_skull_4096.txt','wt');
 fprintf(fid, '%10.6f %10.6f %10.6f \n', VertexNormals.')
 fclose(fid);
 system('bzip2 Surfaces/vertex_normals_inner_skull_4096.txt')
 
 fid = fopen('Surfaces/triangles_inner_skull_4096.txt','wt');
 fprintf(fid, '%d %d %d \n', Triangles.' - 1)
 fclose(fid);
 system('bzip2 Surfaces/triangles_inner_skull_4096.txt')
 
 clear all



%% Load supplimentary information
load('Surfaces/SummaryInfo_InnerSkull_4096.mat')

%% Write it as a text file
fid = fopen('Surfaces/info_inner_skull_4096.txt','wt');

  fprintf(fid, '%s', 'NumberOfVertices: ')
  fprintf(fid, '%d \n', NumberOfVertices)

  fprintf(fid, '%s', 'NumberOfTriangles: ')
  fprintf(fid, '%d \n', NumberOfTriangles)

  fprintf(fid, '%s', 'TotalSurfaceArea: ')
  fprintf(fid, '%10.6f \n', TotalSurfaceArea)

  fprintf(fid, '%s', 'meanTriangleArea: ')
  fprintf(fid, '%10.6f \n', meanTriangleArea)

  fprintf(fid, '%s', 'minTriangleArea: ')
  fprintf(fid, '%10.6f \n', minTriangleArea)

  fprintf(fid, '%s', 'maxTriangleArea: ')
  fprintf(fid, '%10.6f \n', maxTriangleArea)

  fprintf(fid, '%s', 'meanEdgeLength: ')
  fprintf(fid, '%10.6f \n', meanEdgeLength)

  fprintf(fid, '%s', 'minEdgeLength: ')
  fprintf(fid, '%10.6f \n', minEdgeLength)

  fprintf(fid, '%s', 'maxEdgeLength: ')
  fprintf(fid, '%10.6f \n', maxEdgeLength)

  fprintf(fid, '%s', 'medianDegree: ')
  fprintf(fid, '%d \n', medianDegree)

  fprintf(fid, '%s', 'minDegree: ')
  fprintf(fid, '%d \n', minDegree)

  fprintf(fid, '%s', 'maxDegree: ')
  fprintf(fid, '%d \n', maxDegree)

fclose(fid);

clear all



%% Load cortical surface data
ThisSurface = 'TVB_WhiteMatter'
ThisConnectivity = 'G_20110513_hemisphere_both_subcortical_false_regions_80'

load('Surfaces/Cortex_TVB_WhiteMatter.mat')

%% 
DirectoryName = ThisSurface

%% Make the directory
 system(['mkdir ' DirectoryName])

%% Write it as bzip2'd text files 
fid = fopen([DirectoryName filesep 'vertices.txt'],'wt');
fprintf(fid, '%10.6f %10.6f %10.6f \n', Vertices.')
fclose(fid);
system(['bzip2 ' DirectoryName filesep 'vertices.txt'])

fid = fopen([DirectoryName filesep 'vertex_normals.txt'],'wt');
fprintf(fid, '%10.6f %10.6f %10.6f \n', VertexNormals.')
fclose(fid);
system(['bzip2 ' DirectoryName filesep 'vertex_normals.txt'])

fid = fopen([DirectoryName filesep 'triangles.txt'],'wt');
fprintf(fid, '%d %d %d \n', Triangles.' - 1)
fclose(fid);
system(['bzip2 ' DirectoryName filesep 'triangles.txt'])



%% Load region mapping data
load(['Surfaces/RegionMapping_' ThisSurface '_' ThisConnectivity '.mat'])

%% Write it as bzip2'd text files 
fid = fopen([DirectoryName filesep 'region_mapping_' ThisConnectivity '.txt'],'wt');
fprintf(fid, '%d ', RegionMapping - 1)
fclose(fid);
system(['bzip2 ' DirectoryName filesep 'region_mapping_' ThisConnectivity '.txt'])


%% Load supplimentary information
load('Surfaces/SummaryInfo_Cortex_TVB_WhiteMatter.mat')

%% Write it as a text file
fid = fopen([DirectoryName filesep 'info.txt']','wt');

  fprintf(fid, '%s', 'NumberOfVertices: ')
  fprintf(fid, '%d \n', NumberOfVertices)

  fprintf(fid, '%s', 'NumberOfTriangles: ')
  fprintf(fid, '%d \n', NumberOfTriangles)

  fprintf(fid, '%s', 'TotalSurfaceArea: ')
  fprintf(fid, '%10.6f \n', TotalSurfaceArea)

  fprintf(fid, '%s', 'meanTriangleArea: ')
  fprintf(fid, '%10.6f \n', meanTriangleArea)

  fprintf(fid, '%s', 'minTriangleArea: ')
  fprintf(fid, '%10.6f \n', minTriangleArea)

  fprintf(fid, '%s', 'maxTriangleArea: ')
  fprintf(fid, '%10.6f \n', maxTriangleArea)

  fprintf(fid, '%s', 'meanEdgeLength: ')
  fprintf(fid, '%10.6f \n', meanEdgeLength)

  fprintf(fid, '%s', 'minEdgeLength: ')
  fprintf(fid, '%10.6f \n', minEdgeLength)

  fprintf(fid, '%s', 'maxEdgeLength: ')
  fprintf(fid, '%10.6f \n', maxEdgeLength)

  fprintf(fid, '%s', 'medianDegree: ')
  fprintf(fid, '%d \n', medianDegree)

  fprintf(fid, '%s', 'minDegree: ')
  fprintf(fid, '%d \n', minDegree)

  fprintf(fid, '%s', 'maxDegree: ')
  fprintf(fid, '%d \n', maxDegree)

fclose(fid);


%%



%%%EoF%%%