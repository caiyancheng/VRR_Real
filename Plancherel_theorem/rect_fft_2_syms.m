syms r a theta rho;

% Define the signal
signal = @(theta) a * (heaviside(theta + r) - heaviside(theta - r));
% signal = a * (abs(theta) < r);

fourier_transform = fourier(signal, theta, rho);

simplify(abs(fourier_transform))
