%% Write an .OFF tesselated surface file format...
% http://people.sc.fsu.edu/~jburkardt/html/off_format.html
% http://shape.cs.princeton.edu/benchmark/documentation/off_format.html
%
% NOTE: This is a simplified implementation not using most .off features.
%
% ARGUMENTS:
%           OffFile -- File name
%           Vertices -- 
%           Triangles -- 
%           #NOTE: Ignoring Normals for now... -- 
%
% OUTPUT: 
%           OffFile -- Name of file that was written to...
%
% USAGE:
%{    
    OffFile = WriteOFF(OffFile, Vertices, Triangles);
%}
%
% MODIFICATION HISTORY:
%     SAK(10-05-2012) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function OffFile = WriteOFF(OffFile, Vertices, Triangles) %, Normals
 %% If necessary, open GUI to select an .off file
 yes = true; y = true;  yep = true;
 no = false; n = false; nope = false;
 if exist(OffFile, 'file'),
   overwrite = input('File already exists, overwrite? [yes|no]: ');
 else
   overwrite = 'It''s a new file name, it doesn''t exist : woohoo...';
 end
 switch lower(overwrite)
   case {'y', 'yes', 'yep',  true }
     disp(['Overwriting file: ' OffFile])
   case {'n', 'no', 'nope', false}
     [OffFileName, OffFilePath] = uigetfile('*.off');
     OffFile = [OffFilePath OffFileName];
   otherwise 
     disp(['Writing file: ' OffFile])
 end
 
 NumberOfVertices = length(Vertices);
 NumberOfTriangles = length(Triangles);

 fid = fopen(OffFile,'wt');
 fprintf(fid, '%s \n', 'OFF')
 fprintf(fid, '%d %d %d \n', [NumberOfVertices NumberOfTriangles 0])
 fprintf(fid, '%10.6f %10.6f %10.6f \n', Vertices.')
 if min(Triangles(:)) == 1,
   fprintf(fid, '3 %d %d %d \n', Triangles.' - 1)
 elseif  min(Triangles(:)) == 0,
   fprintf(fid, '3 %d %d %d \n', Triangles.')
 else
   error(['BrainNetworkModels:' mfilename ':TriangleIndexProblem'], 'Something seems to be wrong with your triangles');
 end 

end %function WriteOFF()

