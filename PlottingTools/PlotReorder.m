%% <Description>
%
% ARGUMENTS:
%           <arg1> -- <description>
%
% OUTPUT: 
%           <output1> -- <description>
%
% REQUIRES:
%        GetOrder() --
%        imrotateticklabel() -- 
%        xticklabel_rotate() --
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(09-03-2009) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO: Don't remember exactly what this was for, also can't find the function
%      GetOrder()... Search some more, if it can't be found then dump this function.

function FigureHandle = PlotReorder(Xp,Xo,OrderBy,NodeStr)
%%
  [PlotNodesI PlotNodesO] = size(Xp);
  [OrderNodesI OrderNodesO] = size(Xo);

%%    
  if OrderNodesI==OrderNodesO,
    Order = GetOrder(Xo,OrderBy);
  else
    [temp Order] = sort(Xo);
  end
  
  if PlotNodesI == PlotNodesO,
    FigureHandle = imagesc(Xp(Order,Order));
    if nargin>3, % NodeStr was provided
      set(gca,'XTick', 1:length(Order));
      set(gca,'YTick', 1:length(Order));
      set(gca,'XTickLabel', NodeStr(Order));
      set(gca,'YTickLabel', NodeStr(Order));
      imrotateticklabel(gca,90);
    end
  
  else
    FigureHandle = plot(Xp(Order,:));
    if nargin>3, % NodeStr was provided
      set(gca,'XTick', 1:length(Order));
      set(gca,'XTickLabel', NodeStr(Order));
      xticklabel_rotate([],90);
    end
  end
  
  if OrderNodesI == OrderNodesO,
    title([inputname(1) ' Sorted by ' OrderBy ' of '  inputname(2)], 'Interpreter','none')
  else
    title([inputname(1) ' Sorted by ' inputname(2)], 'Interpreter','none')
  end

end %function PlotReorder()
