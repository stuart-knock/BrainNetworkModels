%% Load one of our connectivity matrices
%
% ARGUMENTS: 
%          Connectivity -- a structure containing the options, specific to
%                          each matrix. The options common to all
%                          connectivities are:
%              .WhichMatrix -- A string specifying the connection matrix to
%                              be loaded. No default, must be specified.
%              .invel -- inverse velocity, either a single value or a 
%                        matrix the same size as the connectivity matrix 
%                        you're loading. Default = 1.0;
%
%          Additional options for WhichMatrix = 
%            'for_Vik_July11':
%              .subject -- Default = 1; Possible values = 1:6; 
%
%            'O52R00_IRP2008':
%              .hemisphere -- Which brain hemisphere/s to include. 
%                             Default = 'right'; 
%                             Possible values = {'right', 'left', 'both'}; 
%              .RemoveThalamus -- Default = false;
%              .centres -- Default = 'mni';
%                          Possible values = {'mni', 'macaque_new', 'pals', 
%                                             'colin'}
%
%            'DSI_enhanced':
%              .Parcellation --  Default = 'full';
%                                Possible values = {'full', 'roi'};
%              .WhichWeights --  Default = 'resampled';
%                                Possible values = {'resampled', 'fbden'};
%
% OUTPUT: 
%           weights -- Matrix of connection weights between regions
%           delay   -- Matrix of time delays between regions
%           NodeStr -- A cell array containing strings fro labelling each
%                      region in the matrix.
%           Position -- Euclidean coordinates for centre of regions, mm
%           NumberOfNodes -- Number of regions comprising the parcellation.
%
%       Additionally, for 'O52R00_IRP2008':
%           ThalamicNodes -- Logical vector, identifies thalamic nodes.
%           LeftNodes -- Logical vector, identifies left hemisphere nodes.
%
% REQUIRES:
%           dis -- A function for calculating Euclidean distance between sets of points.
%
% USAGE:
%{
     
  %Specify bi-hemispheric corticothalamic hybrid CoCoMac/DSI connectivity
   Connectivity.WhichMatrix = 'O52R00_IRP2008';
   Connectivity.hemisphere = 'both';
   Connectivity.invel = 1.0 ./ 4.0; %(m/s)^-1 or equiv (mm/ms)^-1...

  %Load it:
   Connectivity = GetConnectivity(Connectivity); 
%}
%
% MODIFICATION HISTORY:
%     VJ/YAR(<dd-mm-yyyy>) -- Original.
%     SAK(27-10-2008) -- Optimise.
%     SAK(04-11-2008) -- Comment/Structure/Generalise.
%     SAK(??-11-2008) -- Added loading of 'for_Vik_July11'
%     SAK(28-01-2009) -- Moved connectivity data into a separate directory
%                        and call to GetSeparator for OS independent path.
%     SAK(19-02-2009) -- Added loading of 'O52R00_IRP2008'
%     SAK(10-03-2009) -- Added return of NodeStr
%     SAK(01-04-2009) -- Added return of Position, where available...
%     SAK(01-04-2009) -- Changed default velocity to 7 m/s 
%     SAK/ARM(07-05-2009) -- Expanded 'GarbageIn' to further clean up
%                            redundant and unconnected regions in  O52R00_IRP2008
%     SAK(22-05-2009) -- 'R00-PFCORB' had been removed due to consisting of
%                         R00-PFCol + R00-PFCoi + R00-PFCom, which exist in
%                         position files but apparently not in connectivity
%                         martrix. R00-PFCORB is nolonger thrown out.
%     SAK(17-11-2009) -- Added option to remove thalamus from the 
%                        O52R00_IRP2008 martix.
%     SAK(10-12-2009) -- Following email from Olaf today, corrected tract  
%                        lengths in for_Vik_July11 to actually be mm, ie 
%                        now use 2*(LENreg_mean)-1
%     SAK(21-12-2009) -- Incorperated position info for 'for_Vik_July11', 
%                        sent by Olaf who stressed that it should only 
%                        be used for plotting. It's an average over all 6
%                        recordings.
%     SAK(22-12-2009) -- Changed default velocity to 1 m/s, so that 
%                        distances are returned 
%     SAK(04-01-2010) -- Set centre for PFCorb in 'O52R00_IRP2008' to be 
%                        centre of subregions ('PFCol','PFCom','PFCoi').
%     SAK(24-03-2010) -- Corrected "Clean-up Node Strings..." for matrix
%                        'O52R00_IRP2008'. Bug had led cortical label 'G' 
%                        to be modified to R00G.
%     SAK(19-08-2011) -- Rotated the weights matrix for O52R00_IRP2008,
%                        with the current simulation code this produces the
%                        correct inputs/outputs, though I don't know if
%                        this is because this matrix started with a 
%                        different orientation to the others or if the
%                        others are currrently wrong... All orientation had
%                        simply been kept cosistent with original
%                        implementation which used RM_AC... TODO: check.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Connectivity] = GetConnectivity(Connectivity)

 Sep = filesep; %Get the appropriate directory separator for this OS

 if isoctave(),
   pkg load io
 end
 
 Connectivity.HaveRotatedWeights = false; %Fresshly loading so they have original sense...

 switch Connectivity.WhichMatrix
   case 'NearestNeighbour'
     if ~isfield(Connectivity,'invel'),
       Connectivity.invel = 1.0; %/7.0; %%must be either a single number or vec(1,N)
     end
     if ~isfield(Connectivity,'dx'),
       Connectivity.dx = 1.0; 
     end
     if ~isfield(Connectivity,'NumberOfNodes'),
       Connectivity.NumberOfNodes = 42;
     else
       if mod(Connectivity.NumberOfNodes,2),
         Connectivity.NumberOfNodes = Connectivity.NumberOfNodes+1;
         warning(strcat('BrainNetworkModels:', mfilename,':NumberOfNodesNotEven'), 'Need an even number of nodes... added 1 and continuing.');
       end
     end
     
     for ns = 1:Connectivity.NumberOfNodes, 
       Connectivity.NodeStr{ns} = num2str(ns);
     end
   
    Connectivity.weights = diag(ones(1,Connectivity.NumberOfNodes-1),1);
    Connectivity.weights = Connectivity.weights + diag(ones(1,Connectivity.NumberOfNodes-1),-1);
    Connectivity.weights(1,end) = 1;
    Connectivity.weights(end,1) = 1;
     
     distance = [0:Connectivity.NumberOfNodes/2  (Connectivity.NumberOfNodes/2-1):-1:1];
     for n=2:Connectivity.NumberOfNodes, 
       distance = [distance ; circshift(distance(n-1,:),[0 1])]; 
     end
     distance = distance .* Connectivity.dx;
     
     Connectivity.delay = (Connectivity.weights~=0) .*Connectivity.invel.*distance;
     
     Connectivity.Position = [(1:Connectivity.NumberOfNodes).' zeros(Connectivity.NumberOfNodes,2)];
   %---------------------------------------------------------------%  
   
   case 'Local'
     if ~isfield(Connectivity,'invel'),
       Connectivity.invel = 1.0; %/7.0; %%must be either a single number or vec(1,N)
     end
     if ~isfield(Connectivity,'dx'),
       Connectivity.dx = 1.0; 
     end
     if ~isfield(Connectivity,'NumberOfNodes'),
       Connectivity.NumberOfNodes = 42;
     else
       if mod(Connectivity.NumberOfNodes,2),
         Connectivity.NumberOfNodes = Connectivity.NumberOfNodes+1;
         warning(strcat('BrainNetworkModels:', mfilename,':NumberOfNodesNotEven'), 'Need an even number of nodes... added 1 and continuing.');
       end
     end
     
     for ns = 1:Connectivity.NumberOfNodes, 
       Connectivity.NodeStr{ns} = num2str(ns);
     end
     
     distance = [0:Connectivity.NumberOfNodes/2  (Connectivity.NumberOfNodes/2-1):-1:1];
     for n=2:Connectivity.NumberOfNodes, 
       distance = [distance ; circshift(distance(n-1,:),[0 1])]; 
     end
     distance = distance.*Connectivity.dx;
     
     Connectivity.weights  = Gaussian(distance, 0.1, 2) - Gaussian(distance, 1,1);
     
     Connectivity.delay = Connectivity.invel.*distance;
     
     Connectivity.Position = [(1:Connectivity.NumberOfNodes).' zeros(Connectivity.NumberOfNodes,2)];
   %---------------------------------------------------------------%  
   
   case 'Random'
     if ~isfield(Connectivity,'invel'),
       Connectivity.invel = 1.0; %/7.0; %%must be either a single number or vec(1,N)
     end
     if ~isfield(Connectivity,'dx'),
       Connectivity.dx = 1.0; 
     end
     if ~isfield(Connectivity,'NumberOfNodes'),
       Connectivity.NumberOfNodes = 42;
     else
       if mod(Connectivity.NumberOfNodes,2),
         Connectivity.NumberOfNodes = Connectivity.NumberOfNodes+1;
         warning(strcat('BrainNetworkModels:', mfilename,':NumberOfNodesNotEven'), 'Need an even number of nodes... added 1 and continuing.');
       end
     end
     
     for ns = 1:Connectivity.NumberOfNodes, 
       Connectivity.NodeStr{ns} = num2str(ns);
     end
     
     Connectivity.weights  = (rand(Connectivity.NumberOfNodes)).*(~ eye(Connectivity.NumberOfNodes));
     
     distance = [0:Connectivity.NumberOfNodes/2  (Connectivity.NumberOfNodes/2-1):-1:1];
     for n=2:Connectivity.NumberOfNodes, 
       distance = [distance ; circshift(distance(n-1,:),[0 1])]; 
     end
     distance = distance.*Connectivity.dx;
     
     Connectivity.delay = Connectivity.invel.*distance;
     
     Connectivity.Position = [(1:Connectivity.NumberOfNodes).' zeros(Connectivity.NumberOfNodes,2)];
   %---------------------------------------------------------------%  
   
   case 'AllToAll'
     if ~isfield(Connectivity,'invel'),
       Connectivity.invel = 1.0; %/7.0; %%must be either a single number or vec(1,N)
     end
     if ~isfield(Connectivity,'dx'),
       Connectivity.dx = 1.0; 
     end
     if ~isfield(Connectivity,'NumberOfNodes'),
       Connectivity.NumberOfNodes = 42;
     else
       if mod(Connectivity.NumberOfNodes,2),
         Connectivity.NumberOfNodes = Connectivity.NumberOfNodes+1;
         warning(strcat('BrainNetworkModels:', mfilename,':NumberOfNodesNotEven'), 'Need an even number of nodes... added 1 and continuing.');
       end
     end
     
     for ns = 1:Connectivity.NumberOfNodes, 
       Connectivity.NodeStr{ns} = num2str(ns);
     end
     
     Connectivity.weights  = (ones(Connectivity.NumberOfNodes,Connectivity.NumberOfNodes) - eye(Connectivity.NumberOfNodes,Connectivity.NumberOfNodes));
     
     distance = [0:Connectivity.NumberOfNodes/2  (Connectivity.NumberOfNodes/2-1):-1:1];
     for n=2:Connectivity.NumberOfNodes, 
       distance = [distance ; circshift(distance(n-1,:),[0 1])]; 
     end
     distance = distance.*Connectivity.dx;
     
     Connectivity.delay = Connectivity.invel.*distance;
     
     Connectivity.Position = [(1:Connectivity.NumberOfNodes).' zeros(Connectivity.NumberOfNodes,2)];
   %---------------------------------------------------------------%  
   
   case 'RM_AC'
     if ~isfield(Connectivity,'invel'),
       Connectivity.invel = 1.0; %/7.0; %%must be either a single number or vec(1,N)
     end
     
     Connectivity.NodeStr = {'A1', 'A2', 'CCA', 'CCP', 'CCR', 'CCS', 'FEF', 'IA', 'IP',    ...
                             'M1', 'PCI', 'PCIP', 'PCM', 'PCS', 'PFCCL', 'PFCDL', 'PFCDM', ...
                             'PFCM', 'PFCORB', 'PFCPOL', 'PFCVL', 'PHC', 'PMCDL', 'PMCM',  ...
                             'PMCVL', 'S1', 'S2', 'TCC', 'TCI', 'TCPOL', 'TCS', 'TCV',     ...
                             'V1', 'V2', 'VACD', 'VACV', 'Pulvinar', 'ThalAM'};
                           
     %Load the connectivity matrix data
     load(['ConnectivityData' Sep 'RM_AC.dat']); %Contains: RM_AC

     Connectivity.NumberOfNodes  = size(RM_AC,1);
     N2 = size(RM_AC,2);
     Connectivity.weights  = RM_AC(1:Connectivity.NumberOfNodes,1:Connectivity.NumberOfNodes).'; %transposed
     Connectivity.Position = RM_AC(1:Connectivity.NumberOfNodes,Connectivity.NumberOfNodes+1:N2);

     % connectivity matrix
     Connectivity.weights(Connectivity.weights==7) = 0.0; %unknowns
     Connectivity.weights(Connectivity.weights==8) = 0.0; %not connected
     Connectivity.weights(Connectivity.weights==9) = 0.0; %diagonals - doesn't matter

     % Calculate time delay using the Euclidean distance between nodes
     Connectivity.delay = zeros(Connectivity.NumberOfNodes,Connectivity.NumberOfNodes);
     for i=1:Connectivity.NumberOfNodes,
       Connectivity.delay(i,:) = Connectivity.invel.*dis(Connectivity.Position(i,:).', Connectivity.Position.').';
     end
   %---------------------------------------------------------------%  
     
   case 'for_Vik_July11'  
     %These matrices are supposed to be symmetric but aren't exactly...
     %Also, they have values in the diagonal elements for some reason... as
     %they are derived from dsi tractography this doesn't seem to make much sense.  -- DUE TO AVEREAGING OVER THE FINER PARCELLATION... 
     
     if ~isfield(Connectivity,'invel'),
       Connectivity.invel = 1.0; %/7.0;%must be either a single number or vec(1,N)
     end
     if ~isfield(Connectivity,'subject'),
       Connectivity.subject = 1;
     end
     
     %Load the connectivity matrix data
     load(['ConnectivityData' Sep 'for_Vik_July11.mat'], 'CIJreg_mean', 'LENreg_mean', 'anatlbls'); %Contains:  CIJreg_mean, LENreg_mean, anatlbls
     
     Connectivity.NodeStr = strtrim(cellstr(anatlbls));

     Connectivity.NumberOfNodes  = size(CIJreg_mean,1);
     Connectivity.weights  = CIJreg_mean(1:Connectivity.NumberOfNodes,1:Connectivity.NumberOfNodes,Connectivity.subject); %These matrices are supposed to be symmetric but aren't exactly...
     
     Connectivity.delay = Connectivity.invel.*(2.*LENreg_mean(1:Connectivity.NumberOfNodes,1:Connectivity.NumberOfNodes,Connectivity.subject)-1);
     Connectivity.delay(Connectivity.weights==0) = 0; %when weights are 0 lengths are NaN, changing here saves having to do it in the integration routine and has no effect as the history selected by these values are multiplied by weights...
     
     %%%warning(strcat('BrainNetworkModels:', mfilename,':NoPositionData'), 'There is no position data for "for_Vik_July11"');
     %%%Position = zeros(N,3);
     warning(strcat('BrainNetworkModels:', mfilename,':OlafSaidPlottingOnly'), 'Olaf requested this position info be used for plotting purposes only...');
     load(['ConnectivityData' Sep 'xyz_dsi_regional.mat'], 'xm', 'ym', 'zm'); % Contains: xm, ym, zm
     Connectivity.Position = [xm ym zm];
   %---------------------------------------------------------------% 
     
   case 'O52R00_IRP2008' %NOTE: This one merges Cocomac & DSI 
     if ~isfield(Connectivity,'invel'),
       Connectivity.invel = 1.0; %/7.0; %%must be either a single number or vec(1,N)
     end
     if ~isfield(Connectivity,'centres'),
       Connectivity.centres = 'mni';
     end
     if ~isfield(Connectivity,'hemisphere'),
       Connectivity.hemisphere = 'right';
     end
     if ~isfield(Connectivity,'RemoveThalamus'),
       Connectivity.RemoveThalamus = false;
     end

    %Load the connectivity matrix data
     try
       temp = importdata(['ConnectivityData' Sep 'O52R00_IRP2008.txt'], ',');
       %keyboard
     catch
       error(strcat('BrainNetworkModels:', mfilename,':NoImportdata'), 'If using Octave you probably need pkg io and importdata from forge...');
     end
     if isoctave(),
       Connectivity.weights = temp.data(2:end, 2:end);
     else %Presumably Matlab
       Connectivity.weights = temp.data; %TODO: Need to check if Matlab has changed with explicit ',' required by octave for importdata
     end
     Connectivity.weights(isnan(Connectivity.weights)) = 0; %Set absent values to zero
     Connectivity.NodeStr = temp.textdata(2:end,1);
     %keyboard
     
     %Load a cell array of strings containing more intuitive region names.
     %(Courtesy of RB.)
     if ~isoctave(), %Getting an error loading this in Octave, it's non-critical so just skipping. TODO: Check again with newer octaves...
       load(['ConnectivityData' Sep 'O52R00_IRP2008_NodeStrIntuitiveName.mat'])
       Connectivity.NodeStrIntuitive = NodeStrIntuitive;
     end
     
    %Insert columns at 27(O52-GR.cn),56(O52-Sf),58(O52-Sub.Th),59(O52-Teg.a)
     columnOfZeros = zeros(size(Connectivity.weights,1),1);
     Connectivity.weights = [Connectivity.weights(:,1:26) columnOfZeros Connectivity.weights(:,27:54) columnOfZeros Connectivity.weights(:,55) columnOfZeros columnOfZeros Connectivity.weights(:,56:end)];
     
    %Insert a row at 60(O52-SO)
     rowOfZeros = zeros(1,size(Connectivity.weights,2));
     Connectivity.weights = [Connectivity.weights(1:59,:) ; rowOfZeros ; Connectivity.weights(60:end,:)];
     Connectivity.NodeStr = {Connectivity.NodeStr{1:59} 'O52-SO'  Connectivity.NodeStr{60:end}}.';
     
    %Get rid of old/redundant nodes...
     GarbageIn = {'R00-PCD'    'R00-PFCD'               'R00-TOC'  'O52-ZIC'  'O52-ZI'   'O52-SO' ... 
                  'O52-Sub.Th' 'O52-Sf'    'O52-RO'     'O52-HM'   'O52-HLPC' 'O52-HLMC' 'O52-HL'  ... 
                  'O52-H'      'O52-GR.cn' 'O52-GMMC'   'O52-GLVO' 'O52-GLVC' 'O52-GLV'  'O52-Al' ...
                  'BHD91-MD'   'BK83-LGN'  'O52-GLD'};
     GarbageOut = zeros(1,length(GarbageIn));
     for j = 1:length(GarbageIn),  %All the redundant crap
       GarbageOut(j) = find(strcmp(GarbageIn{j}, Connectivity.NodeStr)); %Get indexes
     end
     Connectivity.weights(GarbageOut,:) = [];     %Throw out rows
     Connectivity.weights(:,GarbageOut) = [];     %Throw out columns
     Connectivity.NodeStr(GarbageOut) = []; %Throw out corresponding NodeStr
     if ~isoctave(),
       Connectivity.NodeStrIntuitive(GarbageOut) = []; %Throw out corresponding Intuitive NodeStr
     end
%%%keyboard 
%%%Connectivity.NodeStr
     % Clean-up Node Strings...
     for j = 1:length(Connectivity.NodeStr),
       if all(Connectivity.NodeStr{j}(1:4)=='O52-') || all(Connectivity.NodeStr{j}(1:4)=='R00-'),
         Connectivity.NodeStr{j}(1:4) = []; 
       end
     end
%%%Connectivity.NodeStr
         
    %Load position data
     try %On my setup I can't get any xls to load in Octave. TODO: May be easier to transform all xls into a format that will be less painful... I hate .xls.
       left  = importdata(['ConnectivityData' Sep 'centres_' Connectivity.centres '_left.csv'], ',');  %Node position data, Left hemisphere
       right = importdata(['ConnectivityData' Sep 'centres_' Connectivity.centres '_right.csv'], ','); %Node position data, Right hemisphere 
     catch
       error(strcat('BrainNetworkModels:', mfilename,':NoImportdata'), 'If using Octave you probably need pkg io, java and importdata from forge...');
     end
     %keyboard
     if isoctave(),
       left.data = left.data(:, 2:4);
       right.data = right.data(:, 2:4);
     else %Presumably Matlab
       %TODO: Need to check if Matlab has changed with conversion to csv & explicit ',' required by octave for importdata
     end
     ThalamusPosition = mean([left.data ; right.data],1); %No position data for thalamus, approximate by centre of cortical positions.

     %Modify region names for locations to be consistent with naming for connectivity matrix...
     for j=1:length(right.textdata),
       right.textdata{j} = ['r' right.textdata{j}(4:end)];
     end
     %Modify region names for locations to be consistent with naming for connectivity matrix...
     for j=1:length(left.textdata),
       left.textdata{j} = ['l' left.textdata{j}(4:end)];
     end
     
    %Use centre of three regions ('PFCol','PFCom','PFCoi') to set centre for PFCorb 
     lPFCorb_PartLabels = {'lPFCol','lPFCom','lPFCoi'};
     rPFCorb_PartLabels = {'rPFCol','rPFCom','rPFCoi'};
     lPFCorb_PartsIndex = zeros(1,3);
     rPFCorb_PartsIndex = zeros(1,3);
     for j =1:3, 
       lPFCorb_PartsIndex(j) = find(strcmp(lPFCorb_PartLabels{j}, left.textdata)); 
       rPFCorb_PartsIndex(j) = find(strcmp(rPFCorb_PartLabels{j}, right.textdata)); 
     end
     left.textdata{end+1} = 'lPFCorb';
     left.data(end+1,:) = mean(left.data(lPFCorb_PartsIndex,:),1);
     right.textdata{end+1} = 'rPFCorb';
     right.data(end+1,:) = mean(right.data(rPFCorb_PartsIndex,:),1);
     
     Connectivity.NumberOfNodes = length(Connectivity.NodeStr);
     
     switch lower(Connectivity.hemisphere),
       case 'right',
         for j = 1:Connectivity.NumberOfNodes,
           Connectivity.NodeStr{j} = ['r' Connectivity.NodeStr{j}]; %Prepend with r for right hemisphere
           if ~isoctave(),
             Connectivity.NodeStrIntuitive{j} = ['r' Connectivity.NodeStrIntuitive{j}]; %Prepend with r for right hemisphere
           end
         end
         Connectivity.LeftNodes = false(1,Connectivity.NumberOfNodes);
        %Use positions for right hemisphere...
         PositionData = right.data;
         PositionStr  = right.textdata;
         
       case 'left',
         for j = 1:Connectivity.NumberOfNodes,
           Connectivity.NodeStr{j} = ['l' Connectivity.NodeStr{j}]; %Prepend with l for left hemisphere
           if ~isoctave(),
             Connectivity.NodeStrIntuitive{j} = ['l' Connectivity.NodeStrIntuitive{j}]; %Prepend with l for left hemisphere
           end
         end
         Connectivity.LeftNodes = true(1,Connectivity.NumberOfNodes);
        %Use positions for left hemisphere...
         PositionData = left.data;
         PositionStr  = left.textdata;
         
       case 'both',
         Connectivity.NodeStr = [Connectivity.NodeStr ; Connectivity.NodeStr];
         if ~isoctave(),
           Connectivity.NodeStrIntuitive = [Connectivity.NodeStrIntuitive ; Connectivity.NodeStrIntuitive];
         end
         for j = 1:Connectivity.NumberOfNodes,
           Connectivity.NodeStr{j} = ['l' Connectivity.NodeStr{j}]; %Prepend with l for left hemisphere
           if ~isoctave(),
             Connectivity.NodeStrIntuitive{j} = ['l' Connectivity.NodeStrIntuitive{j}]; %Prepend with l for left hemisphere
           end
         end
         for j = (Connectivity.NumberOfNodes+1):length(Connectivity.NodeStr),
           Connectivity.NodeStr{j} = ['r' Connectivity.NodeStr{j}]; %Prepend with r for right hemisphere
           if ~isoctave(),
             Connectivity.NodeStrIntuitive{j} = ['r' Connectivity.NodeStrIntuitive{j}]; %Prepend with r for right hemisphere
           end
         end
         Connectivity.LeftNodes = [true(1,Connectivity.NumberOfNodes) false(1,Connectivity.NumberOfNodes)];
        %Use positions for left hemisphere...
         PositionData = [left.data     ; right.data];
         PositionStr  = [left.textdata ; right.textdata];
         
        %Construct weight matrix containing both hemispheres
         temp = zeros(2*Connectivity.NumberOfNodes,2*Connectivity.NumberOfNodes);
         temp(1:Connectivity.NumberOfNodes,1:Connectivity.NumberOfNodes) = Connectivity.weights;
         temp((Connectivity.NumberOfNodes+1):end,(Connectivity.NumberOfNodes+1):end) = Connectivity.weights;
         Connectivity.weights = temp; clear temp
%%%keyboard         
% % %         %Load cortical interhemispheric data...
% % %          CallosalConnections = importdata(['ConnectivityData' Sep 'CallosalConnections_HagmannVsCocomac.xls']); 
% % %          for j = 2:37, 
% % %            StrStart = strfind(CallosalConnections.textdata.Sheet1{j,5},'-') + 1; 
% % %            InterHemisphericStr{j-1} = CallosalConnections.textdata.Sheet1{j,5}(StrStart:(end-1)); 
% % %          end
% % %          InterHemispheric = CallosalConnections.data.Sheet1(:,5);
                  
        %Load cortical interhemispheric data...
         try
           CallosalConnections = importdata(['ConnectivityData' Sep 'cleanCallosalConnections_HagmannVsCocomac.csv'], ',');
         catch
           error(strcat('BrainNetworkModels:', mfilename,':NoImportdata'), 'If using Octave you probably need pkg io and importdata from forge...');
         end
         InterHemisphericStr = cell(1,36);
         LabelMapping        = cell(1,36);
         DSIlabel            = cell(1,36);
         for j = 2:37,
           InterHemisphericStr{1,j-1} = CallosalConnections.textdata{j,4};
           LabelMapping{1,j-1}  = CallosalConnections.textdata{j,2};
           DSIlabel{1,j-1}      = CallosalConnections.textdata{j,1};
         end
         if isoctave(),
           InterHemispheric = CallosalConnections.data(2:37,5);
         else %Presumably Matlab
            InterHemispheric = CallosalConnections.data(:,5); %TODO: Need to check if Matlab has changed with explicit ',' required by octave for importdata
         end
         %keyboard
         
        %Load the DSI connectivity matrix data
         DSI = load(['ConnectivityData' Sep 'for_Vik_July11.mat'], 'CIJreg_mean', 'LENreg_mean', 'anatlbls'); %Contains:  CIJreg_mean, LENreg_mean, anatlbls
         DSI.anatlbls = strtrim(cellstr(DSI.anatlbls));
         DSI.CIJreg_mean = squeeze(mean(DSI.CIJreg_mean,3)); %Average over the DSI derived matrices we have
         minDSIw = min(DSI.CIJreg_mean(~eye(size(DSI.CIJreg_mean)))); %Only inter-regional
         maxDSIw = max(DSI.CIJreg_mean(~eye(size(DSI.CIJreg_mean)))); %Only inter-regional
         DSI.CIJreg_mean = 3*(DSI.CIJreg_mean - minDSIw)./(maxDSIw - minDSIw); %Rescale to lie in range 0:3
%%% min(DSI.CIJreg_mean(:))
%%% max(DSI.CIJreg_mean(:))
%%% figure, hist(DSI.CIJreg_mean(DSI.CIJreg_mean~=0),100)
         
%keyboard     

        %Incorporate Interhemispheric connection into w 
         for j=1:length(InterHemispheric),                                                                     %For: Our interhemispheric data
           if InterHemispheric(j),                                                                             %If: The CoCoMac database shows a connection
             LeftNode  = find(strcmpi(['l' InterHemisphericStr{j}],Connectivity.NodeStr));                     %Get index of Left hemisphere node.
             RightNode = find(strcmpi(['r' InterHemisphericStr{j}],Connectivity.NodeStr));                     %Get index of Right hemisphere node.
             DSILabelMappingIndex = find(strcmpi(Connectivity.NodeStr{LeftNode}(2:end), LabelMapping));        %Get index of corressponding NodeStr for DSI.
             if isempty(DSILabelMappingIndex),                                                                 %If: There is NO equivalent node in the DSI matrices
               Connectivity.weights(LeftNode,RightNode) = 1;                                                   %Assign 1 to interhemispheric connection
               Connectivity.weights(RightNode,LeftNode) = 1;                                                   %Assign 1 to interhemispheric connection
             else                                                                                              %Else: There is an equivalent node in the DSI matrices
%%%keyboard
               DSIequivNodeStr   = DSIlabel{DSILabelMappingIndex};                                             %Get corressponding NodeStr for DSI.
               DSIequivLeftNode  = find(strcmpi(['l' DSIequivNodeStr], DSI.anatlbls));                         %Get index of DSI Left hemisphere node.
               DSIequivRightNode = find(strcmpi(['r' DSIequivNodeStr], DSI.anatlbls));                         %Get index of DSI Right hemisphere node.
               Connectivity.weights(LeftNode,RightNode) = DSI.CIJreg_mean(DSIequivLeftNode,DSIequivRightNode); %Assign normalised DSI weight to interhemispheric connection
               Connectivity.weights(RightNode,LeftNode) = DSI.CIJreg_mean(DSIequivRightNode,DSIequivLeftNode); %Assign normalised DSI weight to interhemispheric connection
             end
           end
         end

%%%keyboard
         Connectivity.NumberOfNodes = length(Connectivity.NodeStr); %Reset N for new two hemishpere brain...
         
       otherwise
         error(strcat('BrainNetworkModels:', mfilename,':UnknownHemisphere'), ['Ummmm... Hemisphere should be left, right, or both but you seem to have asked for: ' Connectivity.hemisphere]);
     end
     
     Connectivity.ThalamicNodes = false(1,Connectivity.NumberOfNodes);
     for j=1:Connectivity.NumberOfNodes,
       Connectivity.ThalamicNodes(1,j) = ~any(strcmpi(PositionStr, Connectivity.NodeStr{j})); %Use fact that we don't know thalamic positions...
     end
   %Make it a purely cortical matrix on request.
    if Connectivity.RemoveThalamus,
      Connectivity.weights(Connectivity.ThalamicNodes,:)        = []; %Throw out row
      Connectivity.weights(:,Connectivity.ThalamicNodes)        = []; %Throw out column
      Connectivity.NodeStr(Connectivity.ThalamicNodes)          = []; %Throw out corresponding NodeStr 
      if ~isoctave(),
        Connectivity.NodeStrIntuitive(Connectivity.ThalamicNodes) = []; %Throw out corresponding NodeStrIntuitive
      end
      Connectivity.LeftNodes(Connectivity.ThalamicNodes)        = [];
      Connectivity.NumberOfNodes = length(Connectivity.NodeStr);      %Reset N for cortex only matrix...
      Connectivity.ThalamicNodes = false(1,Connectivity.NumberOfNodes);
    end
     
    %Assign positions for nodes in NodeStr...
    Connectivity.Position = zeros(Connectivity.NumberOfNodes,3);
     for j=1:Connectivity.NumberOfNodes,
       PositionIndex = find(strcmpi(PositionStr, Connectivity.NodeStr{j}), 1);
       if isempty(PositionIndex),
         Connectivity.Position(j,:) = ThalamusPosition;
       else
         Connectivity.Position(j,:) = PositionData(PositionIndex, :);
       end
     end
%keyboard
     
    % Calculate time delay using the Euclidean distance between nodes
     Connectivity.delay = zeros(Connectivity.NumberOfNodes, Connectivity.NumberOfNodes);
     for i=1:Connectivity.NumberOfNodes,
       Connectivity.delay(i,:) = Connectivity.invel.*dis(Connectivity.Position(i,:).', Connectivity.Position.').';
     end
     
     %Robert noticed incorrect orientation of this matrix, given current
     %usage in simulation code. Quick fix rotate it here, however, should
     %check that other matrices are in fact correctly oriented. Currently
     %simulation code assumes weights are provided such that summing over 
     %columns, ie W(42,42)=>W(42,1), will provide summed input to a region.
     Connectivity.weights = Connectivity.weights.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %---------------------------------------------------------------%  

%TODO: Make use of this with in combination with CoCoMac...  
   case 'DSI_enhanced'  
     %
     if ~isfield(Connectivity,'invel'),
       Connectivity.invel = 1.0; %/7.0;%must be either a single number or vec(1,N)
     end
     if ~isfield(Connectivity,'Parcellation'),
       Connectivity.Parcellation = 'full'; %keep all 998 nodes...
     end
     if ~isfield(Connectivity,'WhichWeights'),
       Connectivity.WhichWeights = 'resampled'; %use resampled to gaussian...
     end
     
     %Load the connectivity matrix data
     load(['ConnectivityData' Sep 'DSI_enhanced.mat'],'anat_lbls', 'CIJ_resampled_average', 'CIJ_fbden_average', 'CIJ_edgelength_average', 'talairach', 'roi_lbls'); 
     % Contains: CIJ_edgelength_average, COR_fMRI_average, roi_xyz_avg, 
     %           CIJ_fbden_average,      anat_lbls,        talairach,               
     %           CIJ_resampled_average,  roi_lbls
     
     Connectivity.NodeStr = strtrim(cellstr(anat_lbls));
     switch Connectivity.WhichWeights, 
       case 'resampled' 
         Connectivity.weights  = CIJ_resampled_average;
       case 'fbden' 
         Connectivity.weights  = CIJ_fbden_average;
       otherwise
         error(strcat('BrainNetworkModels:', mfilename,':UnknownWhichWeights'), ['WhichWeights for DSI_enhanced must be either ''resampled'' or ''fbden''. You requested ''' Connectivity.WhichWeights '''.']);
     end
     Connectivity.delay = Connectivity.invel.*CIJ_edgelength_average;
     Connectivity.delay(Connectivity.weights==0) = 0; %when weights are 0 lengths are NaN, changing here saves having to do it in the integration routine and has no effect as the history selected by these values are multiplied by weights...
     Connectivity.Position = talairach;
     
     switch Connectivity.Parcellation, 
       case 'full' %all 998
         Connectivity.NodeStr = Connectivity.NodeStr(roi_lbls);
         Connectivity.NumberOfNodes = length(Connectivity.NodeStr);
       case 'roi' %labeled 66
         Connectivity.NumberOfNodes = length(Connectivity.NodeStr);
         
         % NB. diagonal elements in the weights and delay matrices 
         % correspond to the "internal" connection within the roi, 
         % that is between the subregions that make up each roi.
         
         %Weights
         temp = Connectivity.weights;
         temp2 = zeros(Connectivity.NumberOfNodes,998);
         Connectivity.weights = zeros(Connectivity.NumberOfNodes,Connectivity.NumberOfNodes);
         for k=1:Connectivity.NumberOfNodes, 
           temp2(k,:) = mean(temp(roi_lbls==k,:)); 
         end
         for k=1:Connectivity.NumberOfNodes, 
           Connectivity.weights(:,k) = mean(temp2(:,roi_lbls==k),2); 
         end
         
         %Delay
         temp = Connectivity.delay;
         temp2 = zeros(Connectivity.NumberOfNodes,998);
         Connectivity.delay = zeros(Connectivity.NumberOfNodes,Connectivity.NumberOfNodes);
         for k=1:Connectivity.NumberOfNodes, 
           temp3 = temp(roi_lbls==k,:);
           for kk=1:998,
             temp4 = temp3(:,kk);
             temp2(k,kk) = mean(temp4(temp4~=0));
           end
         end
         for k=1:Connectivity.NumberOfNodes, 
           temp3 = temp2(:,roi_lbls==k);
           for kk=1:Connectivity.NumberOfNodes,
             temp4 = temp3(kk,:);
             Connectivity.delay(kk,k) = mean(temp4(temp4~=0));
           end
         end
         
         %Position
         temp = Connectivity.Position;
         Connectivity.Position = zeros(Connectivity.NumberOfNodes,3);
         for k=1:Connectivity.NumberOfNodes, 
           Connectivity.Position(k,:) = mean(temp(roi_lbls==k,:)); 
         end
       otherwise
         error(strcat('BrainNetworkModels:', mfilename,':UnknownParcellation'), ['Parcellation for DSI_enhanced must be either ''full'' or ''roi''. You requested ''' Connectivity.Parcellation '''.']);
     end
   
     
     
   case 'G_20110513' 
     if ~isfield(Connectivity,'invel'),
       Connectivity.invel = 1.0; %/7.0;
     end
     if ~isfield(Connectivity,'hemisphere'),
       Connectivity.hemisphere = 'both';
     end
     if ~isfield(Connectivity,'CortexOnly'),
       Connectivity.CortexOnly = false;
     end
     
     if ~strcmp(Connectivity.hemisphere, 'both'),
       error(strcat('BrainNetworkModels:', mfilename,':NotImplemented'), ['Haven''t implemented split into hemispheres yet for gleb...']);
     end
     
     try
       Description = importdata(['ConnectivityData' Sep 'RM_mni_description_20110513_clean.xls']);
     catch
       error(strcat('BrainNetworkModels:', mfilename,':NoImportdata'), 'If using Octave you probably need pkg io and importdata from forge...');
     end
     
     %NodeStr
     Connectivity.NodeStr = Description.textdata(2:end, end);
     Connectivity.NodeStrIntuitive = Description.textdata(2:end, 5);
     Connectivity.NumberOfNodes = length(Connectivity.NodeStr);
     
     %Weights
     load(['ConnectivityData' Sep 'TVB_surfaceData+connectivityMatrix_20110923.mat'], 'connection_matrix');
     Connectivity.weights = connection_matrix;
     
     %Position
      load(['ConnectivityData' Sep 'Centres_G_20110513.mat'], 'RegionCentres');
      Connectivity.Position = RegionCentres;
      
     %Delay
     % Calculate time delay using the Euclidean distance between nodes
     Connectivity.delay = zeros(Connectivity.NumberOfNodes, Connectivity.NumberOfNodes);
     for i=1:Connectivity.NumberOfNodes,
       Connectivity.delay(i,:) = Connectivity.invel .* dis(Connectivity.Position(i,:).', Connectivity.Position.').';
     end
     
     %Cortical
     try
       isCortex = importdata(['ConnectivityData' Sep 'RM.isCortex_20111020_clean.xls']);
     catch
       error(strcat('BrainNetworkModels:', mfilename,':NoImportdata'), 'If using Octave you probably need pkg io and importdata from forge...');
     end
     Connectivity.ThalamicNodes = ~isCortex.data(:,3);
     %%%Connectivity.ThalamicNodes = false(1,Connectivity.NumberOfNodes);
     %%%Connectivity.ThalamicNodes(1, [42:48 90:96]) = true;
     %[num2cell(Connectivity.ThalamicNodes(:)) Connectivity.NodeStr  Connectivity.NodeStrIntuitive]
     
     %Orientation
      load(['ConnectivityData' Sep 'AverageOrientation_G_20110513.mat'], 'AverageOrientation');
      Connectivity.Orientation = AverageOrientation;
     
     %Area
      load(['ConnectivityData' Sep 'RegionSurfaceArea_G_20110513.mat'], 'RegionSurfaceArea');
      Connectivity.Area = RegionSurfaceArea;
     
      if Connectivity.CortexOnly,
        Connectivity.weights(Connectivity.ThalamicNodes, :)        = []; %Throw out row
        Connectivity.weights(:, Connectivity.ThalamicNodes)        = []; %Throw out column
        Connectivity.delay(Connectivity.ThalamicNodes, :)          = []; %Throw out row
        Connectivity.delay(:, Connectivity.ThalamicNodes)          = []; %Throw out column
        Connectivity.Position(Connectivity.ThalamicNodes, :)       = []; 
        Connectivity.Orientation(Connectivity.ThalamicNodes, :)    = []; 
        Connectivity.Area(Connectivity.ThalamicNodes, :)           = []; 
        Connectivity.NodeStr(Connectivity.ThalamicNodes)           = []; %Throw out corresponding NodeStr
        Connectivity.NodeStrIntuitive(Connectivity.ThalamicNodes)  = []; %Throw out corresponding NodeStrIntuitive
        Connectivity.ThalamicNodes(Connectivity.ThalamicNodes)     = [];
        Connectivity.NumberOfNodes = length(Connectivity.NodeStr);      %Reset N for cortex only matrix...
      end
     
   %---------------------------------------------------------------%  
   otherwise
     error(strcat('BrainNetworkModels:', mfilename,':UnknownConnectionMatrix'), ['Don''t know how to load this matrix...' ThisMatrix]);
 end %switch ThisMatrix
     
end %function GetConnectivity()

% % %      R00 = RM
% % %      R00-PCD = R00-PCm || R00-PCs 
% % %      R00-PFCD = R00-PFCm || R00-PFCdl
% % %      R00-PFCORB = R00-PFCol || R00-PFCoi || R00-PFCom
