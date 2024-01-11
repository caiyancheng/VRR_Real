function E = flicker_disc_energy_spatial( csf_model, omega, r )

disc_F = @(r, rho) r.*sinc(2*rho.*r);

rho = linspace( 0, 64, 10000 )'; % in cpd

csf_pars = struct();
csf_pars.t_frequency = omega;
csf_pars.luminance = 40;
csf_pars.s_frequency = rho;
csf_pars.ge_sigma = 1; 

S = csf_model.sensitivity(csf_pars);

c = 1;

I_F = c*disc_F(r,rho).*S;

I_S = fftshift(abs(fft( cat( 1, I_F, flipud(I_F(2:end,:)) ), [], 1 )), 1);
%I_S = abs(ifft( cat( 1, I_F, flipud(I_F(2:end,:)) ), [], 1 ));

ppd = rho(end)*2;
size_deg = size(I_S,1)/ppd;
yy = linspace( -size_deg/2, size_deg/2, size(I_S,1) )';

E = pi*trapz( yy, (I_S).^2 .* abs(yy) );

end
