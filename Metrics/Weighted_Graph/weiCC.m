%% Compute cluster index of a weighted directed graph.
%  Extends the definition of Onnela etal, which only considers cycles of 3 
%  nodes, to include 3-node clusters where 2 nodes have edges connecting 
%  to the 3rd, and 3-node clusters where 2 nodes have edges connecting 
%  from the 3rd. This is all cases of 3-node 3-edge motifs where a direct
%  connection between each node exists (triangles), ie it doesn't include 
%  3-node 3-edge motifs where 2 of the edges lie between the same 2 nodes
%  leaving 2 nodes without a direct connection.
%
%  Feed-back(Onnela) Clustering part of the code is based on a modification 
%  of Olaf's weighted_clustind_onella.m
%
%  Calling node of interst "i"
%    FeedBack Clustering: uses the definition provided by Onnela etal, can
%                         be thought of as the strength with which the 
%                         nodes i affect affect those node which in turn 
%                         affect i. (Cycles)
%             Clustering: connection between nodes that affect i and nodes
%                         i affect
%
%    Output   Clustering: generalises Onnela etal definition to include the
%                         connection beetween 2 nodes i affect
%    Input    Clustering: generalises Onnela etal definition to include the
%                         connection beetween 2 nodes which affect i
% 
%
%  ARGUMENTS:  CIJ -- weighted-directed(ie non-symmetric) connection matrix
%
%
%  OUTPUT:  CC   -- Total     cluster index for each vertex.
%           oCC  -- Output    cluster index for each vertex.
%           iCC  -- Input     cluster index for each vertex.
%           fbCC -- Feed-Back cluster index for each vertex.
%           maCC --            cluster index for each vertex.
%
%
%  MODIFICATION HISTORY:
%    SAK(20-6-2007) -- Original... extend/modify from Olaf(Onnela)...
%    SAK(Nov 2013)  -- Move to git, future modification history is
%                      there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%normalisation is to all vertices fully connected with weight max(CIJ).
%%%should this be something like fully connected with mean weight???


function [CC, oCC, iCC, fbCC, maCC] = weiCC(CIJ)
  
  N = size(CIJ,1);
  CIJ = CIJ ./ max(CIJ(:));  %Explicitly normalise graph weights to be on [0,1]
  CIJ = CIJ.^(1/3);  % take cube root up front so that we end up with gegometric mean of triangle weights... 
  
  oCC  = zeros(N,1);
  iCC  = zeros(N,1);
  fbCC = zeros(N,1);
  maCC = zeros(N,1);
  CC   = zeros(N,1);
  
  %loop over all vertices
  for v=1:N,
    %Output Clustering
    nbo = find(CIJ(v,:)); %Neighbours -- edges from v
    lnbo = length(nbo);   %Out degree of v
    if lnbo > 1, %Cause equiv of 2 out-pairs we are conuting 2ice here, but norm shld take care of this... in other words, CIJ(v,nbo).' * CIJ(v,nbo), is symmetric but we sum and norm as though it's not...  
      oCC(v) = sum(sum(CIJ(nbo,nbo) .* (CIJ(v,nbo).' * CIJ(v,nbo)))) ./ (lnbo^2-lnbo);%%%EQUIV: (CIJ(v,nbo) * CIJ(nbo,nbo) * CIJ(v,nbo).')./ (lnbo^2-lnbo);
    else 
      oCC(v) = 0;
    end
    
    %Input Clustering
    nbi = find(CIJ(:,v).'); %Neighbours -- edges to v
    lnbi = length(nbi);     %In degree of v
    if lnbi > 1,
      iCC(v) = sum(sum(CIJ(nbi,nbi) .* (CIJ(nbi,v)*CIJ(nbi,v).'))) ./ (lnbi^2-lnbi);%%%EQUIV: (CIJ(nbi,v).' * CIJ(nbi,nbi) * CIJ(nbi,v)) ./ (lnbi^2-lnbi);
    else 
      iCC(v) = 0;
    end
    
    %FeedBack Clustering (3-node,3-edge cycles: Onnela etal)
    nb = union(nbo,nbi); %Neighbours -- edges to or from v (no repeats means explicit counting vertices not edges)
    lnb = length(nb);    %Total degree
    if lnb > 1,
      %keyboard 
      fbCC(v) = (CIJ(v,nbo)*CIJ(nbo,nbi)  *CIJ(nbi,v)) ./ (lnb^2-lnb); %%%CIJ(v,nbo)*(CIJ(nbo,nbi)./((repmat(CIJ(v,nbo).',[1 length(nbi)]) + CIJ(nbo,nbi) + repmat(CIJ(nbi,v).',[length(nbo) 1]))./3))*CIJ(nbi,v) ;
      maCC(v) = (CIJ(v,nbo)*CIJ(nbi,nbo).'*CIJ(nbi,v)) ./ (lnb^2-lnb); %%% will capture the triangle we are missing... 
    else
      fbCC(v) = 0;
      maCC(v) = 0;
    end
    
    %Total Clustering
    CC(v) = (oCC(v).*iCC(v).*fbCC(v).*maCC(v)).^0.25; %Geometric mean of 4 components of CC
  
  end %loop over all vertices

end %function weiCC()
