syms a r_0 rho r theta omega

% Define the signal in polar coordinates
f_polar = a * (1-heaviside(r - r_0)); % disk with the radius r_0

% Calculate the Fourier Transform
fourier_transform = fourier(f_polar, [r, theta], [rho, omega]);

simplify_fourier_transform = simplify(fourier_transform)
