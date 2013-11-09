%% Remove edges untill cutoff of the total number of edges remain, keeping connected
%
% Returns strongly connected matrix with the largest possible nodes
% assumes that input matrix is strongly connected.
%
% ARGUMENTS:
%           G -- Connectivity matrix representing the graph
%           cutoff -- fraction of edges to keep
%           Symmetric -- A 1 or 0 specifying whether the matix is symmetric or not.
%
% OUTPUT: 
%           mtx -- G with only cutoff of edges kept, require connected.
%
% USAGE:
%
% MODIFICATION HISTORY:
%     MR(Early-2006)  -- Original.
%     SAK(15-11-2006) -- Generalised for nonsymetric matrix, defaults 
%                        to symmetric for backward compatability...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function mtx = diacut(G, cutoff, Symmetric)
%% Set any argument that weren't specified
 if nargin < 3,
   Symmetric = 1;
 end

%% Determine properties of G 
 n = size(G,1);                              

%remove diagonal to obtain true existing edges 
 if Symmetric,  %use lower triangular matrix
   mtx = tril(G, -1);                         
 else
   mtx = G.*(~eye(n,n));
 end

 index = find(mtx);
 index = sortrows([index mtx(index)], 2);
 index = index(:,1);                         %indexes of edges from smallest to largest
 remainder = length(index);                  %will decrease with edge removal
 
 if Symmetric,
   total_edges = ((n^2)-n)/2;                %-n don't use diagonal; /2 as use only lower triangle instead of both
 else
   total_edges = (n^2)-n;                    %-n don't use diagonal;
 end
   
%% Strip away unwanted elements of G
 while (remainder/total_edges) > cutoff,
   if not(isempty(index)),                   %if removable edges still exist
    %tests for connectedness without the edge
     [u v] = ind2sub(n, index(1));
     if Symmetric,
       matrix = mtx + mtx';
     else
       matrix = mtx;
     end
     
     matrix(u,v) = 0;
     neib = find(matrix(u,:));

     while 1,
       new_neib = setdiff(find(sum(matrix(neib,:),1)), neib);
       if isempty(new_neib),                 %if graph disconnects without node
         break
       elseif any(new_neib == v),            %if graph stays connected without node
         mtx(u,v) = 0;
         remainder = remainder - 1;
         break
       else                                  %keep searching
         neib = [neib new_neib];
       end
     end

     index(1) = [];
   else
     break                                   %if no removable edges left
   end
 end

% disp(remainder/total_edges);
 if Symmetric,
   mtx = mtx + mtx.';
 end
 
end %function diacut
