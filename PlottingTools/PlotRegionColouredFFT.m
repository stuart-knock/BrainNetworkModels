%% Plot FFT of a TimeSeries Mapped into a set of regions and coloured accordingly.
%
% ARGUMENTS:
%         TimeSeries -- (tpts, nodes)
%         time -- Assume ms: Either dt or a vector of time values, with length = tpts.
%         Mapping -- From nodes to time-series you want to display,
%                    a simple subset, a region averaging, or 
%                    TODO: more complex mappings such as EEG/MEG/etc...
%         SampleRateHz -- TimeSeries sample rate in Hz.
%
% OUTPUT:
%         FigureHandle -- A handle for the figure.
%         pY -- power spectrum.
%         f -- frequency vector.
%
% REQUIRES: 
%         none
%
% USAGE:
%{
    %Assuming you've just run BRRWtess_eo_O52R00_IRP2008_2s_demo
    addpath(genpath('./PlottingTools'))
    Mapping = mapping_to_regions(options);

    [FigureHandle pY f] = PlotRegionColouredFFT(Store_phi_e, Store_t, Mapping);
 
%}
%
% MODIFICATION HISTORY:
%     SAK(07-05-2009) -- Original.
%     SAK(02-12-2010) -- Rewrite with "Mapping" structure.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [FigureHandle pY f] = PlotRegionColouredFFT(TimeSeries, time, Mapping)
%% TimeSeries info
  [NumberOfTimePoints NumberOfNodes] = size(TimeSeries);
  
  if nargin < 2 || isempty(time),
    msg = 'No time-scale was provided, defaulting to 1000Hz, frequencies will be rescaled accordingly.';
    warning(['BrainNetwrokModels:PlottingTools', mfilename, ':NoTimeScale'], msg);
    SampleRateHz = 1000.0;
  else
    if length(time) == 1, % assume it's dt
      SampleRateHz = 1000.0 / time;
    else
    SampleRateHz = 1000.0 / (time(2) - time(1));
    end
  end

%% Set defaults for any argument that weren't specified
  if nargin<3,
    msg = 'No Mapping was provided, if this is a surface time-series this''ll get ugly';
    warning(['BrainNetwrokModels:PlottingTools', mfilename, ':NoMapping'], msg);
    Mapping.ProjectionMatrix = speye(NumberOfNodes);
    for k=1:NumberOfNodes, Mapping.ProjectionLables{k} = num2str(k); end; %index labels
  end

%% Projecting to 
  NumberOfRegions = size(Mapping.ProjectionMatrix, 2);

%% Initialise timeseries
  TimeSeries = TimeSeries * Mapping.ProjectionMatrix;
  TimeSeries = detrend(TimeSeries);

%% Segment time series
  %2 second segments => 0.5Hz FFT resolution...\/
  NumberOfSegments = floor(NumberOfTimePoints/(2.0*SampleRateHz));
  if NumberOfSegments<1,
    msg = 'Expect at least 2 seconds of data...';
    error(['PlottingTools',mfilename,':NotEnoughData'], msg);
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
