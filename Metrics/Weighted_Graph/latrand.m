%% Generate lattice and random surrogate graphs
%
% Returns strongly connected surrogate lattice and random graphs for G.
% randomising algorithm: Watts & Strogatz. Nature (1998) 393:441.
%
% ARGUMENTS:
%           G -- Connectivity matrix representing the graph
%           Symmetric -- A 1 or 0 specifying whether the matix is symmetric or not.
%
% OUTPUT: 
%        lattice --  
%        randos  -- 
%
% USAGE:
%
% MODIFICATION HISTORY:
%     MR(Early-2006)  -- Original.
%     SAK(15-11-2006) -- Generalised for nonsymetric matrix, defaults 
%                        to symmetric for backward compatability...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [lattice, randos] = latrand(G, Symmetric)
%% Set any argument that weren't specified
 if nargin < 2,
   Symmetric = 1;
 end

 n = size(G,1);
 
%% remove diagonal to obtain true existing edges
 if Symmetric,
   G = tril(G, -1);        %use lower triangular matrix           
 else
   G = G.*(~eye(n,n));
 end
 lattice = zeros(n,n);
 
%% Make lattice surrogate graph
 edges = sort(G(G~=0));   %find and order nonzero edges
 num_edge = length(edges);
 
 if Symmetric,
   num_neib = ceil(num_edge/n); %Avg Number of neighbours assuming uniform distribution
   edges = [zeros(num_neib*n - num_edge,1); edges]; %Pad with zeros to make edges the size of n*num_neib
 else
   num_neib = ceil(num_edge/(2*n)); %Avg Number of neighbours assuming uniform distribution
   edges = [zeros(num_neib*2*n - num_edge,1); edges]; %Pad with zeros to make edges the size of n*num_neib
 end
 
%Distribute edges, strongest closest to the diagonal, randomly.
 if Symmetric,
   for i=num_neib:-1:1,
     neib = edges(randperm(n));
     lattice = lattice + diag(neib(1:n-i),-i) + diag(neib(n-i+1:n),n-i);             %lower triangle, cylindrical/toroidal symmetry
     edges(1:n) = [];
   end
 else
   for i=num_neib:-1:1,
     neib = edges(randperm(2*n));
     lattice = lattice + diag(neib(1:n-i),-i) + diag(neib(n-i+1:n),n-i);             %lower triangle, cylindrical/toroidal symmetry
     lattice = lattice + diag(neib(n+1:(2*n-i)),i) + diag(neib(2*n-i+1:(2*n)),i-n);  %upper triangle, cylindrical/toroidal symmetry
     edges(1:(2*n)) = [];
   end
 end
 

%% Make random surrogate graph  %%%?THIS ALGORITHM PREFERENTIAL BREAKS NEAREST NEIGHBOUR CONNECTIONS?%%%
if nargout > 1,
 if Symmetric,   %Just fill connection matrix for symetric graphs
   randos = lattice;
   for i = 1:num_neib,
     for node = 1:n,
       old_out = mod(node+i-1,n)+1;
       old_in  = mod(node-1,  n)+1;
       new_in  = old_in;

      %New position  can't Already-Contain,  an edge
       while (randos(old_out,new_in) || randos(new_in,old_out)) || (new_in==old_out),
         new_in = ceil(n*rand);
       end

      %Move edge to its new randomly chosen position
       randos(old_out,new_in) = randos(old_out,old_in);
       randos(old_out,old_in) = 0;
     end
   end
   lattice = lattice + lattice';
   randos  = randos  + randos';
 else
   error('GraphMetrics:utilities:Weighted_Graph:latrand:NonSymNotCoded','HAVEN''T ADAPTED RANDOMISATION TO NON-SYMMETRIC GRAPHS...')
 end
end
 

% % %  else   
% % %    randos = zeros(size(lattice))
% % %    for i = 1:num_neib,
% % %      for node = 1:n,
% % %        old_out = mod(node+i-1,n)+1;
% % %        old_in  = mod(node-1,  n)+1;
% % %        new_in  = old_in;
% % % 
% % %        while (randos(old_out,new_in) || randos(new_in,old_out)) || (new_in==old_out),%%%SOME OF THESE WILL NEED TO BE LATTICE CONDITIONS
% % %          new_in = ceil(n*rand);
% % %        end
% % % 
% % %        randos(old_out,new_in) = lattice(old_out,old_in);
% % %      end
% % %    end
% % %  end

 
end %function 


% % %  edges = G(G~=0);
% % %  if Symmetric,
% % %    new_ind = find(tril(ones(n),-1));             %find lower half triangle indexes
% % %    new_ind = new_ind(randperm(length(new_ind))); %randomise order
% % %  else
% % %    new_ind = randperm(n^2);
% % %  end
% % %  
% % %  randos = zeros(n,n);
% % %  randos(new_ind(1:num_edge)) = edges;
% % %  %randos = reshape(randos,n,n
