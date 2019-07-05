function [ Inv_Cov ] = Est_Cov( Multi_STFT,Flag,Eps)

[No_Bins No_Frames No_Ch] = size(Multi_STFT);

%----------------%----------Output Covariance Matrix-------%---------------
N_Cov = zeros(No_Ch,No_Ch,No_Bins);
Inv_Cov = zeros(No_Ch,No_Ch,No_Bins);
                             
for i = 1:No_Bins
    for j = 1:No_Frames
        N_Data = reshape(Multi_STFT(i,j,:),[No_Ch 1]);
        N_Cov(:,:,i) = N_Cov(:,:,i) + N_Data*N_Data'/(No_Frames);
    end;
    if(Flag==1)
        Inv_Cov(:,:,i) = inv((N_Cov(:,:,i)+Eps*eye(No_Ch)));
    else
        Inv_Cov(:,:,i) = N_Cov(:,:,i);
    end;
end;


end

