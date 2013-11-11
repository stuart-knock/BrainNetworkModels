%% Return linear indexing based on delay matrix 
%
% ARGUMENTS:
%           delay -- Matrix of time delays 
%           iters -- 
%           maxdelayiters --
%           dt -- integration time step
%
% OUTPUT: 
%           lidelay -- delay in the form of linear indexes to an array that
%                      consists of (iters + maxdelayiters) rows and N
%                      columns, where N is the number of nodes. Indexes are
%                      inverted so that they will count backward from the
%                      current time point.
%
% USAGE:
%{
    lidelay = GetLinearIndex(delay, iters, maxdelayiters, dt);
%}
%
% MODIFICATION HISTORY:
%     SAK(17-09-2009) -- Original.
%     SAK(03-12-2009) -- Changed N to N1,N2 to reuse for vector of
%                        corticothalamic delays...
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function lidelay = GetLinearIndex(delay, iters, maxdelayiters, dt, CouplingVariables)
  if nargin<5,
    CouplingVariables = 1;
  end
  [N1 N2] = size(delay);
  
  %Convert time delays into a integer number of integration steps...(with 0 delay counting as previous time point???)
  idelay = round(delay/dt)+1; 
  
  %Calculate offset required to convert the values idelay into a linear index
  NumberOfRows = iters + maxdelayiters;
  OffsetMatrix = repmat((0:NumberOfRows:(NumberOfRows*(N2-1))), [N1 1]);
  
  %Offset delays and invert them so that they count into the past
  lidelay(1,:,:) = maxdelayiters - idelay + OffsetMatrix; 
  
  %
  if CouplingVariables~=1,
    ElementsInHistory = N2*NumberOfRows;
    for cv = 2:CouplingVariables,
      lidelay(cv,:,:) = lidelay(1,:,:) + (cv-1)*ElementsInHistory;
    end
  else
    lidelay = squeeze(lidelay);
  end

end %function GetLinearIndex()
