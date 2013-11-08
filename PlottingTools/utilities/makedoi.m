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
      SampleRate = options.dt;
%}
%
% MODIFICATION HISTORY:
%     SAK(<dd-mm-yyyy>) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function doi=makedoi(X,NodeStr,SampleRate,t,Epochs)
%% Set any argument that weren't specified
 if nargin < 3,
   arg3 = default;
 end
 if nargin < 4,
   arg4 = default;
 end
 
%% Checks...
  [N L ShouldBeOne] = size(X);
 
 %Clean-up crappy Node Strings fro use as structure fields...
  for j = 1:length(NodeStr), 
    NodeStr{j}(NodeStr{j}=='.') = [];
    NodeStr{j}(NodeStr{j}=='-') = '_';
  end

%% Construct doi structure
 for j = 1:length(NodeStr), 
   doi.(NodeStr{j}) = X(j,:);
 end

 doi.SampleRate = SampleRate;

 if nargin>3,
   doi.t = t;
 else
   doi.t = (1:L)/SampleRate;
 end

%% 

end %function 