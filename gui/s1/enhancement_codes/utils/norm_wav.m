function [data] = norm_wav(data)
nbits = 16;
data = data - mean(data);
nbits = nbits -1; % one less, as half for positive and half of negative bits
scale  = (2^nbits-1)/2^nbits;

data = data/max(abs(data)) * scale;
