% Disc integral

N = 2048;

r=3;
xx = linspace( -10, 10, N );
yy = linspace( -10, 10, N )';

D = sqrt(xx.^2 + yy.^2)<r;

Dl = abs(xx)<r;

A = pi*r^2

Al = pi*trapz( xx, Dl.*abs(xx))

A_2d = trapz( yy, trapz( xx, D, 2 ), 1 )

disc_F = @(radius, rho) 0.1*radius.*sinc(2*rho.*radius);

%[cyc/deg]
% 0.5*2024 / 20

rho = linspace( 0, 0.5*N/20, N/2 );

clf;

d_F = disc_F(r,rho);

d_spatial = fftshift(ifft( cat( 2, d_F, fliplr( d_F(2:end) ) ) ));

plot( xx(1:(end-1)), abs(d_spatial) );
hold on
plot( xx, Dl );

hold off

A_F = 2*pi*trapz( rho, disc_F(r, rho).^2.*rho )*400

% l = trapz( xx, Dl.^2 )
% Dl_F = fft(Dl)/numel(Dl);
% rho_p = linspace( 0, 0.5, N/2 );
% l_F = 2*trapz( rho, abs(Dl_F(1:N/2)).^2 )*400