clear;
clc;
size = 16;
radius = size/2;
area_value = pi*radius^2;
fit_poly_degree = 4;
luminance_value = 5;
vrr_f_contiuous = logspace(log10(0.2),log10(20),100);

stelaCSF_model = CSF_stelaCSF();
stelaCSF_HF_model = CSF_stelaCSF_HF();
Barten_HF_model = CSF_Barten_HF();
Barten_Original_model = CSF_Barten_Original();
castleCSF_model = CSF_castleCSF();
A_Daly_model = CSF_A_Daly();
stelaCSF_transient_model = CSF_stelaCSF_transient();
stelaCSF_HF_transient_model = CSF_stelaCSF_HF_transient();

csf_pars = struct('s_frequency', 0.1, 't_frequency', vrr_f_contiuous', 'orientation', 0, 'luminance', luminance_value, 'area', area_value, 'eccentricity', 0);
stelaCSF_result = stelaCSF_model.sensitivity(csf_pars);
stelaCSF_HF_result = stelaCSF_HF_model.sensitivity(csf_pars);
Barten_HF_result = Barten_HF_model.sensitivity(csf_pars);
Barten_Original_result = Barten_Original_model.sensitivity(csf_pars);
castleCSF_result = castleCSF_model.sensitivity(csf_pars);
A_Daly_result = A_Daly_model.sensitivity(csf_pars);
stelaCSF_transient_result = stelaCSF_transient_model.sensitivity(csf_pars);
stelaCSF_HF_transient_result = stelaCSF_HF_transient_model.sensitivity(csf_pars);

figure;
plot(vrr_f_contiuous, stelaCSF_result, 'DisplayName', 'stelaCSF');
hold on;
plot(vrr_f_contiuous, stelaCSF_HF_result, 'DisplayName', 'stelaCSF_{HF}');
plot(vrr_f_contiuous, Barten_HF_result, 'DisplayName', 'BartenCSF_{HF}');
plot(vrr_f_contiuous, Barten_Original_result, 'DisplayName', 'BartenCSF_{Original}');
plot(vrr_f_contiuous, castleCSF_result, 'DisplayName', 'castleCSF');
plot(vrr_f_contiuous, A_Daly_result, 'DisplayName', 'DalyCSF');
plot(vrr_f_contiuous, stelaCSF_transient_result, 'DisplayName', 'stelaCSF transient');
plot(vrr_f_contiuous, stelaCSF_HF_transient_result, 'DisplayName', 'stelaCSF_{HF} transient');
xlim([0.1,20]);
xlabel('Temporal Frequency (Hz)');
ylabel('Sensitivity');
title('Spatital Frequency 1 cpd')
legend('show');
