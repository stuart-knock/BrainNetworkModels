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
      
%}
%
% MODIFICATION HISTORY:
%     SAK(09-04-2009) -- Original.
%     SAK/ARM(07-05-2009) -- Rest State Network grouping for DSI matrix added.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Regions = GroupRegions(Metric,Index,NodeStr,ThisMatrix,options)
 
 if nargin<5
   options.GroupBy = 'RestStateNetwork';
 else
   if ~isfield(options,'GroupBy'), 
     options.GroupBy = 'RestStateNetwork'; 
   end
 end
 
 N = length(NodeStr);
 
 switch ThisMatrix,
   case {'RM_AC'}
     Regions.PreFrontal = zeros(N,1);
     Regions.Parietal   = zeros(N,1);
     Regions.Cingulate  = zeros(N,1);
     Regions.Visual     = zeros(N,1);
     Regions.AllOther   = zeros(N,1);

     for j = 1:N,
       switch lower(NodeStr{j}(1:2)), %first two characters of the NodeStr
         case {'pf'},
           Regions.PreFrontal(Index==j) = Metric(j);
         case {'pc'},
           Regions.Parietal(Index==j)   = Metric(j);
         case {'cc'},
           Regions.Cingulate(Index==j)  = Metric(j);
         case {'va', 'v1', 'v2',},
           Regions.Visual(Index==j)     = Metric(j);
         otherwise
           Regions.AllOther(Index==j)   = Metric(j);
       end
     end
  
   case  {'for_Vik_July11'}
     switch lower(options.GroupBy)
       case {'hemisphere'}
         Regions.Left  = zeros(N,1);
         Regions.Right = zeros(N,1);

         for j = 1:N,
           switch lower(NodeStr{j}(1)), %first character of the NodeStr
             case {'l'},
               Regions.Left(Index==j)     = Metric(j);
             case {'r'},
               Regions.Right(Index==j)    = Metric(j);
             otherwise
               Regions.AllOther(Index==j) = Metric(j);
           end
         end

       case {'reststatenetwork'}
         Regions.PreFrontal = zeros(N,1);
         Regions.Parietal   = zeros(N,1);
         Regions.Cingulate  = zeros(N,1);
         Regions.Visual     = zeros(N,1);
         Regions.AllOther   = zeros(N,1);
         for j = 1:N,
           switch lower(NodeStr{j}(2:end)),
             case {'cmf', 'fp', 'lof','mof', 'pope', 'pob',  'pti', 'mf', 'sf'},
               Regions.PreFrontal(Index==j) = Metric(j);
             case {'ip', 'pcun', 'sp'},
               Regions.Parietal(Index==j)   = Metric(j);
             case {'cac', 'istc', 'pc', 'ac'},
               Regions.Cingulate(Index==j)  = Metric(j);
             case {'cun', 'locc', 'ling', 'pcal'},
               Regions.Visual(Index==j)     = Metric(j);
             otherwise
               Regions.AllOther(Index==j)   = Metric(j);
           end
         end
     end
     
  
   case  {'O52R00_IRP2008'}
     switch lower(options.GroupBy)
       case {'hemisphere'}
         Regions.Left  = zeros(N,1);
         Regions.Right = zeros(N,1);

         for j = 1:N,
           switch lower(NodeStr{j}(1)), %first character of the NodeStr
             case {'l'},
               Regions.Left(Index==j)     = Metric(j);
             case {'r'},
               Regions.Right(Index==j)    = Metric(j);
             otherwise
               Regions.AllOther(Index==j) = Metric(j);
           end
         end

       case {'reststatenetwork'}
         Regions.PreFrontal = zeros(N,1);
         Regions.Parietal   = zeros(N,1);
         Regions.Cingulate  = zeros(N,1);
         Regions.Visual     = zeros(N,1);
         Regions.AllOther   = zeros(N,1);
         for j = 1:N,
           switch lower(NodeStr{j}(2:end)),
             case {'pfccl','pfcdl','pfcdm','pfcm','pfcpol','pfcvl'},
               Regions.PreFrontal(Index==j) = Metric(j);
             case {'pci','pcip','pcm','pcs'},
               Regions.Parietal(Index==j)   = Metric(j);
             case {'cca','ccp','ccr','ccs'},
               Regions.Cingulate(Index==j)  = Metric(j);
             case {'v1','v2'},
               Regions.Visual(Index==j)     = Metric(j);
             otherwise
               Regions.AllOther(Index==j)   = Metric(j);
           end
         end
     end
   otherwise
     error(strcat(mfilename,':UnknownConnectionMatrix'), ['Don''t know how to load this matrix...' ThisMatrix]);
 end
     
end % function GroupRegions()

%      labels = 
%     'BSTS'    'other'
%     'ENT'    'other'
%     'FUS'    'other'  
%     'IT'    'other'   
%     'MT'    'other'
%     'PAC'     'other'
%     'PAH'     'other'
%     'PSTC'    'other'
%     'PEC'     'other'
%     'ST'    'other'
%     'SMA'     'other'
%     'TP'    'other'
%     'TT'    'other'
%     
%     'CAC'    'cc'  
%     'ISTC'    'cc'  
%     'PC'    'cc'    
%     'AC'     'cc'  
%     
%     'CMF'    'pf'  
%     'FP'    'pf'     
%     'LOF'    'pf'   
%     'MOF'    'pf'   
%     'POPE'    'pf'   
%     'POB'     'pf'   
%     'PTI'     'pf'  
%     'MF'     'pf'   
%     'SF'    'pf'   
%     
%     'CUN'    'vis' 
%     'LOCC'    'vis' 
%     'LING'    'vis'  
%     'PCAL'    'vis'  
%     
%     'IP'    'pc'
%     'PCUN'    'pc'  
%     'SP'    'pc' 