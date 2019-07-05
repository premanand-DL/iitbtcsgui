function [ Lag ] = Max_Lag( D,c,Fs )
    T = D/c;
    Lag = ceil(T*Fs);


end

