function [thx thy]=imrotateticklabel(h,rot,demo)
%ROTATETICKLABEL rotates tick labels
%   TH=ROTATETICKLABEL(H,ROT) is the calling form where H is a handle to
%   the axis that contains the XTickLabels that are to be rotated. ROT is
%   an optional parameter that specifies the angle of rotation. The default
%   angle is 90. TH is a handle to the text objects created. For long
%   strings such as those produced by datetick, you may have to adjust the
%   position of the axes so the labels don't get cut off.
%
%   Of course, GCA can be substituted for H if desired.
%
%   TH=ROTATETICKLABEL([],[],'demo') shows a demo figure.
%
%   Known deficiencies: if tick labels are raised to a power, the power
%   will be lost after rotation.
%
%   See also datetick.

%   Written Oct 14, 2005 by Andy Bliss
%   Copyright 2005 by Andy Bliss

%DEMO:
if nargin==3
    x=[now-.7 now-.3 now];
    y=[20 35 15];
    figure
    plot(x,y,'.-')
    datetick('x',0,'keepticks')
    h=gca;
    set(h,'position',[0.13 0.35 0.775 0.55])
    rot=90;
end

%set the default rotation if user doesn't specify
if nargin==1
    rot=90;
end
%make sure the rotation is in the range 0:360 (brute force method)
while rot>360
    rot=rot-360;
end
while rot<0
    rot=rot+360;
end
%get current tick labels
a=get(h,'XTickLabel');
e=get(h,'YTickLabel');
%erase current tick labels from figure
set(h,'XTickLabel',[]);
set(h,'YTickLabel',[]);
%get tick label positions
b=get(h,'XTick');
c=get(h,'YTick');
%where are xlabels 
d = get(gca,'XAxisLocation');
%make new tick labels
switch d,
  case 'bottom'
    if rot<180
      thx=text(b,repmat(c(end)+1.3*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','right','rotation',rot, 'FontSize', get(gca,'FontSize'));
    else
      thx=text(b,repmat(c(end)+1.3*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','left','rotation',rot, 'FontSize', get(gca,'FontSize'));
    end
  case 'top'
    if rot<180
        thx=text(b,repmat(c(1)-1.3*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','left','rotation',rot, 'FontSize', get(gca,'FontSize'));
    else
        thx=text(b,repmat(c(1)-1.3*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','right','rotation',rot, 'FontSize', get(gca,'FontSize'));
    end
end


%where are xlabels 
f = get(gca,'YAxisLocation');
%make new tick labels
switch f,
  case 'left'
    thy=text(repmat(b(1)-1.3*(b(2)-b(1)),length(c),1),c,e,'HorizontalAlignment','right','FontSize', get(gca,'FontSize'));
  case 'right'
    thy=text(repmat(b(end)+1.3*(b(2)-b(1)),length(c),1),c,e,'HorizontalAlignment','left','FontSize', get(gca,'FontSize'));
end

return



