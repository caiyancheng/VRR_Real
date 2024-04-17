stelaCSF_model = CSF_stelaCSF();
castleCSF_model = CSF_castleCSF();

luminance = 10;
s_frequency = 1;
t_frequency = 1;
area = 1;
orientation = linspace(0,180,10);
csf_pars = struct('s_frequency', s_frequency, 't_frequency', 1, 'orientation', orientation', 'luminance', luminance, 'area', area, 'eccentricity', 3.2);
stelaCSF_sensitivity = stelaCSF_model.sensitivity(csf_pars);
castleCSF_sensitivity = castleCSF_model.sensitivity(csf_pars);
plot(orientation, stelaCSF_sensitivity', 'DisplayName', 'StelaCSF Sensitivity');
hold on;
plot(orientation, castleCSF_sensitivity', 'DisplayName', 'CastleCSF Sensitivity');
grid on;

xlabel('Orientation');
ylabel('Sensitivity');
title('CSF Sensitivity vs. Orientation');
legend('Location', 'best');