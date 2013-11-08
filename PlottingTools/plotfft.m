%% <Description>
%
% ARGUMENTS:
%           x [Segments, Timepoints]-- Times series
%           sr -- Sample rate per second
%
% OUTPUT: 
%           <output1> -- <description>
%
% USAGE:
%{
      [Y,f]=plotfft(x,sr);
%}
%
% MODIFICATION HISTORY:
%     SAK(<dd-mm-yyyy>) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Y,f]=plotfft(x,sr)
%% Set any argument that weren't specified
% % %  if nargin < 3,
% % %    arg3 = default;
% % %  end
% % %  if nargin < 4,
% % %    arg4 = default;
% % %  end

%% 
[~, L] = size(x);  %[NumberOfSements, LengthOfTimeseries]
NFFT = 2^nextpow2(L); % Next power of 2 from length of y

%%%wndw = hamming(L).'; % Create a hamming window   %ones(1,L);
x = detrend(x.').'; % Remove any linear trend from the data
%%%x = x .* repmat(wndw,[NumberOfSements 1]); % Window the time series data...

figure, 
  plot((1:size(x,2))./sr, x.')
  xlabel('time (s)')
  
Y = fft(x,NFFT,2)/L;
f = sr/2*linspace(0,1,NFFT/2);

mY = mean(abs(Y),1);
stdY = std(2*abs(Y),0,1);
semY = stdY./sqrt(size(x,1));

%%  Plot single-sided amplitude spectrum.
figure,
plot(f,2*(mY(1:NFFT/2)),'LineWidth',2)                        %Mean
hold on
  plot(f,2*(mY(1:NFFT/2))+(semY(1:NFFT/2)./mY(1:NFFT/2)),':') %SEM 
  plot(f,2*(mY(1:NFFT/2))-(semY(1:NFFT/2)./mY(1:NFFT/2)),':') %SEM
  plot(f,2*(mY(1:NFFT/2))+(stdY(1:NFFT/2)),'--')              %STD
  plot(f,2*(mY(1:NFFT/2))-(stdY(1:NFFT/2)),'--')              %STD
hold off
title(['Single-Sided Amplitude Spectrum of ' inputname(1)])
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
legend({'Mean' 'SEM' 'SEM' 'STD' 'STD'})

end %function 