%% Convert a TimeSeries plus options structure into a doi structure.
%
% ARGUMENTS:
%           TimeSeries -- (tpts, nodes)
%           NodeStr -- Cell array of short strings labeling nodes. 
%           SampleRate -- time-series sample rate in Hz.
%           t -- time vector in seconds.
%           Epochs -- Number of Epochs to break the time-series into.
%
% OUTPUT: 
%           doi -- A structure containing time-series in a structure I used
%                  used to use for data analysis at BDI. Namely, one field 
%                  for the time-series from each Node|channel|region|etc, plus:
%             .SampleRate -- the sample rate of the data.
%             .t -- time vector in seconds.
%
% USAGE:
%{
      %Assuming you've run something like BRRWtess_eo_O52R00_IRP2008_2s_demo
      NodeStr = options.Connectivity.NodeStr;
      SampleRate = 1000 / options.Integration.dt; %ms->s
      doi = makedoi(Store_phi_e, NodeStr, SampleRate, Store_t/1000.0, 4);

%}
%
% MODIFICATION HISTORY:
%     SAK(<dd-mm-yyyy>) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function doi = makedoi(TimeSeries, NodeStr, SampleRate, t, Epochs)
  [NumberOfTimePoints NumberOfNodes] = size(TimeSeries);
%% Set any argument that weren't specified
  if nargin < 2 || isempty(NodeStr),
    for k=1:NumberOfNodes, NodeStr{k} = num2str(k); end; %index labels
  end
  if nargin < 3,
    msg = 'No sample-rate provided, assuming 1000Hz...';
    warning(['BrainNetwrokModels:PlottingTools:utilities:', mfilename, ':NoSampleRateHz'], msg);
    SampleRate = 1000;
  end
  if nargin >= 4 && ~isempty(t),
    SampleRate = 1.0 / (t(2)-t(1));
  end
  if nargin < 4 || isempty(t),
    t = (1:NumberOfTimePoints)/SampleRate;;
  end
  if nargin == 5,
    %Break into non-overlapping segments, through away excess from front -- tend to have transients there anyway.
    epoch_len = floor(NumberOfTimePoints / Epochs);
    TimeSeries = reshape(TimeSeries((NumberOfTimePoints-(Epochs*epoch_len) +1):end,:), [epoch_len Epochs NumberOfNodes]);
    TimeSeries = permute(TimeSeries,[3 1 2]); %(nodes, time, epochs)
    t = (1:epoch_len) ./ SampleRate;
  else
    Epochs = 1;
    TimeSeries = TimeSeries.';
  end

  doi.SampleRate = SampleRate;
  doi.t = t;
  doi.Epochs = Epochs;
  
  %Clean-up crappy Node Strings for use as structure fields...
  for j = 1:length(NodeStr), 
    NodeStr{j}(NodeStr{j}=='.') = [];
    NodeStr{j}(NodeStr{j}=='-') = '_';
  end
  doi.NodeStr = NodeStr;

%% Construct doi structure
  for j = 1:length(NodeStr),
    if Epochs == 1,
      doi.(NodeStr{j}) = TimeSeries(j,:);
    else
      doi.(NodeStr{j}) = squeeze(TimeSeries(j,:,:)).';
    end
  end

end %function makedoi()