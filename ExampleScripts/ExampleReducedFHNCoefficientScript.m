%% Generate 6 seconds worth of time series for the RM_AC matrix at 1000000Hz. 
% Default FHN paramters produce oscilators at ~140Hz. By setting Velocity to
% 70 and reinterpreting the oscilations as ~14Hz and Velocity as 7 we
% effectively have 60 seconds of data. The factor of 10 in this 
% reinterpretation plus downsampling by 100 leaves us with 1 minute worth of 
% 1000Hz data, which we then save. 
% (Network of 38 nodes should take about 30min on a Desktop circa 2008)
%
%
% NOTE: This is a batch script example and so there is an exit at the end.
%

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
tic
 options.WhichModel = 'fhn';

 options.fhn.a = 0.45;
 mu = 0;       %Mean of the Normal distribution
 sigma = 0.35; %standard deviation of the Normal Distribution

 Nv = 150; %Resolution of Excitatory distribution (chosen in paper to match neuron count of "neuron level" simulation)
 Nu = 48;  %Resolution of Inhibitory distribution (chosen in paper to match neuron count of "neuron level" simulation)

%%%options.fhn.Zu = -(4*sigma):((8*sigma)/(Nu-1)):(4*sigma); %Produces equivalent g1 but changes normalisation of V  
%%%options.fhn.Zv = -(4*sigma):((8*sigma)/(Nv-1)):(4*sigma); %Produces equivalent g2 but changes normalisation of U  

%Get sampling based on the inverse CDF for a Normal PDF (~equiv of ordering Normally distributed random variates...) 
 stepu = 1/(Nu+2-1);
 stepv = 1/(Nv+2-1);
 options.fhn.Zu = NormCDFinv(stepu:stepu:(1-stepu), mu, sigma); %
 options.fhn.Zv = NormCDFinv(stepv:stepv:(1-stepv), mu, sigma); %

%Define the modes
 options.fhn.V(1,:) = [ ones(Nv/3,1) ; zeros(Nv/3,1) ; zeros(Nv/3,1)];     
 options.fhn.V(2,:) = [zeros(Nv/3,1) ;  ones(Nv/3,1) ; zeros(Nv/3,1)];  
 options.fhn.V(3,:) = [zeros(Nv/3,1) ; zeros(Nv/3,1) ;  ones(Nv/3,1)]; 
 options.fhn.U(1,:) = [ ones(Nu/3,1) ; zeros(Nu/3,1) ; zeros(Nu/3,1)];  
 options.fhn.U(2,:) = [zeros(Nu/3,1) ;  ones(Nu/3,1) ; zeros(Nu/3,1)];  
 options.fhn.U(3,:) = [zeros(Nu/3,1) ; zeros(Nu/3,1) ;  ones(Nu/3,1)];   

%Normalise the modes
 options.fhn.V = options.fhn.V ./ repmat(sqrt(trapz(options.fhn.Zv, options.fhn.V .* options.fhn.V, 2)), [1 Nv]);
 options.fhn.U = options.fhn.U ./ repmat(sqrt(trapz(options.fhn.Zu, options.fhn.U .* options.fhn.U, 2)), [1 Nu]);

%Get Normal PDF's evaluated with sampling Zv and Zu 
 options.fhn.g1 = NormPDF(options.fhn.Zv, mu, sigma); %
 options.fhn.g2 = NormPDF(options.fhn.Zu, mu, sigma); %

%Get the coefficients
 options = reduced_coefficients(options);

%Coupling with reduced population model
 options.K11 = 3;
 options.K12 = 0.6;
 options.K21 = options.K11;
 
 %Set network and integration options 
 Velocity = 70;  %Defaults produce ~140Hz FHN oscillators, a reinterpretation of  Velocity = 70 as Velocity = 7 coresponds to ~14Hz FHN oscillators.
 options.invel = 1/Velocity;
 
 options.csf = 0.00042;
 
 options.Qx = 0.001;
 options.Qy = 0.001;
 options.Qz = 0.001;
 options.Qw = 0.001;
 
%Load a connection matrix
 [weights delay] = GetConnectivity('RM_AC',options);

%Integrate the network 
 options.iters = 60000; %With the default dt(0.001) and reinterp intrinsic oscillations as ~10Hz this gives 1 minutes
 NumberOfModes = 3;
 N = 38;
 NumberOfDpts = options.iters;
 DSF = 100;
 
 Xi    = zeros(options.iters/10, 38, 3);
 Eta   = zeros(options.iters/10, 38, 3);
 Alpha = zeros(options.iters/10, 38, 3);
 Beta  = zeros(options.iters/10, 38, 3);
 t = zeros(1,options.iters*100);
 for j=1:100,
   [X Y Z W tt] = reduced_fhn_net_heun(weights,delay,options);
 
   Xi(1+((j-1)*options.iters/DSF):(j*options.iters/DSF),:,:)    = squeeze(mean(reshape(X, [DSF (NumberOfDpts/DSF) N NumberOfModes])));
   Eta(1+((j-1)*options.iters/DSF):(j*options.iters/DSF),:,:)   = squeeze(mean(reshape(Y, [DSF (NumberOfDpts/DSF) N NumberOfModes])));
   Alpha(1+((j-1)*options.iters/DSF):(j*options.iters/DSF),:,:) = squeeze(mean(reshape(Z, [DSF (NumberOfDpts/DSF) N NumberOfModes])));
   Beta(1+((j-1)*options.iters/DSF):(j*options.iters/DSF),:,:)  = squeeze(mean(reshape(W, [DSF (NumberOfDpts/DSF) N NumberOfModes])));
   
   t(1,1+((j-1)*options.iters):(j*options.iters)) = tt+t(max([1 (j-1)*options.iters]));
 end
 clear  X Y Z W tt 
 t = 10*t(((DSF/2)+1):DSF:end); %Factor of 10 is 
% % % %Crude downsample
% % %  [NumberOfDpts N NumberOfModes] = size(Xi); %
% % %  DSF = 100;      %Down sample factor
% % %  Xi    = squeeze(mean(reshape(Xi,    [DSF (NumberOfDpts/DSF) N NumberOfModes])));
% % %  Eta   = squeeze(mean(reshape(Eta,   [DSF (NumberOfDpts/DSF) N NumberOfModes])));
% % %  Alpha = squeeze(mean(reshape(Alpha, [DSF (NumberOfDpts/DSF) N NumberOfModes])));
% % %  Beta  = squeeze(mean(reshape(Beta,  [DSF (NumberOfDpts/DSF) N NumberOfModes])));
% % %  t = 10*t(((DSF/2)+1):DSF:end); %Factor of 10 is 
toc 
%% Save results to the directory of the invoking script
 save([ScriptDir Sep 'RM_AC_1min_default'])

%% When did we finish:
 CurrentTime = clock;
 disp(['Script ended on ' date ' at ' num2str(CurrentTime(4)) ':' num2str(CurrentTime(5)) ':' num2str(CurrentTime(6))])

%% Always exit at the end when batching... 
 exit
 
%%%EoF%%%