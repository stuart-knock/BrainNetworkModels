%% 
%
% NOTE: This is a batch script example and so there is an exit at the end.
%
%(Network of 38 nodes should take about 15min on a Desktop circa 2008)

%% Some details of our environment...
%Where is the code
 CodeDir = '..';        %can be full or relative directory path
 ScriptDir = pwd;       %get full path to this script
 cd(CodeDir)            %Change to code directory
 FullPathCodeDir = pwd; %get full path of CodeDir
 
%Get separator for this OS
 Sep = filesep;

%When and Where did we start:
 CurrentTime = clock;
 disp(['Script started on ' date ' at ' num2str(CurrentTime(4)) ':' num2str(CurrentTime(5)) ':' num2str(CurrentTime(6))]) 
 if strcmp(Sep,'/'), %on a *nix machine, then write machine details to our log...
   system('uname -a') 
 end 
 disp(['Script directory: ' ScriptDir])
 disp(['Code directory: ' FullPathCodeDir])
 
%% Do the stuff... 
%Which reduced model do we want the coefficients for: 
 options.WhichModel = 'hmr';
 
 options.hmr.r  =  0.006;
 options.hmr.s  =  4; 
 options.hmr.x0 = -1.6; 
 options.hmr.a  =  1;
 options.hmr.b  =  3; 
 options.hmr.c  =  1; 
 options.hmr.d  =  5; 
 
 mu    = 2.2; %Mean of the Normal distribution
 sigma = 0.3; %standard deviation of the Normal Distribution

 Nv = 150; %Resolution of Excitatory distribution (chosen in paper to match neuron count of "neuron level" simulation)
 Nu = 48;  %Resolution of Inhibitory distribution (chosen in paper to match neuron count of "neuron level" simulation)

%Get sampling based on the inverse CDF for a Normal PDF (~equiv of ordering Normally distributed random variates...) 
 stepu = 1/(Nu+2-1);
 stepv = 1/(Nv+2-1);
 options.hmr.Iu = NormCDFinv(stepu:stepu:(1-stepu), mu, sigma); %uniform in the CDF of I
 options.hmr.Iv = NormCDFinv(stepv:stepv:(1-stepv), mu, sigma); %uniform in the CDF of I

%Define the modes
 options.hmr.V(1,:) = [ ones(Nv/3,1) ; zeros(Nv/3,1) ; zeros(Nv/3,1)];     
 options.hmr.V(2,:) = [zeros(Nv/3,1) ;  ones(Nv/3,1) ; zeros(Nv/3,1)];  
 options.hmr.V(3,:) = [zeros(Nv/3,1) ; zeros(Nv/3,1) ;  ones(Nv/3,1)]; 
 options.hmr.U(1,:) = [ ones(Nu/3,1) ; zeros(Nu/3,1) ; zeros(Nu/3,1)];  
 options.hmr.U(2,:) = [zeros(Nu/3,1) ;  ones(Nu/3,1) ; zeros(Nu/3,1)];  
 options.hmr.U(3,:) = [zeros(Nu/3,1) ; zeros(Nu/3,1) ;  ones(Nu/3,1)];   

%Normalise the modes
 options.hmr.V = options.hmr.V ./ repmat(sqrt(trapz(options.hmr.Iv, options.hmr.V .* options.hmr.V, 2)), [1 Nv]);
 options.hmr.U = options.hmr.U ./ repmat(sqrt(trapz(options.hmr.Iu, options.hmr.U .* options.hmr.U, 2)), [1 Nu]);

%Get Normal PDF's evaluated with sampling Iv and Iu 
 options.hmr.g1 = NormPDF(options.hmr.Iv, mu, sigma); %
 options.hmr.g2 = NormPDF(options.hmr.Iu, mu, sigma); %

%Get the coefficients
 options = reduced_coefficients(options);

%% Save results to the directory of the invoking script
 save([ScriptDir Sep 'RM_AC_1min_default'])

%% When did we finish:
 CurrentTime = clock;
 disp(['Script ended on ' date ' at ' num2str(CurrentTime(4)) ':' num2str(CurrentTime(5)) ':' num2str(CurrentTime(6))])

%% Always exit at the end when batching... 
 exit
 
%%%EoF%%%