function [ Y ] = MVDR( X,TDOA,IS)
% Performs Multi Channel Alignment
% Multi_STFT - Multi Channel STFT of the input data
% TDOA - Time Difference of Arrival for each frame (No_Frame x No_Ch)
[nbin, nfram, nchan] = size(X);
FFT_Size = (nbin-1)*2;

%--------------------------------MVDR--------------------------------------

Mu = 1e-3;
Energy = permute(mean(abs(X).^2,2),[3 1 2]);
Y = zeros(nbin,nfram);

%-----------------------------Noise Covariance Matrix----------------------
Ncov=zeros(nchan,nchan,nbin);
for f=1:nbin,
    for n=1:IS,
        Ntf=permute(X(f,n,:),[3 1 2]);
        Ncov(:,:,f)=Ncov(:,:,f)+Ntf*Ntf';
    end
    Ncov(:,:,f)=Ncov(:,:,f)/IS;
end


for i = 1:nfram
    for j = 1:nbin
        S_Vector = exp(-1i*2*pi*(j-1)*TDOA(:,i)/FFT_Size);
        % Compute the Noise Coherence matrix
        Inv_Cov = inv(Ncov(:,:,j)+Mu*diag(Energy(:,j)));
        % MVDR beamforming
        MVDR = Inv_Cov*S_Vector/(S_Vector'*Inv_Cov*S_Vector);
        Y(j,i) = MVDR'*reshape(X(j,i,:),[nchan 1]);
    end
end

end
