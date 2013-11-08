%% Displays doi original data + Power spectrum one segment at a time,
%% overlayed on Average over epochs/segments
% 
% Plots power spectrum, 
% and plots the original data for given channels below. Multiple channels 
% can be displayed for each dnn* segment, these are stepped through by 
% pressing  Enter, the number of channels stepped through by pressing Enter 
% can be changed at any time, with the default being 1 and -ve numbers 
% stepping backward. 
% Subsequent segements are also displayed by pressing Enter.
%
% At least one channel of original data must be displayed for each dnn*
% segment. The number of dnn* segments and the number of doi segments
% must be equal.
%
% ARGUMENTS:
%           doi           -- structure containing the original data from which dnn* was calculated. 
%                            Must be in standard doi-type EEG structure.
%           figureNum     -- index of figure window into which to plot
%           segNum        -- vector of dnn* segments to display 
%           datastr       -- cell array of EEG channel names. The original
%                            data of these channels will be plotted.
%
% USAGE:
%{
   %Generate some data
    ThisMatrix = 'O52R00_IRP2008';
    [weights delay NodeStr] = GetConnectivity(ThisMatrix);
    [V W t] = fhn_net_rk(weights,delay);

   %Put it in doi structure format
    doi = makedoi(...)
    segNum = 1:Epochs;
    figureNum = 666;
    inspectdoi(doi, figureNum, segNum, NodeStr);
%}
%
% MODIFICATION HISTORY:
%     AJL (Nov-2006) -- Original
%     SAK(24-11-2006) -- Slight modifications: generalised for all dnn*; colourmap; ranges; forward & backward; comments.
%     SAK(12-07-2007) -- Modified from inspectdnn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%NEED AVERAGE OVER CHANNELS AS WELL AS INDIVIDUAL CHANNELS...

function inspectdoi(doi, figureNum, segNum,  datastr)

SigRange = max(doi.(datastr{1})(:))-min(doi.(datastr{1})(:));
SigAmpMin = -(SigRange*1.2)/2;
SigAmpMax = (SigRange*1.2)/2;

%% Create figure window
 figure(figureNum);
 set(figureNum,'Position',[200,40,900,900]);
 
%% Calculate PowerSpectra
%%%NEED TO CONSIDER WINDOWING FOR THIS...
for chan = 1:length(datastr),
  [Epochs DataPoints] = size(doi.(datastr{chan}));
  Bits = DataPoints ./ doi.SampleRate;
  Overlap = Bits - floor(Bits);
  Bits = ceil(Bits);
  Overlap = floor((Overlap.*doi.SampleRate) ./ (Bits -1));
  StartPoints = 1;
  for ThisBit = 2:Bits-1,
    StartPoints = [StartPoints ((StartPoints(ThisBit-1)+doi.SampleRate-1-Overlap) )];
  end
  StartPoints = [StartPoints (DataPoints - doi.SampleRate +1)];
  pwr = zeros(Epochs,doi.SampleRate);
  for ThisBit = 1:Bits,
    pwr = pwr + abs(fft(detrend(doi.(datastr{chan})(:,StartPoints(ThisBit):(StartPoints(ThisBit)+doi.SampleRate-1))), [], 2)).^2;
  end
  pwr = pwr ./ Bits;
  PowerSpectrum.(datastr{chan}) = pwr(:,1:doi.SampleRate/2);
  AvgPowerSpectrum.(datastr{chan}) = mean(PowerSpectrum.(datastr{chan}),1);
  semPowerSpectrum.(datastr{chan}) = std(PowerSpectrum.(datastr{chan}),[],1)./ sqrt(size(PowerSpectrum.(datastr{chan}),1));
end
f = 0:(doi.SampleRate/2 -1);
 
%% Allow forward and backward steping over epochs and channels
 direction = 1;
 chan = 1;
 while (chan >= 1) && (chan <= length(datastr)),
   
%% Plot background averages for this channel
   subplot('position',[0.05 0.3 0.9 0.65])
   ThisChnlAvgPwr = loglog(f,AvgPowerSpectrum.(datastr{chan}),'LineWidth',2);
   axis([f(1) f(end) 10.^(-1) 10.^6]);
   xlabel('Frequency(Hz)');
   ylabel('Power()');
   title(datastr{chan}, 'interpreter', 'none');
   hold on
     ThisChnlAvgPwrSemUp = loglog(f,AvgPowerSpectrum.(datastr{chan})+semPowerSpectrum.(datastr{chan}),':','LineWidth',0.5);
     ThisChnlAvgPwrSemDwn = loglog(f,AvgPowerSpectrum.(datastr{chan})-semPowerSpectrum.(datastr{chan}),':','LineWidth',0.5);
   hold off 
 
   subplot('position',[0.1 0.05 0.8 0.15])
   ThisChnlERP = plot(doi.t, mean(detrend(doi.(datastr{chan})),1), 'LineWidth',2);
   axis([doi.t(1) doi.t(end) SigAmpMin SigAmpMax]);
   xlabel('time(ms)');
   ylabel('potential(arb)');
   title(datastr{chan}, 'interpreter', 'none');
  
%% Plot associated original time-series
   if direction > 0,
     epoch = 1;
   elseif direction < 0,
     epoch = length(segNum);
   end
   while (epoch >= 1) && (epoch <= length(segNum)),
    %Plot this epoch
     subplot('position',[0.05 0.3 0.9 0.65])
     hold on
     ThisChnlPwr = loglog(f,PowerSpectrum.(datastr{chan})(epoch,:),'k','LineWidth',1);
     hold off
     title([datastr{chan} ' ' ' Epoch Number:' num2str(epoch)], 'interpreter', 'none');

     subplot('position',[0.1 0.05 0.8 0.15])
     hold on
     ThisEpochTS = plot(doi.t, detrend(doi.(datastr{chan})(epoch,:)),'k','LineWidth',1);
     hold off
     title([datastr{chan} ' ' ' Epoch Number:' num2str(epoch)], 'interpreter', 'none');
     home
     newdirection = input(['Current scroll direction is ' num2str(direction) ', select new direction [Next = 1; Previous = -1]: ']);
     if ~isempty(newdirection),
       direction = newdirection;
     end
     epoch = epoch+direction;
    %clear previous epoch plots 
     delete(ThisChnlPwr);
     delete(ThisEpochTS);
   end
   chan = chan+sign(direction);
  %Clear previous channel Average plots
   delete(ThisChnlAvgPwr)
   delete(ThisChnlAvgPwrSemUp)
   delete(ThisChnlAvgPwrSemDwn)
   delete(ThisChnlERP)
 end

 close(figureNum);

end %function

%%%EoF%%%