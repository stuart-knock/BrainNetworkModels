%% Calculate Betweeness Centrality Coefficients, noe and edge wise, for a set of graphs 'x'
%
%
%  ARGUMENTS:
%    x[nodes,nodes,noepochs] -- A 3-D array of noepochs connectivity matricies,
%                               larger value = stronger connection.  
%   
%
%
%  OUTPUTS:
%    Hubco         [nodes, noepochs] -- Hub coefficient or Hub Betweeness Centrality, per epoch per node
%    nodeHubco     [nodes, 1]        -- Node-wise Hub index, averaged over epochs 
%    stdnodeHubco  [nodes, 1]        -- Standard deviation of nodeHubco.
%    epochHubco    [1, noepochs]     -- Epoch-wise hub index, maximum 
%    stdepochHubco [1, noepochs]     -- Standard deviation of epochHubco
%    epochwiseHub  [1, noepochs]     -- Epoch-wise hub, which nodes
%
%    Edgco         [nodes,nodes, noepochs] -- Edge Betweeness Centrality, per epoch per node
%    edgEdgco      [nodes*(nodes-1), 1]        -- Node-wise Edge index, averaged over epochs 
%    stdedgEdgeco  [nodes*(nodes-1), 1]        -- Standard deviation of nodeEdgco.
%    epochEdgco    [1, noepochs]     -- Epoch-wise Edg index, maximum 
%    stdepochEdgco [1, noepochs]     -- Standard deviation of epochEdgco
%    epochwiseEdg  [1, noepochs]     -- Epoch-wise Edg, which nodes
%
%
% MODIFICATION HISTORY:
%     SAK(22-06-2007) -- Original
%     SAK(25-09-2007) -- replace bcentvect with BCwei
%     SAK(25-09-2007) -- Change epochHubco to max rather than mean and
%                        store which node is the hub (epochwiseHub)
%     SAK(19-10-2007) -- Added Edge Betweeness Centrality, Changed function
%                        name from HubCoefficients to BetweenessCentrality. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 function [Hubco nodeHubco stdnodeHubco Edgco edgEdgco stdedgEdgco  epochHubco stdepochHubco epochwiseHub epochEdgco stdepochEdgco epochwiseEdg] = BetweenessCentrality(x)
 
  [nodes nodes noepochs] = size(x);

  Hubco = zeros(nodes,noepochs);
  Edgco = zeros(nodes,nodes,noepochs);
  for m=1:noepochs,
   [Hubco(:,m) Edgco(:,:,m)] = BCwei(x(:,:,m));
  end
  
  nodeHubco    = mean(Hubco,2);
  stdnodeHubco = std(Hubco,0,2);
 
  if nargout > 4,
    [epochHubco, epochwiseHub] = max(Hubco,[],1);
    stdepochHubco = std(Hubco,0,1);

    edgEdgco    = mean(Edgco,3);
    stdedgEdgco = std(Edgco,0,3);

    epochEdgco    = zeros(1,noepochs);
    epochwiseEdg  = zeros(1,noepochs);
    stdepochEdgco = zeros(1,noepochs);
    for m=1:noepochs,
      temp = Edgco(:,:,m);
      [epochEdgco(1,m), epochwiseEdg(1,m)] = max(temp(:));
      stdepochEdgco(1,m) = std(temp(:));
    end
  end
    
 end %function BetweenessCentrality()
