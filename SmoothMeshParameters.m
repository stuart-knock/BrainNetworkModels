%% Approximates local coupling on triangulated surface, based on the 
% subtraction of two Gaussian distributions. ie G1 - G2
%
% ARGUMENTS:
%           tr -- Surface as a TriRep object  
%           G1 -- .Std -- Standard deviation of 1st Gaussian.
%                 .Amp -- Amplitude of 1st Gaussian.
%           G2 -- .Std -- Standard deviation of 2nd Gaussian.
%                 .Amp -- Amplitude of 2nd Gaussian.
%           Neighbourhood -- The N-ring to truncate approximation.
%
% OUTPUT: 
%           LocalCoupling -- Discrete approximation to Local coupling 
%                            based on subtraction of 2 gaussians.
%           Convergence -- <description>
%
% REQUIRES:
%           Gaussian() -- Gaussian distribution.
%           dis() -- euclidean distance.
%           GetLocalSurface() -- extracts sub-region of surface.
%           MeshDistance() -- Calculates distances from a vertex to other
%                             vertices on the surface by traversing edges of
%                             the surface.
%
% USAGE:
%{   
       Left  = load('Polish_213_lh.pial.mat');
       Right = load('Polish_213_rh.pial.mat');
       Vertices  = [Left.Vertices  ; Right.Vertices];
       Triangles = [Left.Triangles ; Right.Triangles+length(Left.Vertices)]; 
       tr = TriRep(Triangles, Vertices);

      %For epilepsy work...   
       TheseParameters = {'nu_se'};
       options = SpatializeDynamicParameters(options, TheseParameters);

       options = SmoothMeshParameters(TR, options, TheseParameters);

%}
%
% MODIFICATION HISTORY:
%     SAK(24-11-2010) -- Original
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function options = SmoothMeshParameters(TR, options, TheseParameters, Neighbourhood)  
%% Set defaults for any argument that weren't specified
 if nargin<3,
   error(['BrainNetworkModels:' mfilename ':ParametersMustBeSpecified'],'The parameters you want Smoothed must be specified...'); %
 end
 if nargin<4,
   Neighbourhood = 3; %
 end
%TODO: make possible to specify in mm
 
%% Sizes and preallocation
 NumberofVertices = length(TR.X);
 
 
%% Do The Stuff
 for k = 1:length(TheseParameters),
   for i = 1:NumberofVertices,
     [~, ~, GlobalVertexIndices] = GetLocalSurface(TR, i, Neighbourhood);
     %
     options.Dynamics.(TheseParameters{k})(i) = mean(options.Dynamics.(TheseParameters{k})(GlobalVertexIndices));
     
   end
 end
       
%keyboard

end %function SmoothMeshParameters()