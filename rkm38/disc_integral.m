% Disc integral

N = 2048;
N2 = N/2;
sz = 20;

r=3;
xx = linspace( -sz/2, sz/2, N );
yy = linspace( -sz/2, sz/2, N )';

D = sqrt(xx.^2 + yy.^2)<r;

% The rect function
Dl = abs(xx)<r;

% The area of a disc
A = pi*r^2

% An integral in the polar coordinates
Al = pi*trapz( xx, Dl.*abs(xx))

% A 2D integral
A_2d = trapz( yy, trapz( xx, D, 2 ), 1 )

% The analitycal Fourier transform of a rect function
disc_F = @(radius, rho) (2/sz)*radius.*sinc(2*rho.*radius);

%[cyc/deg]
% 0.5*2024 / 20

Nyq_freq = 0.5*N/sz; % The Nyquist freqyency
rho = linspace( 0, Nyq_freq - Nyq_freq/N2, N2 );

clf;

d_F = disc_F(r,rho);

d_spatial = fftshift(ifft( cat( 2, d_F, fliplr( d_F(2:end) ) ) )*N);

plot( xx(1:(end-1)), abs(d_spatial) );
hold on
plot( xx, Dl );

hold off

A_1d = trapz( rho, disc_F(r, rho).^2 )*sz^2

A_F = 2*pi*trapz( rho, disc_F(r, rho).^2.*rho.^2 )*sz^2

