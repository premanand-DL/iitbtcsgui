function [ Tau, R ] = Compute_GCC( Multi_STFT, Max_Delay)

[No_Bins No_Frames No_Ch] = size(Multi_STFT);
FFT_Size = (No_Bins-1)*2;

%% --------------------------------GCC-------------------------------------
Tau = zeros(No_Frames,No_Ch);

for j = 1:No_Frames
    FFT_X1 = Multi_STFT(:,j,1);
    for k = 1:No_Ch
        G_x1x2  = zeros(No_Bins,1);
        % Compute PSDS
        FFT_X2 = Multi_STFT(:,j,k);
        G_x1x2 = FFT_X1.*conj(FFT_X2);
        
        % Compute PHAT
        PHAT_Weight = 1./abs(G_x1x2);
        G_Hat = G_x1x2.*PHAT_Weight;
        G_Hat = [G_Hat; conj(G_Hat(No_Bins-1:-1:2))];
        R     = fftshift(ifft(G_Hat));
        [~, Index] = max(abs(R(FFT_Size/2+1-Max_Delay:FFT_Size/2+1+Max_Delay)));
        Tau(j,k) = -(Index-Max_Delay-1);
    end;
end;
end
