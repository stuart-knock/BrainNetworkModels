function hText = xticklabel_rotate(XTick,rot,varargin)
%hText = xticklabel_rotate(XTick,rot,XTickLabel,varargin)     Rotate XTickLabel
%
% Syntax: xticklabel_rotate
%
% Input:    
% {opt}     XTick       - vector array of XTick positions & values (numeric) 
%                           uses current XTick values or XTickLabel cell array by
%                           default (if empty) 
% {opt}     rot         - angle of rotation in degrees, 90� by default
% {opt}     XTickLabel  - cell array of label strings
% {opt}     [var]       - "Property-value" pairs passed to text generator
%                           ex: 'interpreter','none'
%                               'Color','m','Fontweight','bold'
%
% Output:   hText       - handle vector to text labels
%
% Example 1:  Rotate existing XTickLabels at their current position by 90�
%    xticklabel_rotate
%
% Example 2:  Rotate existing XTickLabels at their current position by 45� and change
% font size
%    xticklabel_rotate([],45,[],'Fontsize',14)
%
% Example 3:  Set the positions of the XTicks and rotate them 90�
%    figure;  plot([1960:2004],randn(45,1)); xlim([1960 2004]);
%    xticklabel_rotate([1960:2:2004]);
%
% Example 4:  Use text labels at XTick positions rotated 45� without tex interpreter
%    xticklabel_rotate(XTick,45,NameFields,'interpreter','none');
%
% Example 5:  Use text labels rotated 90� at current positions
%    xticklabel_rotate([],90,NameFields);
%
% Note : you can not re-run xticklabel_rotate on the same graph. 
%
% 


% This is a modified version of xticklabel_rotate90 by Denis Gilbert
% Modifications include Text labels (in the form of cell array)
%                       Arbitrary angle rotation
%                       Output of text handles
%                       Resizing of axes and title/xlabel/ylabel positions to maintain same overall size 
%                           and keep text on plot
%                           (handles small window resizing after, but not well due to proportional placement with 
%                           fixed font size. To fix this would require a serious resize function)
%                       Uses current XTick by default
%                       Uses current XTickLabel is different from XTick values (meaning has been already defined)

% Brian FG Katz
% bfgkatz@hotmail.com
% 23-05-03
% Modified 03-11-06 after user comment
%	Allow for exisiting XTickLabel cell array

% Other m-files required: cell2mat
% Subfunctions: none
% MAT-files required: none
%
% See also: xticklabel_rotate90, TEXT,  SET

% Based on xticklabel_rotate90
%   Author: Denis Gilbert, Ph.D., physical oceanography
%   Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%   email: gilbertd@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%   February 1998; Last revision: 24-Mar-2003

% check to see if xticklabel_rotate has already been here (no other reason for this to happen)
if isempty(get(gca,'XTickLabel')),
    error('xticklabel_rotate : can not process, either xticklabel_rotate has already been run or XTickLabel field has been erased')  ;
end

% if no XTickLabel AND no XTick are defined use the current XTickLabel
%if nargin < 3 & (~exist('XTick') | isempty(XTick)),
if (nargin < 3 || isempty(varargin{1})) & (~exist('XTick') | isempty(XTick)),
	xTickLabels = get(gca,'XTickLabel')  ; % use current XTickLabel
	if ~iscell(xTickLabels)
		% remove trailing spaces if exist (typical with auto generated XTickLabel)
		temp1 = num2cell(xTickLabels,2)         ;
		for loop = 1:length(temp1),
			temp1{loop} = deblank(temp1{loop})  ;
		end
		xTickLabels = temp1                     ;
	end
varargin = varargin(2:length(varargin));	
end

% if no XTick is defined use the current XTick
if (~exist('XTick') | isempty(XTick)),
    XTick = get(gca,'XTick')        ; % use current XTick 
end

%Make XTick a column vector
XTick = XTick(:);

if ~exist('xTickLabels'),
	% Define the xtickLabels 
	% If XtickLabel is passed as a cell array then use the text
	if (length(varargin)>0) & (iscell(varargin{1})),
        xTickLabels = varargin{1};
        varargin = varargin(2:length(varargin));
	else
        xTickLabels = num2str(XTick);
	end
end    

if length(XTick) ~= length(xTickLabels),
    error('xticklabel_rotate : must have same number of elements in "XTick" and "XTickLabel"')  ;
end

%Set the Xtick locations and set XTicklabel to an empty string
set(gca,'XTick',XTick,'XTickLabel','')

if nargin < 2,
    rot = 90 ;
end

% Determine the location of the labels based on the position
% of the xlabel
hxLabel = get(gca,'XLabel');  % Handle to xlabel
xLabelString = get(hxLabel,'String');

% if ~isempty(xLabelString)
%    warning('You may need to manually reset the XLABEL vertical position')
% end

%%%SAK%%%set(hxLabel,'Units','data');
%%%SAK%%%xLabelPosition = get(hxLabel,'Position');
%%%SAK%%%y = xLabelPosition(2);
y = get(gca,'YTick');%SAK
y = y(1)-0.01*(y(end)-y(1));%SAK

%CODE below was modified following suggestions from Urs Schwarz
y=repmat(y,size(XTick,1),1);
% retrieve current axis' fontsize
fs = get(gca,'fontsize');

% Place the new xTickLabels by creating TEXT objects
%%%SAK%%%hText = text(XTick, y, xTickLabels,'fontsize',fs);
hText = text(XTick, y, xTickLabels,'HorizontalAlignment','right','rotation',rot, 'FontSize', get(gca,'FontSize'));%SAK
% Rotate the text objects by ROT degrees
%%%SAK%%%set(hText,'Rotation',rot,'HorizontalAlignment','right',varargin{:})

% Adjust the size of the axis to accomodate for longest label (like if they are text ones)
% This approach keeps the top of the graph at the same place and tries to keep xlabel at the same place
% This approach keeps the right side of the graph at the same place 

%%%SAK%%%set(get(gca,'xlabel'),'units','data')           ;
%%%SAK%%%    labxorigpos_data = get(get(gca,'xlabel'),'position')  ;
%%%SAK%%%set(get(gca,'ylabel'),'units','data')           ;
%%%SAK%%%    labyorigpos_data = get(get(gca,'ylabel'),'position')  ;
%%%SAK%%%set(get(gca,'title'),'units','data')           ;
%%%SAK%%%    labtorigpos_data = get(get(gca,'title'),'position')  ;

%%%SAK%%%set(gca,'units','pixel')                        ;
%%%SAK%%%set(hText,'units','pixel')                      ;
%%%SAK%%%set(get(gca,'xlabel'),'units','pixel')          ;
%%%SAK%%%set(get(gca,'ylabel'),'units','pixel')          ;

%%%SAK%%%origpos = get(gca,'position')                   ;
%%%SAK%%%textsizes = cell2mat(get(hText,'extent'))       ;
%%%SAK%%%longest =  max(textsizes(:,4))                  ;

%%%SAK%%%laborigext = get(get(gca,'xlabel'),'extent')    ;
%%%SAK%%%laborigpos = get(get(gca,'xlabel'),'position')  ;


%%%SAK%%%labyorigext = get(get(gca,'ylabel'),'extent')   ;
%%%SAK%%%labyorigpos = get(get(gca,'ylabel'),'position') ;
%%%SAK%%%leftlabdist = labyorigpos(1) + labyorigext(1)   ;

% assume first entry is the farthest left
%%%SAK%%%leftpos = get(hText(1),'position')              ;
%%%SAK%%%leftext = get(hText(1),'extent')                ;
%%%SAK%%%leftdist = leftpos(1) + leftext(1)              ;
%%%SAK%%%if leftdist > 0,    leftdist = 0 ; end          % only correct for off screen problems

%%%SAK%%%botdist = origpos(2) + laborigpos(2)            ;
%%%SAK%%%newpos = [origpos(1)-leftdist longest+botdist origpos(3)+leftdist origpos(4)-longest+origpos(2)-botdist]  ;
%%%SAK%%%set(gca,'position',newpos)                      ;

% readjust position of nex labels after resize of plot
%%%SAK%%%set(hText,'units','data')                       ;
%%%SAK%%%for loop= 1:length(hText),
%%%SAK%%%    set(hText(loop),'position',[XTick(loop), y(loop)])  ;
%%%SAK%%%end


% adjust position of xlabel and ylabel
%%%SAK%%%laborigpos = get(get(gca,'xlabel'),'position')  ;
%%%SAK%%%set(get(gca,'xlabel'),'position',[laborigpos(1) laborigpos(2)-longest 0])   ;

% switch to data coord and fix it all
%%%SAK%%%set(get(gca,'ylabel'),'units','data')                   ;
%%%SAK%%%set(get(gca,'ylabel'),'position',labyorigpos_data)      ;
%%%SAK%%%set(get(gca,'title'),'position',labtorigpos_data)       ;

%%%SAK%%%set(get(gca,'xlabel'),'units','data')                   ;
%%%SAK%%%    labxorigpos_data_new = get(get(gca,'xlabel'),'position')  ;
%%%SAK%%%set(get(gca,'xlabel'),'position',[labxorigpos_data(1) labxorigpos_data_new(2)])   ;


% Reset all units to normalized to allow future resizing
%%%SAK%%%set(get(gca,'xlabel'),'units','normalized')          ;
%%%SAK%%%set(get(gca,'ylabel'),'units','normalized')          ;
%%%SAK%%%set(get(gca,'title'),'units','normalized')          ;
%%%SAK%%%set(hText,'units','normalized')                      ;
%%%SAK%%%set(gca,'units','normalized')                        ;

if nargout < 1,
    clear hText
end

