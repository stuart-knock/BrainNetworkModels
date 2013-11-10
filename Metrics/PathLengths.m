%% Calculate Distance Matricies for a set of graphs 'x' and average them in the
% possible ways to get Path Lengths.
%
%
%  ARGUMENTS:
%    x[nodes,nodes,noepochs] -- A 3-D array of noepochs connectivity matricies, 
%                               larger value = stronger connection. 
%
%
%  OUTPUTS:
%    PL         -- Path Length, averaged over all nodes and epochs.
%    stdPL      -- Standard deviation of PL.
%    nodeoPL    -- Average distance to another node in the graph
%    stdnodeoPL -- Standard deviation of nodeoPL.
%    nodeiPL    -- Average distance from another node in the graph
%    stdnodeiPL -- Standard deviation of nodeiPL.
%    epochPL    -- Epoch-wise Path Length, averaged over all nodes.
%    stdepochPL -- Standard deviation of epochPL.
%    D[nodes,nodes,noepochs] -- Distance matricies corresponding to x
%
%
% REQUIRES: 
%          Dwei() -- Weighted distance matrix for graph (Dijkstra's algorithm).
%
% USAGE:
%{
      %See ../PlottingTools/PlotGraphMetrics.m
%}
%
%
% MODIFICATION HISTORY:
%     SAK(22-06-2007) -- Original 
%     SAK(25-09-2007) -- replace minpathmat with Dwei
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [PL stdPL nodeoPL stdnodeoPL nodeiPL stdnodeiPL epochPL stdepochPL D] = PathLengths(x)

  [nodes nodes noepochs] = size(x);
  numdists = nodes.^2 - nodes;
   
 %Calculate the Distance matricies from the connection matricies.
  D = zeros(nodes, nodes, noepochs);
  for m=1:noepochs,
    D(:,:,m) = Dwei(x(:,:,m),nodes);
  end
  
 %Average over epochs to get an Average Distance matrix 
  AvD = sum(D, 3) ./ noepochs; %Octave mean() has a bug...
  %%%stdAvD = std(D,3);
 
 %Average over nodes and epochs to get Path Length, get epoch-wise along the way
 if noepochs>1,
   noself = zeros(noepochs,numdists);
   epochPL = zeros(1,noepochs);
   stdepochPL = zeros(1,noepochs);
   for m=1:noepochs,
     TEMP = D(:,:,m);
     epochPL(1,m) = sum(TEMP(:))./numdists;
     noself(m,:) = TEMP(~eye(size(TEMP))); %remove the diagonal, ie self connections.
     stdepochPL(1,m) = std(noself(m,:));
   end
   PL =  mean(noself(:));
   stdPL = std(noself(:));
 else %Only one epoch/connection matrix
   PL =  sum(D(:))./numdists;
   noself = D(~eye(size(D))); %remove the diagonal, ie self connections.
   stdPL = std(noself);
   epochPL = PL;       %Just assign something so we can get D
   stdepochPL = stdPL; 
 end
  
  %%%???NODE-WISE, SEPARATE IN AND OUT... AVERAGE DISTANCE OF A NODE FROM THE REST OF TEH NETWORK???%%%
  nodeoPL    = zeros(nodes,1);
  stdnodeoPL = zeros(nodes,1);
  nodeiPL    = zeros(nodes,1);
  stdnodeiPL = zeros(nodes,1);
  TEMP = ~eye(size(AvD));
  for n = 1:nodes,
    nodeoPL(n,1)    =  mean(AvD(n,TEMP(n,:)));
    stdnodeoPL(n,1) =  std(AvD(n,TEMP(n,:))); 

    nodeiPL(n,1)    =  mean(AvD(TEMP(n,:),n));
    stdnodeiPL(n,1) =  std(AvD(TEMP(n,:),n)); 
  end

end %function PathLengths()
