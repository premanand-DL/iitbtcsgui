function [ Auto_PSD Cross_PSD ] = Estimate_PSD( PA_Data )

[No_Bins No_Frames No_Ch] = size(PA_Data);

Auto_PSD = zeros(No_Bins,1);
Cross_PSD = zeros(No_Bins,1);

Alpha = 0.98;
for i = 1:No_Frames
    for j = 1:No_Ch
        for k = j:No_Ch
            if(j==k)
                Auto_PSD = Alpha*Auto_PSD + (1-Alpha)*PA_Data(:,i,j).*conj(PA_Data(:,i,k))/No_Frames;
            else
                Cross_PSD = Alpha*Cross_PSD + (1-Alpha)*PA_Data(:,i,j).*conj(PA_Data(:,i,k))/No_Frames;
            end;
        end;
    end;
end;

Auto_PSD = Auto_PSD/No_Ch;
Cross_PSD = real(Cross_PSD/(No_Ch*(No_Ch-1)/2));
                
end

