% 2D disc Fourier transform

N = 2048;
N2 = N/2;
sz = 20;

r=1;
xx = linspace( -sz/2, sz/2, N );
yy = linspace( -sz/2, sz/2, N )';

D = sqrt(xx.^2 + yy.^2)<r;

Nyq_freq = 0.5*N/sz;
rho = linspace( 0, Nyq_freq - Nyq_freq/N2, N2 );

rho_full = [rho -linspace( Nyq_freq, Nyq_freq/N2, N2 )];

disc_F = @(radius, rho) (1/sz)*radius.*sinc(2*rho.*radius);

rho_2d = sqrt(rho_full.^2 + (rho_full').^2);

D_F = disc_F(r,rho_2d);
D_F(abs(rho_2d)>sz/2) = 0;

D_Fd = fft2(D)/numel(D);

%D_iF = fftshift(fft2( D_F ));
%pfsview( abs(D_iF) )

rho_full_fs = fftshift(rho_full);

A_an = pi*r^2

A1 = 4*trapz( rho_full_fs, fftshift(abs(D_F(:,1)).^2), 1 )*sz^2

%A = 5*trapz( rho_full_fs, 4*trapz( rho_full_fs, fftshift(abs(D_F).^2), 1 )*sz^2, 2 )
A2 = sum(abs(D_F).^2,"all")*sz^2 
