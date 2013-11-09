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
      %NOTE: for physiologicallly plausible "local coupling" only the
      %      higher resolution meshes will really make sense.
       ThisSurface = 'reg13'
       load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles'); % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals'
       tr = TriRep(Triangles, Vertices); % Convert to TriRep object

       G1.Std =  5;
       G1.Amp =  2; %NOTE: set me to zero for single -ve Gaussian coupling.
       G2.Std = 20;
       G2.Amp =  1; %NOTE: set me to zero for single +ve Gaussian coupling.

       Neighbourhood = 6;

      %NOTE: check your values by directly calling Gaussian().
       load(['SummaryInfo_Cortex_' ThisSurface '.mat'], 'meanEdgeLength')
       small_step = 2*4*max(G2.Std,G1.Std) / 1024.0;
       X1 =  -4*max(G2.Std,G1.Std):small_step:4*max(G2.Std,G1.Std);
       X2 =  -Neighbourhood*meanEdgeLength:meanEdgeLength:Neighbourhood*meanEdgeLength;
       figure, plot(X1, Gaussian(X1, G1.Std, G1.Amp) - Gaussian(X1, G2.Std, G2.Amp), '--b', 'LineWidth', 4)
       xlabel('(mm)')
       hold on
       plot(X2, Gaussian(X2, G1.Std, G1.Amp) - Gaussian(X2, G2.Std, G2.Amp), 'r', 'LineWidth', 2)
       legend({'What you want...', 'What you''ll get...'})

       [LocalCoupling, Convergence] = LocalCoupling(tr, G1, G2, Neighbourhood);

       %Check quality, this should be small (<1e-6) -- if not you need a larger Neighbourhood:
        figure, plot(Convergence)
%}
%
% MODIFICATION HISTORY:
%     SAK(24-11-2010) -- Original: from MeshLaplacian().
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [LocalCoupling, Convergence] = LocalCoupling(TR, G1, G2, Neighbourhood, Homogenise)  
%% Set defaults for any argument that weren't specified
 if nargin<4,
   Neighbourhood = 8; %for spalloc()
 end
 
 if nargin<5,
   Homogenise = false; %Don't fudge clean-up discreetisation errors...
 end
 
 
%% Sizes and preallocation
 NumberofVertices = length(TR.X);
 AverageNeighboursPerVertex = 342; %for spalloc() %FIXME: Need a principaled way to approximate this, based on Neighbourhood...

 LocalCoupling = spalloc(NumberofVertices, NumberofVertices, AverageNeighboursPerVertex*NumberofVertices);

 
%% Do The Stuff
 if nargout > 1,
   Convergence = zeros(1,NumberofVertices);
 end
 for i = 1:NumberofVertices,
   [LocalVertices, LocalTriangles, GlobalVertexIndices, ~, nRing] = GetLocalSurface(TR, i, Neighbourhood);
   
   %Get distance to vertices in neihbourhood of current vertex
   LocalTR = TriRep(LocalTriangles, LocalVertices);
   LocalEdges = edges(LocalTR);
   LocalEdgeLengths = dis(LocalVertices(LocalEdges(:,1),:).', LocalVertices(LocalEdges(:,2),:).');
   CM = zeros(length(LocalVertices));
   EdgeLind = sub2ind(size(CM),LocalEdges(:,1),LocalEdges(:,2));
   CM(EdgeLind) = LocalEdgeLengths;
   DeltaX = MeshDistance(CM); %TODO: Should implement geodesic distance (interpelated surface);
   DeltaX = DeltaX(1,2:end);
   
   %
   LocalCoupling(GlobalVertexIndices(2:end),i) = Gaussian(DeltaX, G1.Std, G1.Amp) - Gaussian(DeltaX, G2.Std, G2.Amp);  %) ./ (length(GlobalVertexIndices)-1)
   
   %TODO: Add check of outer ring values, if > critical value then increase neighbourhood...
   if nargout > 1,
     Convergence(1,i) = max(LocalCoupling(GlobalVertexIndices((end-nRing(1,Neighbourhood)+1):end),i));
   end
 
 end
   
 if Homogenise,
   mask = LocalCoupling > 0.0;
   plc =  LocalCoupling .* mask;
   
   mask = LocalCoupling < 0.0;
   nlc =  LocalCoupling .* mask;
   
   psumlc = sum(plc, 1);
   nsumlc = sum(nlc, 1);
   
   mpslc = mean(psumlc);
   mnslc = mean(nsumlc);
   
   %pscale = (mpslc ./ psumlc);
   %nscale = (mnslc ./ nsumlc);
   
   plc = plc * diag(sparse(mpslc ./ psumlc));
   nlc = nlc * diag(sparse(mnslc ./ nsumlc));
%keyboard
   LocalCoupling = plc + nlc;
 end
       
%keyboard
 

end %function LocalCoupling()