%% Calculate Weighted Degrees (In, Out, and Total), mean, node-wise, and epoch-wise.
%
%  Connections are out of a row and into a column... from node 1->2 is x(1,2)
%
%  ARGUMENTS:
%    x[nodes,nodes,noepochs] -- A 3-D array of noepochs connectivity matricies,
%                               larger value = stronger connection. 
%
%
%  OUTPUTS:
%    In          [nodes, epochs] -- Array if weighted in degrees per node and epoch
%    Out         [nodes, epochs] -- Array if weighted out degrees per node and epoch
%    stdIn       [nodes, epochs] -- Standard deviation of In
%    stdOut      [nodes, epochs] -- Standard deviation of Out
%    nodeIn      [nodes, 1]      -- Weighted in degree per node, averaged over epochs.
%    stdnodeIn   [nodes, 1]      -- Standard deviation of nodeIn
%    nodeOut     [nodes, 1]      -- Weighted out degree per node, averaged over epochs.
%    stdnodeOut  [nodes, 1]      -- Standard deviation of nodeOut
%    epochIn     [1, epochs]     -- Weighted in degree per epoch, averaged over nodes.
%    stdepochIn  [1, epochs]     -- Standard deviation of epochIn
%    epochOut    [1, epochs]     -- Weighted out degree per epoch, averaged over nodes.
%    stdepochOut [1, epochs]     -- Standard deviation of epochOut
%
%
% REQUIRES: 
%          none 
%
% USAGE:
%{
      %See ../PlottingTools/PlotGraphMetrics.m
%}
%
%
% MODIFICATION HISTORY:
%     SAK(22-06-2007) -- Original
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO: Should add conditional evaluation with if nargout > ...

function [In Out stdIn stdOut nodeIn stdnodeIn nodeOut stdnodeOut ...
          epochIn stdepochIn epochOut stdepochOut] = Degrees(x)
  
  [nodes nodes noepochs] = size(x);
  if (nargout>4) && (noepochs==1),
    msg = 'Input is only a single graph but you''ve asked for node-wise epoch-wise output...';
    error(strcat('BrainNetworkModels:','Metrics:',mfilename,':IncompatInOut'), msg);
  end
  
  %Weighted in and out degree arrays, [nodes, epochs].
  In  = squeeze(sum(x,1));
  stdIn = squeeze(std(x,0,1));
  
  Out = squeeze(sum(x,2));
  stdOut = squeeze(std(x,0,2));
  
  if noepochs ~= 1, 
    %Average over epochs to get node-wise in and out degree.
    nodeIn = mean(In,2);
    stdnodeIn = std(In,0,2);
    
    nodeOut = mean(Out,2);
    stdnodeOut = std(Out,0,2);
    
    %Average over nodes to get epoch-wise in and out degree.
    epochIn = mean(In,1);
    stdepochIn = std(In,0,1);
    
    epochOut = mean(Out,1);
    stdepochOut = std(Out,0,1);
  else
    In  = In.';
    stdIn = stdIn.';
  end

end %function Degrees()
