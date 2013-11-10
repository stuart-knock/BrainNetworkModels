%% Generates a random matrix of G, without disconnection.
%
% In fully connected graphs this will spin its wheels and ultimately just
% randomly redistribute the edge weights...
%
% ARGUMENTS:
%          G -- A NxN matrix representing the graph. It should be non-symmetric
%               (as symmetry isn't maintained). It should be connected.
%
% OUTPUT: 
%          R -- Randomised G...
%
% REQUIRES: 
%          none
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
%  MODIFICATION HISTORY:
%    ORIGINAL(????) -- Don't remember where this came from... ?Olaf, Mika, Me?
%    SAK(Nov 2013)  -- Move to git, future modification history is
%                      there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function R = randedges(G)
  
%% Determine properties of G 
  n = size(G,1);                              

  %remove diagonal to obtain true existing edges
  R = G.*(~eye(n,n));
  
  [i j] = find(R);    %edge location
  K = length(i);      %number of edges
  
  [ni nj] = find((R==0)-eye(n,n)); %non-edge location, not counting self connections(diagonal)
  nK = length(ni);                 %number of non-edges
  
%% Randomly rewire all edges "iterations" number of times
  
  edge = randperm(K);
  for e=1:K, %cycles through all edges (with randperm)
    e1 = edge(e);
    rewire=0;
    
    a=i(e1);
    b=j(e1);
    
    nonedge = randperm(nK);
    for ne=1:nK, %cycles through all current non-edges (with randperm, break below quits this once a suitable edge movement is found)
      ne1 = nonedge(ne);
      c=ni(ne1);
      d=nj(ne1);
      
      if not(R(c,d)),   %double check that proposed new-edge doesn't exist
      
        %begin connectedness condition
        R1 = (R~=0) + eye(size(R));   %binary representation of R...
        R1(c,d) = 1;                  %...add proposed new edge
        R1(a,b) = 0;                  %...remove old edge 
        
        R2=R1;
        while 1,
          R3=R2;
          R2=R2+R2*R1;                %n-paths (n>1) to nodes
          new_path=(R2~=0).*(R3==0);  %check for paths between nodes taking additional steps
          
          if ~any(new_path(:));   %if no new paths exist
            break;                %...give up
          end
          if  R2(a,b), % a path exists between a and b
            rewire=1;  % we can move the edge
            break
          end
        end
      end
      
      
      if rewire,
        R(c,d) = R(a,b);
        R(a,b) = 0;
        
        i(e1) = c;                  %reassign edge locations
        j(e1) = d;
        ni(ne1) = a;
        nj(ne1) = b;
        break                       %move to next edge
      end
      
      %move to next edge
    
    end % for each possible rewire, untill one is found.
  
  end %all edges loop
  
  %distribute weights in a random pattern, this is important for highly
  %connected graphs wehere there can be only a limitwed number of places to
  %move an edge to...
  wts = find(R);                      %weights indices
  wts = wts(randperm(length(wts)));   %shuffle indices
  R(wts) = sort(R(R~=0));

end %function randedges()




% % % function R = randedges(G, Symmetric)
% % % %generates a random matrix of G preserving number of edges and their weights
% % % % 
% % % 
% % % %% Set any argument that weren't specified
% % %  if nargin < 2,
% % %    Symmetric = 1;
% % %  end
% % %  
% % % %% Determine properties of G 
% % %  n = size(G,1);                              
% % % 
% % % %remove diagonal to obtain true existing edges 
% % %  if Symmetric,
% % %    R = tril(G, -1);
% % %    AE = tril(ones(n,n), -1);%All possible Edges
% % %  else
% % %    R = G.*(~eye(n,n));
% % %    AE = ~eye(n,n);%All possible Edges
% % %  end
% % % 
% % %   edges = R(find(R));     %edge location
% % %   K = length(edges);   %number of edges
% % %   
% % %   PE = find(AE); %All possible edge locations
% % %   
% % % %% Randomise 
% % %   RPE = PE(randperm(length(PE))); % A random permutation of all possible edges
% % %   %keyboard
% % %   R = zeros(n,n);
% % %   R(RPE(1:K)) = edges;
% % %   R = reshape(R,n,n);
% % % 
% % % %%
% % %   if Symmetric,
% % %     R = R + R.';
% % %   end
% % % 
% % % end %function randedges


%%%EoF%%%



