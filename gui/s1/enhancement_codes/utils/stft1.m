function [f,fp] = stft1( x, sz, hp, pd, w)
% [f,fp] = stft( x, sz, hp, pd, w)
%x = signal
%sz = fft size
%hp = hopsize between adajcent frames (in points)
%pd = 0 padding (in points)
%w = window (optional; default is boxcar)
%Returns:
%f = stft (complex)
%fp = phase
%
%To reconstruct, x must be a complex array (i.e. an stft)
%                rest stays the same
%
% This code traces its ownership to several people from Media labs, MIT
%


% Forward transform
if isreal( x)
    x = x(:)';

	% Defaults
	if nargin < 5
		w = 1;
	end
	if nargin < 4
		pd = 0;
	end
	if nargin < 3
		hp = sz/2;
	end

	% Zero pad input
%	x = [x zeros( 1, ceil( length(x)/sz)*sz-length(x))];
        extra = (length(x)-sz)/hp;
        padding = ceil(extra)*hp + sz - length(x);
	x = [x zeros( 1, padding)];
%	x = [zeros( 1, sz+pd) x zeros( 1, sz+pd)];

	% Pack frames into matrix
	s = zeros( sz, (length(x)-sz)/hp);
	j = 1;
	for i = sz:hp:length( x)
		s(:,j) = w .* x((i-sz+1):i).';
		j = j + 1;
	end

	% FFT it
	f = fft( s, sz+pd);

	% Chop redundant part
	f = f(1:end/2+1,:);
	
	% Return phase component if asked to
	if nargout == 2
		fp = angle( f);
		fp = cos( fp) + sqrt(-1)*sin( fp);
	end

% Inverse transform
else

	% Defaults
	if nargin < 5
		w = 1;
	end
	if nargin < 4
		pd = 0;
	end
	if nargin < 3
		hp = sz/2;
	end

	% Ignore padded part
	if length( w) == sz
		w = [w; zeros( pd, 1)];
	end

	% Overlap add/window/replace conjugate part
	f = zeros( 1, (size(x,2)-1)*hp+sz+pd);
	v = 1:sz+pd;
	for i = 1:size( x,2)
		f((i-1)*hp+v) = f((i-1)*hp+v) + ...
			(w .* real( ifft( [x(:,i); conj( x(end-1:-1:2,i))])))';
	end

	% Norm for overlap
	f = f / (sz/hp);
	%f = f(sz+pd+1:end-sz-2*pd);
end
