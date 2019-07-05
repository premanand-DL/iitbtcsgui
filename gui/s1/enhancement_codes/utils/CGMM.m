function [ R_N ] = CGMM(X,Init)
[nbin, nfram, nchan] = size(X);

%Initialisation
Prior_N = 0.25*ones(nbin,1); 

R_N= Init.Ncov;
R_NS = Init.NScov;

Lambda_N = zeros(nbin,nfram);
Phi_NS = zeros(nbin,nfram);
Phi_N = zeros(nbin,nfram);
Power_Bin =zeros(nbin,1);

for j = 1:nbin
    for k = 1:nfram
        y = permute(X(j,k,:),[3 1 2]);
        Power_Bin(j) = Power_Bin(j) + y'*y/nchan;
    end;
    Power_Bin(j) = Power_Bin(j)/nfram;
end;

for j = 1:nbin
    for k = 1:nfram
        y = permute(X(j,k,:),[3 1 2]);
        % Initialize Posteriors
        Lambda_N(j,k) = Prior_N(j)*ComplexGaussian(y,reshape(R_N(:,:,j),[nchan nchan]));
        Lambda_N(j,k) = Lambda_N(j,k)/ (Lambda_N(j,k) +(1-Prior_N(j))*ComplexGaussian(y,reshape(R_NS(:,:,j),[nchan nchan])));        
        
        %Initialize PSD Estimates
        Phi_NS(j,k) = (y'/R_NS(:,:,j)*y)/nchan;
        Phi_N(j,k) = (y'/R_N(:,:,j)*y)/nchan;
      
    end;
end;


% EM Algorithm - CGMM with 2 mixture components

for i = 1:20
    Message = sprintf('Iteration - %d', i) ;
    disp(Message);
    for j = 1:nbin
        % E-step - Posterior Probability
        for k = 1:nfram
            y = permute(X(j,k,:),[3 1 2]);
            P_N = Prior_N(j)*ComplexGaussian(y,Phi_N(j,k)*reshape(R_N(:,:,j),[nchan nchan]));
            P_NS = (1-Prior_N(j))*ComplexGaussian(y,Phi_NS(j,k)*reshape(R_NS(:,:,j),[nchan nchan]));
            Lambda_N(j,k) = P_N/(P_N + P_NS);
        end;

        % M-step
        R_NS(:,:,j) = zeros(nchan,nchan);
        R_N(:,:,j) = zeros(nchan,nchan);
        Prior_N(j) = 0;
        for k = 1:nfram
            y = permute(X(j,k,:),[3 1 2]);
            
            % Update PSD Estimates
            Phi_NS(j,k) = trace(y*y'/R_NS(:,:,j))/nchan;
            Phi_N(j,k) = trace(y*y'/R_N(:,:,j))/nchan;
            
            % Update Matrix Estimates
            R_NS(:,:,j) = R_NS(:,:,j) + (1-Lambda_N(j,k))*(y*y')/Phi_NS(j,k);
            R_N(:,:,j) = R_N(:,:,j) + Lambda_N(j,k)*(y*y')/Phi_N(j,k);
            
            % Update Noise Priors
            Prior_N(j) = Prior_N(j) + Lambda_N(j,k);
        end;
        Prior_N(j) = Prior_N(j)/nfram;
        R_N(:,:,j) = R_N(:,:,j)/sum(Lambda_N(j,:));
        R_NS(:,:,j) = R_NS(:,:,j)/sum(1-Lambda_N(j,:));
    end;
end;
return

function [P] = ComplexGaussian(y,R)
    P = exp(-y'/R*y)/(det(pi*R));
end

end
