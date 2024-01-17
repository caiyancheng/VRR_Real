% Plancherel theorem test

N = 2000;
N2 = N/2;
sz = 20;

disc_F = @(radius, rho) (2/sz)*radius.*sinc(2*rho.*radius);
%disc_F = @(radius, rho) radius.*sinc(2*rho.*radius);

r=0.1;
xx = linspace( -sz/2, sz/2, N );

Nyq_freq = 0.5*N/sz;
rho = linspace( 0, Nyq_freq - Nyq_freq/N2, N2 );

rho_full = [rho -linspace( Nyq_freq, Nyq_freq/N2, N2 )];

Dl = abs(xx)<r;

Dl_F = fft(Dl)/numel(Dl);

clf;
plot( rho, abs(Dl_F(1:N2)) );
hold on
plot( rho, abs(disc_F(r,rho)) );
hold off

%rho_p = linspace( 0, 0.5, N/2 );

% Plancherel theorem
l = trapz( xx, Dl.^2 )
l_F_fft = 2*trapz( rho, abs(Dl_F(1:(N/2))).^2 )*sz^2
l_F_analytical = 2*trapz( rho, abs(disc_F(r,rho)).^2 )*sz^2


l_F = trapz( fftshift(rho_full), abs(fftshift(Dl_F)).^2 )*sz^2
