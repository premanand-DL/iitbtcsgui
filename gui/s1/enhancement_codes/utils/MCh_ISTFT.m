function [ SC_Data ] = MCh_ISTFT( BF_Data,Frame_Size,Overlap_Ratio,Len_Data,Win_No)

[No_Bins No_Frames] = size(BF_Data);

Non_Overlap_Samples = Frame_Size*(1-Overlap_Ratio);

Win = sin((.5:Frame_Size-.5)*pi/Frame_Size);

%------------%-----------Normalizing Window-----------------%--------------
Sample = zeros(1,Len_Data);
for i = 1:No_Frames
        Start = (i-1)*Non_Overlap_Samples + 1;
        Fin = (i-1)*Non_Overlap_Samples + Frame_Size;  
        Sample(Start:Fin) = Sample(Start:Fin) + Win.^2;
end;
Sample = sqrt(Sample);%*Frame_Size);

SC_Data = zeros(1,Len_Data);
for i = 1:No_Frames
    Start = (i-1)*Non_Overlap_Samples + 1;
    Fin = (i-1)*Non_Overlap_Samples + Frame_Size;     
    Frame = ifft([BF_Data(:,i).' conj(BF_Data(No_Bins-1:-1:2,i)).']);
    Frame = real(Frame(1:Frame_Size));
    if(Win_No == 1)
        SC_Data(Start:Fin) = SC_Data(Start:Fin) + Frame.*Win./Sample(Start:Fin);
    else
        SC_Data(Start:Fin) = SC_Data(Start:Fin) + Frame;
    end;
end;


end

