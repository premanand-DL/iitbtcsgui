function [ DSB_Data, DSB] = DSB( Multi_STFT,SV_Spk)
% Performs Delay Sum Beamforming
% Multi_STFT - Multi Channel STFT of the input data
% TDOA - Time Difference of Arrival for each frame (No_Frame x No_Ch)
[No_Bins, No_Frames, No_Ch] = size(Multi_STFT);

%--------------------------------DSB---------------------------------------
DSB = zeros(No_Ch,No_Bins);
DSB_Data = zeros(No_Bins,No_Frames);

for j = 1:No_Bins
    DSB(:,j) =  SV_Spk(:,j)/(SV_Spk(:,j)'*SV_Spk(:,j));
    for i = 1:No_Frames
        MC_Data  = reshape(Multi_STFT(j,i,:),[No_Ch 1]);
        DSB_Data(j,i) = DSB(:,j)'*MC_Data;
    end;
end;

end

