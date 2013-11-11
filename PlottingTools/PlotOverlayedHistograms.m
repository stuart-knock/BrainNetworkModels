%% Over-plots histograms for multiple data sets.
%
% ARGUMENTS:
%           Data -- A cell array of vectors containing the data to be displayed.
%           NumberOfBins -- Number of bins to use for the histogram [default 100]
%           DataLabels -- A cell array of short strings to identify each dataset.
%                         [default index, ie 1,2,3,etc] 
%           Normalise -- Binary of whether to normalise or not. [default False] 
%
% OUTPUT: 
%           HistObjHandles -- Cell array of handles to each of the hist objects.
%           FigureHandle -- A handle for the figure.
%
%
% REQUIRES:
%         none
%
% USAGE:
%{
      DataLabels = {'for_Vik_July11', 'O52R00_IRP2008', 'DSI_enhanced', 'RM_AC'};
      
      for k = 1:length(DataLabels),
        Connectivity.WhichMatrix = DataLabels{k};
        Connectivity = GetConnectivity(Connectivity);
        Data{k} = Connectivity.delay(Connectivity.delay(:)~=0);
        clear Connectivity
      end
      
      %Overlay delay distributions for 4 of our Connectivities.
      [HistObjHandles FigureHandle] = PlotOverlayedHistograms(Data, 50, DataLabels);

%}
%
% MODIFICATION HISTORY:
%     SAK(27-10-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [HistObjHandles FigureHandle] = PlotOverlayedHistograms(Data, NumberOfBins, DataLabels, Normalise)
%% Set any argument that weren't specified to default values
  
  NumberOfDatasets = length(Data);

  if nargin < 2,
    NumberOfBins = 100; %
  end
  if nargin < 3,
    for k=1:NumberOfDatasets, DataLabels{k} = num2str(k); end; %index labels
  end
  if nargin < 4,
    Normalise = false; %
  end

%% Optionally normalise
  if Normalise,
    Data = cellfun(@(x) x./mean(x(:)), Data, 'UniformOutput',false);
  end
  
  minD = min(cellfun(@(x) min(x(:)), Data));
  maxD = max(cellfun(@(x) max(x(:)), Data));
  stepD = (maxD-minD)/NumberOfBins;

%% Get Histograms
  HistorgamObjects = cell(size(Data));
  for k = 1:NumberOfDatasets,
    HistorgamObjects{k} = hist(Data{k}, stepD:stepD:maxD);
  end

%% Plot them
  FigureHandle = figure;
  hold on
  for k = 1:NumberOfDatasets,
    bar(stepD:stepD:maxD, HistorgamObjects{k}, 1);
  end
  HistObjHandles = findobj(gca,'Type','patch');
  HistObjHandles = HistObjHandles(end:-1:1);
  
  if Normalise,
    title(['Normalised ' inputname(1)]);
  else
    title(inputname(1));
  end
  
  legend(HistObjHandles, DataLabels)
  

%% Change colours
  for k = 1:NumberOfDatasets,
    %ThisColour = k./(NumberOfDatasets+1); %DarkToLight
    ThisColour = (NumberOfDatasets-k)./(NumberOfDatasets); %LightToDark
    set(HistObjHandles(k),                                                  ...
        'FaceColor', [ThisColour ThisColour ThisColour+1/NumberOfDatasets], ...
        'EdgeColor', [ThisColour ThisColour ThisColour+1/NumberOfDatasets], ...
        'FaceAlpha', 0.75 / NumberOfDatasets, 'EdgeAlpha', 0.0)
  end 
  hold off

end %function PlotOverlayedHistograms()
