%% Calculate Clustering Coefficients for a set of graphs 'x' and average them
% in the possible ways. See notes in weiCC regarding definition of Weighted 
% Directed Clustering Coefficient.
% 
%
%  ARGUMENTS:
%    x[nodes,nodes,noepochs] -- A 3-D array of noepochs connectivity matricies, 
%                               larger value = stronger connection. 
%
%
%  OUTPUTS: (CC => Clustering Coefficients)
%     CC[nodes,noepochs]   -- Array of Total CC
%     oCC[nodes,noepochs]  -- Array of Output CC
%     iCC[nodes,noepochs]  -- Array of Input CC
%     fbCC[nodes,noepochs] -- Array of Feed-Back CC
%     maCC[nodes,noepochs] -- Array of           CC
%
%     meanCC      -- Mean Total CC
%     meanoCC     -- Mean Output CC
%     meaniCC     -- Mean Input CC
%     meanfbCC    -- Mean Feed-Back CC
%     meanmaCC    -- Mean           CC
%     stdmeanCC   -- Standard deviation of the Mean Total CC
%     stdmeanoCC  -- Standard deviation of the Mean Output CC
%     stdmeaniCC  -- Standard deviation of the Mean Input CC
%     stdmeanfbCC -- Standard deviation of the Mean Feed-Back CC
%     stdmeanmaCC -- Standard deviation of the Mean           CC
%
%  If there is only one graph(epoch) then nodeCC == CC, etc, and epochCC == meanCC, etc  
%
%     nodeCC      -- Node-wise Total CC
%     nodeoCC     -- Node-wise Output CC
%     nodeiCC     -- Node-wise Input CC
%     nodefbCC    -- Node-wise Feed-Back CC
%     nodemaCC    -- Node-wise           CC
%     stdnodeCC   -- Standard deviation of the Node-wise Total CC
%     stdnodeoCC  -- Standard deviation of the Node-wise Output CC
%     stdnodeiCC  -- Standard deviation of the Node-wise Input CC
%     stdnodefbCC -- Standard deviation of the Node-wise Feed-Back CC
%     stdnodemaCC -- Standard deviation of the Node-wise           CC
%
%     epochCC       -- Epoch-wise Total  CC
%     epochoCC      -- Epoch-wise Output CC
%     epochiCC      -- Epoch-wise Input  CC
%     epochfbCC     -- Epoch-wise Feed-Back CC
%     epochmaCC     -- Epoch-wise           CC
%     stdepochCC    -- Standard deviation of the Epoch-wise Total  CC
%     stdepochoCC   -- Standard deviation of the Epoch-wise Output CC
%     stdepochiCC   -- Standard deviation of the Epoch-wise Input  CC
%     stdepochfbCC  -- Standard deviation of the Epoch-wise Feed-Back CC
%     stdepochfmaCC -- Standard deviation of the Epoch-wise           CC
%
%
% REQUIRES: 
%          weiCC() -- Computes cluster index of a weighted directed graph.
%
% USAGE:
%{
      %See ../PlottingTools/PlotGraphMetrics.m
%}
%
%
% MODIFICATION HISTORY:
%     SAK(22-06-2007) -- Original... Modified/Amalgamated from redudndant
%                                    implementation in GraphMetrics_1.2.
%                                    Functional change is the move from
%                                    clustind to weiCC for CC calculations 
%                                    and return std again rather than sem,
%                                    sem can be calculated in plotting.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [CC oCC iCC fbCC  maCC                                                                                     ...
          meanCC  meanoCC  meaniCC  meanfbCC  meanmaCC  stdmeanCC  stdmeanoCC  stdmeaniCC  stdmeanfbCC  stdmeanmaCC ...
          nodeCC  nodeoCC  nodeiCC  nodefbCC  nodemaCC  stdnodeCC  stdnodeoCC  stdnodeiCC  stdnodefbCC  stdnodemaCC ... 
          epochCC epochoCC epochiCC epochfbCC epochmaCC stdepochCC stdepochoCC stdepochiCC stdepochfbCC stdepochmaCC] = ClusteringCoefficients(x)

  [nodes nodes noepochs] = size(x);
  if (nargout>15) && (noepochs==1),
    msg = 'Input is only a single graph but you''ve asked for node-wise epoch-wise output...';
    error(strcat('BrainNetworkModels:','Metrics:',mfilename,':IncompatInOut'), msg);
  end
  
  CC   = zeros(nodes, noepochs);
  oCC  = zeros(nodes, noepochs);
  iCC  = zeros(nodes, noepochs);
  fbCC = zeros(nodes, noepochs);
  maCC = zeros(nodes, noepochs);
  
  for m=1:noepochs,
    [CC(:,m) oCC(:,m) iCC(:,m) fbCC(:,m) maCC(:,m)] = weiCC(x(:,:,m));
  end

  if nargout>5,
    meanCC    = mean(CC(:));
    meanoCC   = mean(oCC(:));
    meaniCC   = mean(iCC(:));
    meanfbCC  = mean(fbCC(:));
    meanmaCC  = mean(maCC(:));
    stdmeanCC   = std(CC(:));
    stdmeanoCC  = std(oCC(:));
    stdmeaniCC  = std(iCC(:));
    stdmeanfbCC = std(fbCC(:));
    stdmeanmaCC = std(maCC(:));

    if noepochs>1, %not looking at a single graph...
     %Average over epochs to get node-wise CC
      nodeCC    = mean(CC,  2);
      nodeoCC   = mean(oCC, 2);
      nodeiCC   = mean(iCC, 2);
      nodefbCC  = mean(fbCC,2);
      nodemaCC  = mean(maCC,2);
      stdnodeCC   = std(CC,  0, 2);
      stdnodeoCC  = std(oCC, 0, 2);
      stdnodeiCC  = std(iCC, 0, 2);
      stdnodefbCC = std(fbCC,0, 2);
      stdnodemaCC = std(maCC,0, 2);

     %Average over nodes to get epoch-wise CC
      epochCC   = mean(CC,   1);
      epochoCC  = mean(oCC,  1);
      epochiCC  = mean(iCC,  1);
      epochfbCC = mean(fbCC, 1);
      epochmaCC = mean(maCC, 1);
      stdepochCC   = std(CC,   0, 1);
      stdepochoCC  = std(oCC,  0, 1);
      stdepochiCC  = std(iCC,  0, 1);
      stdepochfbCC = std(fbCC, 0, 1);
      stdepochmaCC = std(maCC, 0, 1);
    end
  end %if means wanted
  
end %function ClusteringCoefficients()
