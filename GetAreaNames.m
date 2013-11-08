%% Return a string specifying the Name of an area given its NodeStr
%  
% Largely extracted from:
%    http://www.cocomac.org/regionalmap.pdf
% 
%    "Cortical network dynamics with time delays reveals functional
%     connectivity in the resting brain" Gosh etal 2008. 
% 
%    "Mapping the Structural Core of Human Cerebral Cortex" Hagmann etal
%    2008.
%
%
% ARGUMENTS:
%           NodeStr -- cell array of short node name abbreviations
%
% OUTPUT: 
%           AreaNameStr -- cell array of long node name descriptions
%
% USAGE:
%{
      %Generate a NodeStr using GetConnectivity(...) then:
       AreaNameStr=GetAreaNames(NodeStr);
%}
%
% MODIFICATION HISTORY:
%     SAK(03-04-2009) -- Original.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function AreaNameStr=GetAreaNames(NodeStr)
%% Clean-up crappy Node Strings...
  for j = 1:length(NodeStr), 
    if length(NodeStr{j})>6, NodeStr{j}(NodeStr{j}(1:6)=='BHD91-') = []; end
    if length(NodeStr{j})>5, NodeStr{j}(NodeStr{j}(1:5)=='BK83-')  = []; end
    if length(NodeStr{j})>4, NodeStr{j}(NodeStr{j}(1:4)=='O52-')   = []; end
    if length(NodeStr{j})>4, NodeStr{j}(NodeStr{j}(1:4)=='R00-')   = []; end
    %NodeStr{j}(NodeStr{j}=='.') = [];
  end
 
%%
 AreaNameStr = cell(1,length(NodeStr));
 for j = 1:length(NodeStr), %Each Node
   switch lower(NodeStr{j})
%CoCoMac
     case {'amyg'}
       AreaNameStr{j} = 'Amygdala';
     case {'lamyg'}
       AreaNameStr{j} = 'Left Amygdala';
     case {'ramyg'}
       AreaNameStr{j} = 'Right Amygdala';
     case {'a1'}
       AreaNameStr{j} = 'Primary Auditory Cortex';
     case {'la1'}
       AreaNameStr{j} = 'Left Primary Auditory Cortex';
     case {'ra1'}
       AreaNameStr{j} = 'Right Primary Auditory Cortex';
     case {'a2'}
       AreaNameStr{j} = 'Secondary Auditory Cortex';
     case {'la2'}
       AreaNameStr{j} = 'Left Secondary Auditory Cortex';
     case {'ra2'}
       AreaNameStr{j} = 'Right Secondary Auditory Cortex';
     case {'cca'}
       AreaNameStr{j} = 'Anterior Cingulate Cortex';
     case {'lcca'}
       AreaNameStr{j} = 'Left Anterior Cingulate Cortex';
     case {'rcca'}
       AreaNameStr{j} = 'Right Anterior Cingulate Cortex';
     case {'ccp'}
       AreaNameStr{j} = 'Posterior Cingulate Cortex';
     case {'lccp'}
       AreaNameStr{j} = 'Left Posterior Cingulate Cortex';
     case {'rccp'}
       AreaNameStr{j} = 'Right Posterior Cingulate Cortex';
     case {'ccr'}
       AreaNameStr{j} = 'Retrosplenial Cingulate Cortex';
     case {'lccr'}
       AreaNameStr{j} = 'Left Retrosplenial Cingulate Cortex';
     case {'rccr'}
       AreaNameStr{j} = 'Right Retrosplenial Cingulate Cortex';
     case {'ccs'}
       AreaNameStr{j} = 'Subgenual Cingulate Cortex';
     case {'lccs'}
       AreaNameStr{j} = 'Left Subgenual Cingulate Cortex';
     case {'rccs'}
       AreaNameStr{j} = 'Right Subgenual Cingulate Cortex';
     case {'fef'}
       AreaNameStr{j} = 'Frontal Eye Field';
     case {'lfef'}
       AreaNameStr{j} = 'Left Frontal Eye Field';
     case {'rfef'}
       AreaNameStr{j} = 'Right Frontal Eye Field';
     case {'hc'}
       AreaNameStr{j} = 'Hippocampus';
     case {'lhc'}
       AreaNameStr{j} = 'Left Hippocampus';
     case {'rhc'}
       AreaNameStr{j} = 'Right Hippocampus';
     case {'ia'}
       AreaNameStr{j} = 'Anterior Insula (= agranular+dysgranular insular cortex)';
     case {'lia'}
       AreaNameStr{j} = 'Left Anterior Insula (= agranular+dysgranular insular cortex)';
     case {'ria'}
       AreaNameStr{j} = 'Right Anterior Insula (= agranular+dysgranular insular cortex)';
     case {'ip'}
       AreaNameStr{j} = 'Posterior insula (= granular insular cortex)';
     case {'lip'}
       AreaNameStr{j} = 'Left Posterior insula (= granular insular cortex)';
     case {'rip'}
       AreaNameStr{j} = 'Right Posterior insula (= granular insular cortex)';
     case {'lgn'}
       AreaNameStr{j} = 'Lateral geniculate nucleus';
     case {'llgn'}
       AreaNameStr{j} = 'Left Lateral geniculate nucleus';
     case {'rlgn'}
       AreaNameStr{j} = 'Right Lateral geniculate nucleus';
     case {'m1'}
       AreaNameStr{j} = 'primary motor cortex';
     case {'lm1'}
       AreaNameStr{j} = 'left primary motor cortex';
     case {'rm1'}
       AreaNameStr{j} = 'right primary motor cortex';
     case {'pci'}
       AreaNameStr{j} = 'Inferior posterior parietal cortex (inferior parietal lobule)';
     case {'lpci'}
       AreaNameStr{j} = 'Left Inferior posterior parietal cortex (inferior parietal lobule)';
     case {'rpci'}
       AreaNameStr{j} = 'Right Inferior posterior parietal cortex (inferior parietal lobule)';
     case {'pcip'}
       AreaNameStr{j} = 'Cortex of the intraparietal sulcus';
     case {'lpcip'}
       AreaNameStr{j} = 'Left Cortex of the intraparietal sulcus';
     case {'rpcip'}
       AreaNameStr{j} = 'Right Cortex of the intraparietal sulcus';
     case {'pcm'}
       AreaNameStr{j} = 'medial  parietal cortex (precuneus)';
     case {'lpcm'}
       AreaNameStr{j} = 'left medial  parietal cortex (precuneus)';
     case {'rpcm'}
       AreaNameStr{j} = 'right medial  parietal cortex (precuneus)';
     case {'pcs'}
       AreaNameStr{j} = 'Dorsal parietal cortex (superior parietal lobule)';
     case {'lpcs'}
       AreaNameStr{j} = 'Left Dorsal parietal cortex (superior parietal lobule)';
     case {'rpcs'}
       AreaNameStr{j} = 'Right Dorsal parietal cortex (superior parietal lobule)';
     case {'pcd'}
       AreaNameStr{j} = 'dorsal (dorsolateral + medial) posterior parietal cortex (superior parietal lobule + precuneus)';
     case {'lpcd'}
       AreaNameStr{j} = 'Left dorsal (dorsolateral + medial) posterior parietal cortex (superior parietal lobule + precuneus)';
     case {'rpcd'}
       AreaNameStr{j} = 'Right dorsal (dorsolateral + medial) posterior parietal cortex (superior parietal lobule + precuneus)';
     case {'pfccl'}
       AreaNameStr{j} = 'centrolateral prefrontal cortex';
     case {'lpfccl'}
       AreaNameStr{j} = 'Left centrolateral prefrontal cortex';
     case {'rpfccl'}
       AreaNameStr{j} = 'Right centrolateral prefrontal cortex';
     case {'pfcdl'}
       AreaNameStr{j} = 'dorsolateral prefrontal cortex';
     case {'lpfcdl'}
       AreaNameStr{j} = 'left dorsolateral prefrontal cortex';
     case {'rpfcdl'}
       AreaNameStr{j} = 'right dorsolateral prefrontal cortex';
     case {'pfcdm'}
       AreaNameStr{j} = 'dorsomedial prefrontal cortex';
     case {'lpfcdm'}
       AreaNameStr{j} = 'left dorsomedial prefrontal cortex';
     case {'rpfcdm'}
       AreaNameStr{j} = 'right dorsomedial prefrontal cortex';
     case {'pfcd'}
       AreaNameStr{j} = 'dorsal (dorsomedial + dorsolateral) prefrontal cortex';
     case {'lpfcd'}
       AreaNameStr{j} = 'left dorsal (dorsomedial + dorsolateral) prefrontal cortex';
     case {'rpfcd'}
       AreaNameStr{j} = 'right dorsal (dorsomedial + dorsolateral) prefrontal cortex';
     case {'pfcm'}
       AreaNameStr{j} = 'Medial prefrontal cortex';
     case {'lpfcm'}
       AreaNameStr{j} = 'Left Medial prefrontal cortex';
     case {'rpfcm'}
       AreaNameStr{j} = 'Right Medial prefrontal cortex';
     case {'pfcom'}
       AreaNameStr{j} = 'Orbitomedial prefrontal cortex';
     case {'lpfcom'}
       AreaNameStr{j} = 'Left Orbitomedial prefrontal cortex';
     case {'rpfcom'}
       AreaNameStr{j} = 'Right Orbitomedial prefrontal cortex';
     case {'pfcorb'}
       AreaNameStr{j} = 'Orbitofrontal cortex';
     case {'lpfcorb'}
       AreaNameStr{j} = 'Left Orbitofrontal cortex';
     case {'rpfcorb'}
       AreaNameStr{j} = 'Right Orbitofrontal cortex';
     case {'pfcpol'}
       AreaNameStr{j} = 'prefrontal pole';
     case {'lpfcpol'}
       AreaNameStr{j} = 'left prefrontal pole';
     case {'rpfcpol'}
       AreaNameStr{j} = 'right prefrontal pole';
     case {'pfcol'}
       AreaNameStr{j} = 'Orbitolateral prefrontal cortex';
     case {'lpfcol'}
       AreaNameStr{j} = 'Left Orbitolateral prefrontal cortex';
     case {'rpfcol'}
       AreaNameStr{j} = 'Right Orbitolateral prefrontal cortex';
     case {'pfcvl'}
       AreaNameStr{j} = 'Ventrolateral prefrontal cortex';
     case {'lpfcvl'}
       AreaNameStr{j} = 'Left Ventrolateral prefrontal cortex';
     case {'rpfcvl'}
       AreaNameStr{j} = 'Right Ventrolateral prefrontal cortex';
     case {'pfcoi'}
       AreaNameStr{j} = 'intermediate orbitofrontal cortex:';
     case {'lpfcoi'}
       AreaNameStr{j} = 'left intermediate orbitofrontal cortex:';
     case {'rpfcoi'}
       AreaNameStr{j} = 'right intermediate orbitofrontal cortex:';
     case {'phc'}
       AreaNameStr{j} = 'Parahippocampal cortex';
     case {'lphc'}
       AreaNameStr{j} = 'Left Parahippocampal cortex';
     case {'rphc'}
       AreaNameStr{j} = 'Right Parahippocampal cortex';
     case {'pmcdl'}
       AreaNameStr{j} = 'dorsolateral premotor cortex:';
     case {'lpmcdl'}
       AreaNameStr{j} = 'left dorsolateral premotor cortex:';
     case {'rpmcdl'}
       AreaNameStr{j} = 'right dorsolateral premotor cortex:';
     case {'pmcm'}
       AreaNameStr{j} = 'Medial (supplementary) premotor cortex';
     case {'lpmcm'}
       AreaNameStr{j} = 'Left Medial (supplementary) premotor cortex';
     case {'rpmcm'}
       AreaNameStr{j} = 'Right Medial (supplementary) premotor cortex';
     case {'pmcvl'}
       AreaNameStr{j} = 'Ventrolateral premotor cortex';
     case {'lpmcvl'}
       AreaNameStr{j} = 'Left Ventrolateral premotor cortex';
     case {'rpmcvl'}
       AreaNameStr{j} = 'Right Ventrolateral premotor cortex';
     case {'s1'}
       AreaNameStr{j} = 'Primary somatosensory cortex';
     case {'ls1'}
       AreaNameStr{j} = 'Left Primary somatosensory cortex';
     case {'rs1'}
       AreaNameStr{j} = 'Right Primary somatosensory cortex';
     case {'s2'}
       AreaNameStr{j} = 'Secondary somatosensory cortex';
     case {'ls2'}
       AreaNameStr{j} = 'Left Secondary somatosensory cortex';
     case {'rs2'}
       AreaNameStr{j} = 'Right Secondary somatosensory cortex';
     case {'tcc'}
       AreaNameStr{j} = 'Central temporal cortex (in the STS and partially on the convexity below)';
     case {'ltcc'}
       AreaNameStr{j} = 'Left Central temporal cortex (in the STS and partially on the convexity below)';
     case {'rtcc'}
       AreaNameStr{j} = 'Right Central temporal cortex (in the STS and partially on the convexity below)';
     case {'tci'}
       AreaNameStr{j} = 'Inferotemporal cortex';
     case {'ltci'}
       AreaNameStr{j} = 'Left Inferotemporal cortex';
     case {'rtci'}
       AreaNameStr{j} = 'Right Inferotemporal cortex';
     case {'tcpol'}
       AreaNameStr{j} = 'Temporal pole';
     case {'ltcpol'}
       AreaNameStr{j} = 'Left Temporal pole';
     case {'rtcpol'}
       AreaNameStr{j} = 'Right Temporal pole';
     case {'tcs'}
       AreaNameStr{j} = 'Superior temporal cortex (excl. STS and primary + secondary auditory cortex)';
     case {'ltcs'}
       AreaNameStr{j} = 'Left Superior temporal cortex (excl. STS and primary + secondary auditory cortex)';
     case {'rtcs'}
       AreaNameStr{j} = 'Right Superior temporal cortex (excl. STS and primary + secondary auditory cortex)';
     case {'tcv'}
       AreaNameStr{j} = 'Ventral temporal cortex';
     case {'ltcv'}
       AreaNameStr{j} = 'Left Ventral temporal cortex';
     case {'rtcv'}
       AreaNameStr{j} = 'Right Ventral temporal cortex';
     case {'v1'}
       AreaNameStr{j} = 'Primary visual cortex';
     case {'lv1'}
       AreaNameStr{j} = 'Left Primary visual cortex';
     case {'rv1'}
       AreaNameStr{j} = 'Right Primary visual cortex';
     case {'v2'}
       AreaNameStr{j} = 'Secondary visual cortex';
     case {'lv2'}
       AreaNameStr{j} = 'Left Secondary visual cortex';
     case {'rv2'}
       AreaNameStr{j} = 'Right Secondary visual cortex';
     case {'vacd'}
       AreaNameStr{j} = 'Dorsal part of anterior visual cortex';
     case {'lvacd'}
       AreaNameStr{j} = 'Left Dorsal part of anterior visual cortex';
     case {'rvacd'}
       AreaNameStr{j} = 'Right Dorsal part of anterior visual cortex';
     case {'vacv'}
       AreaNameStr{j} = 'Ventral part of anterior visual cortex';
     case {'lvacv'}
       AreaNameStr{j} = 'Left Ventral part of anterior visual cortex';
     case {'rvacv'}
       AreaNameStr{j} = 'Right Ventral part of anterior visual cortex';
     case {'vac'}
       AreaNameStr{j} = 'Anterior visual cortex';
     case {'lvac'}
       AreaNameStr{j} = 'Left Anterior visual cortex';
     case {'rvac'}
       AreaNameStr{j} = 'Right Anterior visual cortex';
     case {'pulvinar'}
       AreaNameStr{j} = 'Pulvinar thalamic nucleus';
     case {'lpulvinar'}
       AreaNameStr{j} = 'Left Pulvinar thalamic nucleus';
     case {'rpulvinar'}
       AreaNameStr{j} = 'Right Pulvinar thalamic nucleus';
     case {'thalam'}
       AreaNameStr{j} = 'Anteromedial thalamic nucleus';
     case {'lthalam'}
       AreaNameStr{j} = 'Left Anteromedial thalamic nucleus';
     case {'rthalam'}
       AreaNameStr{j} = 'Right Anteromedial thalamic nucleus';
%Hagmann etal Left
     case {'lbsts'}
       AreaNameStr{j} = 'Left bank of the superior temporal sulcus';
     case {'lcac'}
       AreaNameStr{j} = 'Left caudal anterior cingulate cortex';
     case {'lcmf'}
       AreaNameStr{j} = 'Left caudal middle frontal cortex';
     case {'lcun'}
       AreaNameStr{j} = 'Left cuneus';
     case {'lent'}
       AreaNameStr{j} = 'Left entorhinal cortex';
     case {'lfp'}
       AreaNameStr{j} = 'Left frontal pole';
     case {'lfus'}
       AreaNameStr{j} = 'Left fusiform gyrus';
     case {'lip'}
       AreaNameStr{j} = 'Left inferior parietal cortex';
     case {'lit'}
       AreaNameStr{j} = 'Left inferior temporal cortex';
     case {'listc'}
       AreaNameStr{j} = 'Left isthmus of the cingulate cortex';
     case {'llocc'}
       AreaNameStr{j} = 'Left lateral occipital cortex';
     case {'llof'}
       AreaNameStr{j} = 'Left lateral orbitofrontal cortex';
     case {'lling'}
       AreaNameStr{j} = 'Left lingual gyrus';
     case {'lmof'}
       AreaNameStr{j} = 'Left medial orbitofrontal cortex';
     case {'lmt'}
       AreaNameStr{j} = 'Left middle temporal cortex';
     case {'lparc'}
       AreaNameStr{j} = 'Left Paracentral lobule';
     case {'lparh'}
       AreaNameStr{j} = 'Left parahippocampal cortex';
     case {'lpope'}
       AreaNameStr{j} = 'Left pars opercularis';
     case {'lporb'}
       AreaNameStr{j} = 'Left pars orbitalis';
     case {'lptri'}
       AreaNameStr{j} = 'Left pars triangularis';
     case {'lpcal'}
       AreaNameStr{j} = 'Left pericalcarine cortex';
     case {'lpstc'} %THIS WAS A TYPO IN FIGURE 1 OF THE HAGMANN PAPER
       AreaNameStr{j} = 'Left postcentral gyrus';
     case {'lpc'}
       AreaNameStr{j} = 'Left posterior cingulate cortex';
     case {'lprec'}
       AreaNameStr{j} = 'Left precentral gyrus';
     case {'lpcun'}
       AreaNameStr{j} = 'Left precuneus';
     case {'lrac'}
       AreaNameStr{j} = 'Left rostral anterior cingulate cortex';
     case {'lrmf'}
       AreaNameStr{j} = 'Left rostral middle frontal cortex';
     case {'lsf'}
       AreaNameStr{j} = 'Left superior frontal cortex';
     case {'lsp'}
       AreaNameStr{j} = 'Left superior parietal cortex';
     case {'lst'}
       AreaNameStr{j} = 'Left superior temporal cortex';
     case {'lsmar'}
       AreaNameStr{j} = 'Left supramarginal gyrus';
     case {'ltp'}
       AreaNameStr{j} = 'Left temporal pole';
     case {'ltt'}
       AreaNameStr{j} = 'Left transverse temporal cortex';
%Hagmann etal Right
     case {'rbsts'}
       AreaNameStr{j} = 'Right bank of the superior temporal sulcus';
     case {'rcac'}
       AreaNameStr{j} = 'Right caudal anterior cingulate cortex';
     case {'rcmf'}
       AreaNameStr{j} = 'Right caudal middle frontal cortex';
     case {'rcun'}
       AreaNameStr{j} = 'Right cuneus';
     case {'rent'}
       AreaNameStr{j} = 'Right entorhinal cortex';
     case {'rfp'}
       AreaNameStr{j} = 'Right frontal pole';
     case {'rfus'}
       AreaNameStr{j} = 'Right fusiform gyrus';
     case {'rip'}
       AreaNameStr{j} = 'Right inferior parietal cortex';
     case {'rit'}
       AreaNameStr{j} = 'Right inferior temporal cortex';
     case {'ristc'}
       AreaNameStr{j} = 'Right isthmus of the cingulate cortex';
     case {'rlocc'}
       AreaNameStr{j} = 'Right lateral occipital cortex';
     case {'rlof'}
       AreaNameStr{j} = 'Right lateral orbitofrontal cortex';
     case {'rling'}
       AreaNameStr{j} = 'Right lingual gyrus';
     case {'rmof'}
       AreaNameStr{j} = 'Right medial orbitofrontal cortex';
     case {'rmt'}
       AreaNameStr{j} = 'Right middle temporal cortex';
     case {'rparc'}
       AreaNameStr{j} = 'Right Paracentral lobule';
     case {'rparh'}
       AreaNameStr{j} = 'Right parahippocampal cortex';
     case {'rpope'}
       AreaNameStr{j} = 'Right pars opercularis';
     case {'rporb'}
       AreaNameStr{j} = 'Right pars orbitalis';
     case {'rptri'}
       AreaNameStr{j} = 'Right pars triangularis';
     case {'rpcal'}
       AreaNameStr{j} = 'Right pericalcarine cortex';
     case {'rpstc'} %THIS WAS A TYPO IN FIGURE 1 OF THE HAGMANN PAPER
       AreaNameStr{j} = 'Right postcentral gyrus';
     case {'rpc'}
       AreaNameStr{j} = 'Right posterior cingulate cortex';
     case {'rprec'}
       AreaNameStr{j} = 'Right precentral gyrus';
     case {'rpcun'}
       AreaNameStr{j} = 'Right precuneus';
     case {'rrac'}
       AreaNameStr{j} = 'Right rostral anterior cingulate cortex';
     case {'rrmf'}
       AreaNameStr{j} = 'Right rostral middle frontal cortex';
     case {'rsf'}
       AreaNameStr{j} = 'Right superior frontal cortex';
     case {'rsp'}
       AreaNameStr{j} = 'Right superior parietal cortex';
     case {'rst'}
       AreaNameStr{j} = 'Right superior temporal cortex';
     case {'rsmar'}
       AreaNameStr{j} = 'Right supramarginal gyrus';
     case {'rtp'}
       AreaNameStr{j} = 'Right temporal pole';
     case {'rtt'}
       AreaNameStr{j} = 'Right transverse temporal cortex';


     otherwise
       AreaNameStr{j} = 'Unrecognised area...';

   end
 end
    
end %function GetAreaNames()


