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
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(09-03-2009) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
 
%%

end %function PlotReorder()