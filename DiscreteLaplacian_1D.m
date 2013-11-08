%% Discrete Laplacian
% See, Abramowitz & Stegun, "Handbook of Mathematical Functions" : 
%      chapter 25. Numerical Interpolation, Differentiation, and Integration
% Implemetation of Disrete Laplacian operator... 
%

function M=DiscreteLaplacian_1D(N,bcs,n)
 M = zeros(N,N); 
 if nargin<3, n = 1; end
 if bcs==1;   %free bcs
   for i=1:N, 
     %M(i,(1+i):N) = 1./(1:(N-i));      %hyperbolic
     M(i,(1+i):N) = 1./((1:(N-i)).^n);
   end
   M = M+M';
 elseif bcs==2   %periodic bcs
   M(1,2:N) = max(1./((1:N-1).^n), 1./((N-1:-1:1).^n)); 
   for i=2:N, 
     M(i,(1+i):N) = M(1,2:N+1-i); 
   end
   M = M+M';
 else   %1st order expansion of div squared operator in 1D
   M = zeros(N,N);
   M(1:N-1,2:N) = eye(N-1,N-1);
   M(1,N) = 1;
   M = M+M';
   M = M - 2*eye(N,N);
 end
return;