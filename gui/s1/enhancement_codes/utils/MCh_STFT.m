function [ Multi_STFT Len_Data] = MCh_STFT( Data,Frame_Size,FFT_Size,Overlap_Ratio,Win_No)

%Returns the multichannel STFT of the audio data in the format:
%No_Bins x No_Frames x No_Ch
%Input Parameters :
%Data - Audio Data
%Frame_Size - Size of the Window
%FFT_Size - N-Point FFT
%Overlap_Ratio - A value b/w 0 & 1 to specify the range of overlap
%Win_No -   1 Sine window 
%           2 Hanning window 
%           0 No Windowing   
%This function calls Zero_Pad to make the number of samples a multiple of
%Frame Size


%------------------------Frame Size and Overlap Size-----------------------
[No_Ch Len_Data] = size(Data);
Hop_Size = Frame_Size*(1-Overlap_Ratio);
No_Frames = (Len_Data-Frame_Size)/Hop_Size + 1;

%------------------------Multi Channel STFT--------------------------------
No_Bins = FFT_Size/2 +1;
Multi_STFT = zeros(No_Bins,No_Frames,No_Ch);

%------------%-----------Normalizing Window-----------------%--------------
Sample = zeros(1,Len_Data);
Win = sin((.5:Frame_Size-.5)*pi/Frame_Size);


for j = 1:No_Frames
        Start = (j-1)*Hop_Size + 1;
        Fin = (j-1)*Hop_Size + Frame_Size;  
        Sample(Start:Fin) = Sample(Start:Fin) + Win.^2;
end;
Sample = sqrt(Sample);

%------------------------Hanning Window------------------------------------
H_Win = hanning(Frame_Size)';

for i = 1:No_Ch
    for j = 1:No_Frames
        Start = (j-1)*Hop_Size + 1;
        Fin = (j-1)*Hop_Size + Frame_Size;
        if(Win_No == 1)
            Frame = Data(i,Start:Fin).*Win./Sample(Start:Fin);
        elseif(Win_No == 2)
            Frame = Data(i,Start:Fin).*H_Win;
        else
            Frame = Data(i,Start:Fin);
        end;
        Frame_FFT = fft(Frame,FFT_Size);
        Multi_STFT(:,j,i)= Frame_FFT(1:No_Bins);
   end;
end;


end

