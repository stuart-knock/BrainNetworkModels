function D = MeshDistance(G)

% Modified to only return vector of distance from first node...

%DISTANCE_WEI       Distance matrix
%
%   D = distance_wei(W);
%
%   The distance matrix contains lengths of shortest paths between all
%   pairs of nodes. An entry (u,v) represents the length of shortest path 
%   from node u to node v. The average shortest path length is the 
%   characteristic path length of the network.
%
%   Input:      W,      weighted directed/undirected connection matrix
%
%   Output:     D,      distance matrix
%
%   Notes:
%       The input matrix must be a mapping from weight to distance. For 
%   instance, in a weighted correlation network, higher correlations are 
%   more naturally interpreted as shorter distances, and the input matrix 
%   should consequently be some inverse of the connectivity matrix.
%       Lengths between disconnected nodes are set to Inf.
%       Lengths on the main diagonal are set to 0.
%
%   Algorithm: Dijkstra's algorithm.
%
%
%   Mika Rubinov, UNSW, 2007-2010.

%Modification history
%2007: original
%2009-08-04: min() function vectorized
% SAK(15-11-2010) -- minor mod to only return vector of distance from first node...
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...

 n = length(G);
 D = zeros(1,n); D(1,2:end) = inf;           %distance matrix
 
 S = true(1,n);                              %distance permanence (true is temporary)
 V = 1;
 while 1,
   S(V) = false;                             %distance u->V is now permanent
   G(:,V) = 0;                               %no in-edges as already shortest
   for v=V,
     W = find(G(v,:));                       %neighbours of shortest nodes
     D(1,W) = min([D(1,W) ; D(1,v)+G(v,W)]); %smallest of old/new path lengths
   end
   
   minD = min(D(1,S));
   if isempty(minD) || isinf(minD),          %isempty: all nodes reached;
     break,                                  %isinf: some nodes cannot be reached
   end
   
   V = find(D(1,:)==minD);
 end

end %function MeshDistance()