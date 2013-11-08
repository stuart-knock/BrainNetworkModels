%% Load an .OFF tesselated surface file format...
% http://people.sc.fsu.edu/~jburkardt/html/off_format.html
% http://shape.cs.princeton.edu/benchmark/documentation/off_format.html
%
% ARGUMENTS:
%           OffFile -- Full path file name
%
% OUTPUT: 
%          LocalSurfaceFigureHandle -- <description>
%
% USAGE:
%{    
    [HeaderInfo Vertices Faces Normals] = LoadOFF();
%}
%
% MODIFICATION HISTORY:
%     SAK(02-09-2010) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [HeaderInfo Vertices Faces Normals] = LoadOFF(OffFile)  
 %% If necessary, open GUI to select an .off file
 if nargin<1 || ~exist(OffFile, 'file'),
   [OffFileName, OffFilePath] = uigetfile('*.off');
   OffFile = [OffFilePath OffFileName];
 end
 
 %% Parse header info
 ThisFID = fopen(OffFile,'r');
 
 HeaderInfo.Keyword = textscan(ThisFID, '%s',1);
 if strcmp(HeaderInfo.Keyword,'nOFF'),
  HeaderInfo.NumberOfDimensions = textscan(ThisFID, '%d',1);
 else 
   HeaderInfo.NumberOfDimensions = 3;
 end

 [HeaderInfo.NumberOfVFE EndOfHeaderPos]  = textscan(ThisFID, '%d%d%d',1); %Vertices, Faces, Edges
 
 %% Load the data  %%%NEED TO CHANGE TO ONLY DO NECCESSARRY.... And
 %% complete parsing of possible HeaderInfo.Keyword values.
  if nargout>1,
   %Vertices
    [Vertices EndOfVerticesPos] = textscan(ThisFID, '%f%f%f %*[^\n]', HeaderInfo.NumberOfVFE{1}, 'CollectOutput',true);
    Vertices = Vertices{1};
   
   %Faces
    Nv = zeros(1,HeaderInfo.NumberOfVFE{2});
    Faces = cell(1,HeaderInfo.NumberOfVFE{2});
    for k = 1:HeaderInfo.NumberOfVFE{2},
      Nv(k) = fscanf(ThisFID, '%d', 1);
      Faces{k} = fscanf(ThisFID, '%f', Nv(k));
    end
    
    if numel(unique(Nv)) == 1,
      Faces = [Faces{:}].' + 1;
    else
      warning(['BrainNetworkModels:' mfilename ':FacesReturnedAsCell'], 'As this surface consists of faces with differing numbers of vertices, Faces is being returned as a cell array... And with indices starting from 0');
    end
    
   %Normals
    if nargout>3,
      WhereAreNormals = strfind(HeaderInfo.Keyword{1}, 'N');
      if numel(WhereAreNormals{:})==1,
        fseek(ThisFID, EndOfHeaderPos, 'bof');
        switch WhereAreNormals{:}
          case{1},
            Normals = textscan(ThisFID, '%*f%*f%*f %f%f%f %*[^\n]', HeaderInfo.NumberOfVFE{1}, 'CollectOutput',true);
          case{2},
            Normals = textscan(ThisFID, '%*f%*f%*f %*f%*f%*f %f%f%f %*[^\n]', HeaderInfo.NumberOfVFE{1}, 'CollectOutput',true);
          otherwise
            warning(['BrainNetworkModels:' mfilename ':OptionNotCodedYet'], 'Arrgghhhh...');
        end
        Normals = Normals{1};
      else
        warning(['BrainNetworkModels:' mfilename ':ProblemFindingNormalsData'], 'Arrgghhhh...');
      end
    end
  end
 %%
  fclose(ThisFID);

end 