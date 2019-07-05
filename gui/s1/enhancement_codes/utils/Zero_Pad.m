function [ Data] = Zero_Pad( Data,Frame_Size,Overlap_Ratio )

[No_Ch Len_Data] = size(Data);

if(No_Ch>Len_Data)
    Data = Data.';
    [No_Ch Len_Data] = size(Data);
end;
    

Non_Overlap_Samples = Frame_Size*(1-Overlap_Ratio);
%------------------------Zero Padding Data---------------------------------
No_Frames = ceil((Len_Data-Frame_Size)/Non_Overlap_Samples) + 1;
No_Zeros = (No_Frames-1)*Non_Overlap_Samples + Frame_Size - Len_Data;
Data = [Data zeros(No_Ch,No_Zeros)];

end

