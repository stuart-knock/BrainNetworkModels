
%% Load the data, it's in ./Sensors/
 BDI_EEGlab_Electrodes_64

%% Write EEG unbit vector sensors as bzip2'd text files

 %Normalise to unit vector.
 ElectrodePositions_3D = ElectrodePositions_3D ./ repmat(sqrt(sum(ElectrodePositions_3D.^2, 2)), [1 3]);
 
 %Store with "enough" precission to retain unit vectors...
 fid = fopen('Sensors/EEG_unit_vectors_BrainProducts_62.txt','wt');
 for k = 1:length(ElectrodeLabels),
   fprintf(fid, '%s %20.16f %20.16f %20.16f \n', ElectrodeLabels{k}, ElectrodePositions_3D(k, :))
 end
 fclose(fid);

 %Save some space...
 system('bzip2 Sensors/EEG_unit_vectors_BrainProducts_62.txt')