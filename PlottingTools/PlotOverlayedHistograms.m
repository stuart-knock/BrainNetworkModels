%% <Description>
%
% ARGUMENTS:
%           Data -- <description>
%           NumberOfBins -- <description>
%           DataLabels -- <description>
%           Normalise -- <description>
%
% OUTPUT: 
%           <output1> -- <description>
%
%
% REQUIRES:
%         none
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(27-10-2010) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [HistObjHandles FigureHandle] = PlotOverlayedHistograms(Data,NumberOfBins,DataLabels,Normalise)
%% Set any argument that weren't specified
 if nargin < 2,
    NumberOfBins = 100; %
 end
 if nargin < 4,
    Normalise = false; %
 end
 
 NumberOfDatasets = length(Data);
 
%% 
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
 
  if nargin > 2,
    legend(HistObjHandles, DataLabels)
  end
  
%% Change colours
  for k = 1:NumberOfDatasets,
    %ThisColour = k./(NumberOfDatasets+1); %DarkToLight
    ThisColour = (NumberOfDatasets-k)./(NumberOfDatasets); %LightToDark
    set(HistObjHandles(k), 'FaceColor', [ThisColour ThisColour ThisColour], 'EdgeColor', [ThisColour ThisColour ThisColour])
  end
 
  
end %function PlotOverlayedHistograms()
