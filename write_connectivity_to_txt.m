%% Write connectivity data to bzip2'd text files for use as test data in  
% tvb.simulator, also write suplimentary info, but don't bzip2 it. 
% NOTE: This doesn't currently include the additional region area and
%       average orientation information...

%% Specify connectivity data 
 options.Connectivity.WhichMatrix = 'O52R00_IRP2008';
 options.Connectivity.hemisphere = 'both';
 options.Connectivity.RemoveThalamus = true;
 options.Connectivity.invel = 1;
 

%% Get it
 options.Connectivity = GetConnectivity(options.Connectivity);


%% Create a directory name
 DirectoryName = lower(options.Connectivity.WhichMatrix);
 DirectoryName = [DirectoryName '_hemisphere_' lower(options.Connectivity.hemisphere)];
 if options.Connectivity.RemoveThalamus,
   DirectoryName = [DirectoryName '_subcortical_false'];
 else
   DirectoryName = [DirectoryName '_subcortical_true'];
 end
 DirectoryName = [DirectoryName '_regions_' num2str(options.Connectivity.NumberOfNodes)];
 disp(['Connectivity directory name:  ' DirectoryName])
 
%% Make the directory
 system(['mkdir ' DirectoryName])
 
%% Write weights as bzip2'd text files 
 weights = options.Connectivity.weights;
 save([DirectoryName filesep 'weights.txt'], 'weights', '-ASCII');
 
 system(['bzip2 ' DirectoryName filesep 'weights.txt'])


%% Write tract_lengths as bzip2'd text files 
 tract_lengths = options.Connectivity.delay;
 save([DirectoryName filesep 'tract_lengths.txt'], 'tract_lengths', '-ASCII');
 
 system(['bzip2 ' DirectoryName filesep 'tract_lengths.txt'])
 

%% Write centres as bzip2'd text files
 centres = options.Connectivity.Position;
 NodeStr = options.Connectivity.NodeStr;
 
 fid = fopen([DirectoryName filesep 'centres.txt'], 'wt');
 for k = 1:length(NodeStr),
   fprintf(fid, '%s %10.6f %10.6f %10.6f \n', NodeStr{k}, centres(k,:))
 end
 fclose(fid);

 system(['bzip2 ' DirectoryName filesep 'centres.txt'])


%% Write supplementry information as a text file
fid = fopen([DirectoryName filesep 'info.txt'], 'wt');

  fprintf(fid, '%s %s \n', 'Matrix label: ', options.Connectivity.WhichMatrix)
  fprintf(fid, '%s %s \n', 'Centres space: ', options.Connectivity.centres)
  fprintf(fid, '%s %d \n', 'Number of regions: ', options.Connectivity.NumberOfNodes)
  
  fprintf(fid, '%s \n', 'Left hemisphere regions:')
  fprintf(fid, '%d', options.Connectivity.LeftNodes)
  
 fclose(fid);
 
 
 %%% EoF %%% 