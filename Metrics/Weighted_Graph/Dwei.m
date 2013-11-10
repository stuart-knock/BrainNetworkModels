%% Weighted distance matrix for graph G of n nodes (Dijkstra's algorithm)
%
% ARGUMENTS:
%          G -- The graph (an NxN matrix) that you want to analyse. It is
%               assumed that the edges are a weight or connection strength,
%               and thus inversely proportional to distance.
%          n -- number of nodes.
%
% OUTPUT: 
%          D -- Matrix containing the weighted distances for the graph G.
%
% REQUIRES: 
%          none
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(21-09-2007) -- minor mod from Mika's Lwei
%     SAK(Nov 2013)   -- Move to git, future modification history is there...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function D = Dwei(G,n)
  
  E=find(G);
  G(E)=1./G(E);                 %invert weights: large -> short
  S=~eye(n);                    %distance permanence (0 is permanent)
  D=zeros(n); D(S)=inf;         %distance matrix
  
  for U=1:n
    G1=G;
    V=U;
    while 1
      G1(:,V)=0;                %no in-edges as already shortest
      for i=1:length(V);
        W = find(G1(V(i),:));   %neighbours of shortest nodes
        for j=1:length(W);
          D(U,W(j)) = min(D(U,W(j)), D(U,V(i))+G1(V(i),W(j)));
          %the smallest of old (if exist) and current path lengths
        end
      end
      
      mindist = min(D(U,S(U,:)));
      if isempty(mindist) || isinf(mindist), break, end;
      %isempty: all nodes reached; isinf: some nodes not reached
      
      V = find(D(U,:)==mindist);
      S(U,V) = 0;               %distance U->V is now permanent
    end
  end

end % function Dwei()
