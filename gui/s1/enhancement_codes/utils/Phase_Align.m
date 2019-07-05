function [ PA_Data ] = Phase_Align( Multi_STFT,TDOA,FFT_Size)

[No_Bins No_Frames No_Ch] = size(Multi_STFT);

%---------------------------Phase Align------------------------------------
PA_Data = zeros(No_Bins,No_Frames,No_Ch);

for i = 1:No_Frames
    for j = 1:No_Bins
        S_Vector = exp(-1i*2*pi*(j-1)*TDOA(i,:).'/FFT_Size);
        MC_Data  = reshape(Multi_STFT(j,i,:),[1 No_Ch]);
        PA_Data(j,i,:) = S_Vector'.*MC_Data;
    end;
end;

end

