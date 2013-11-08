%% <Description>
%
% ARGUMENTS:
%           <arg1> -- <description>
%
% OUTPUT: 
%           <output1> -- <description>
%
% USAGE:
%{
     %Simple regional projection matrix.
      NumberOfRegions = options.Connectivity.NumberOfNodes;
      NumberOfVertices = options.Connectivity.NumberOfVertices;
      Mapping.ProjectionMatrix = spalloc(NumberOfVertices, NumberOfRegions, NumberOfRegions);
      for k=1:NumberOfRegions, 
        ThisRegionVertices = options.Connectivity.RegionMapping==k;
        Mapping.ProjectionMatrix(ThisRegionVertices,k) = 1./sum(ThisRegionVertices); %approx normalise region area 
      end
      Mapping.ProjectionLables = options.Connectivity.NodeStr;

      PlotRegionColouredFFT(TimeSeries, Mapping);
 
%}
%
% MODIFICATION HISTORY:
%     SAK(07-05-2009) -- Original.
%     SAK(02-12-2010) -- Rewrite with "Mapping" structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FigureHandle pY f] = PlotRegionColouredFFT(TimeSeries,Mapping,SampleRateHz)
%% Set defaults for any argument that weren't specified
 if nargin<3,
  disp('No samplerate provided, assuming 500Hz...')
  SampleRateHz = 500;
 end
 
%% Data info 
  NumberOfRegions = size(Mapping.ProjectionMatrix, 2);
  NumberOfTimePoints = size(TimeSeries,1);
 

%% Initialise timeseries
 TimeSeries = TimeSeries * Mapping.ProjectionMatrix;
 TimeSeries  = detrend(TimeSeries);
 
 
%% Segment time series
 NumberOfSegments = floor(NumberOfTimePoints/(2*SampleRateHz));
 if NumberOfSegments<1,
   error(['PlottingTools',mfilename,':NotEnoughData'], 'Expect at least 2 seconds of data...' );
 end
 
 TimeSeries = reshape(TimeSeries((NumberOfTimePoints-(NumberOfSegments*2*SampleRateHz) +1):end,:), [2*SampleRateHz NumberOfSegments NumberOfRegions]);
 TimeSeries = permute(TimeSeries,[3 1 2]);
 
 
%% Calculate FFT
 NFFT = 2^nextpow2(2*SampleRateHz); % Next power of 2 from length of y
 f = SampleRateHz/2*linspace(0,1,NFFT/2);
 Y = fft(TimeSeries,NFFT,2) / NumberOfTimePoints;
 pY = squeeze(sum(Y.*conj(Y), 3));
 
 
 %% Plot it...
 FigureHandle = figure;
  loglog(f,2*(pY(:, 1:NFFT/2)),'LineWidth',1);
  legend(Mapping.ProjectionLables,'Location','NorthEast')
  title(['Single-Sided Power Spectrum of ' inputname(1)], 'interpreter','none')
  xlabel('Frequency (Hz)')
  ylabel('|Y(f)|^2')
 
end  %PlotRegionColouredFFT()
