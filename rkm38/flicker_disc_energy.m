function E = flicker_disc_energy( csf_model, omega, r )

% The Fourier transform of a rect
disc_F = @(r, rho) r.*sinc(2*rho.*r);

rho = linspace( 0, 64, 10000 )'; % in cpd

csf_pars = struct();
csf_pars.t_frequency = omega;
csf_pars.luminance = 40;
csf_pars.s_frequency = rho;
csf_pars.ge_sigma = 1; 

S = csf_model.sensitivity(csf_pars);

c = 1;

% rho below is the Jacobian determinant
E = 2*pi*trapz( rho, (c*disc_F(r,rho).*S).^2 .* rho );

end
