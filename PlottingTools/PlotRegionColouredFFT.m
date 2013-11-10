%% Plot FFT of a TimeSeries Mapped into a set of regions.
%
% ARGUMENTS:
%           TimeSeries -- (tpts, nodes)
%           Mapping -- From nodes to time-series you want to display,
%                      a simple subset, a region averaging, or 
%                      TODO: more complex mappings such as EEG/MEG/etc...
%           SampleRateHz -- TimeSeries sample rate in Hz.
%
% OUTPUT: 
%           FigureHandle -- A handle for the figure.
%           pY -- power spectrum.
%           f -- frequency vector.
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
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [FigureHandle pY f] = PlotRegionColouredFFT(TimeSeries, Mapping, SampleRateHz)
%% TimeSeries info
  [NumberOfTimePoints NumberOfNodes] = size(TimeSeries);

%% Set defaults for any argument that weren't specified
  if nargin<2,
    msg = 'No Mapping was provided, if this is a surface time-series this''ll get ugly';
    warning(['BrainNetwrokModels:PlottingTools', mfilename, ':NoMapping'], msg);
    Mapping.ProjectionMatrix = speye(NumberOfNodes);
    for k=1:NumberOfNodes, Mapping.ProjectionLables{k} = num2str(k); end; %index labels
  end
  if nargin<3,
    msg = 'No sample-rate provided, assuming 1000Hz...';
    warning(['BrainNetwrokModels:PlottingTools', mfilename, ':NoSampleRateHz'], msg);
    SampleRateHz = 1000;
  end

%% Projecting to 
  NumberOfRegions = size(Mapping.ProjectionMatrix, 2);

%% Initialise timeseries
  TimeSeries = TimeSeries * Mapping.ProjectionMatrix;
  TimeSeries = detrend(TimeSeries);

%% Segment time series
  NumberOfSegments = floor(NumberOfTimePoints/(2*SampleRateHz)); %2 second segments => 0.5Hz resolution.
  if NumberOfSegments<1,
    error(['PlottingTools',mfilename,':NotEnoughData'], 'Expect at least 2 seconds of data...' );
  end
  
  %Break into non-overlapping segments, through away excess from front -- tend to have transients there anyway.
  TimeSeries = reshape(TimeSeries((NumberOfTimePoints-(NumberOfSegments*2*SampleRateHz) +1):end,:), [2*SampleRateHz NumberOfSegments NumberOfRegions]);
  TimeSeries = permute(TimeSeries,[3 1 2]); %(regions, time, segments)
 
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
