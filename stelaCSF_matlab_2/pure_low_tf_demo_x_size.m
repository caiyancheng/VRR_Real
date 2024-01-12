area_tick = [pi*0.25^2, pi*0.5^2, pi*8^2, 62 * 38];
vrr_f_value = 8;
fit_poly_degree = 4;
luminance_value = 5;
area_contiuous = logspace(log10(0.001),log10(62 * 38*1.3),1000);

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
stelacsf_transient_model = CSF_stelaCSF_transient();
stelacsf_mod_transient_model = CSF_stelaCSF_mod_transient();
barten_mod_model = CSF_stmBartenVeridical();

csf_pars = struct('s_frequency', 1, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance_value, 'area', area_contiuous', 'eccentricity', 0);
stelacsf_result = stelacsf_model.sensitivity(csf_pars);
stelacsf_mod_result = stelacsf_mod_model.sensitivity(csf_pars);
stelacsf_transient_result = stelacsf_transient_model.sensitivity(csf_pars);
stelacsf_mod_transient_result = stelacsf_mod_transient_model.sensitivity(csf_pars);
barten_mod_result = barten_mod_model.sensitivity(csf_pars);

figure;
plot(area_contiuous, stelacsf_result, 'DisplayName', 'stelaCSF');
hold on;
plot(area_contiuous, stelacsf_mod_result, 'DisplayName', 'stelaCSF_{HF}');
plot(area_contiuous, barten_mod_result, 'DisplayName', 'BartenCSF_{HF}');
plot(area_contiuous, stelacsf_transient_result, 'DisplayName', 'stelaCSF transient');
plot(area_contiuous, stelacsf_mod_transient_result, 'DisplayName', 'stelaCSF_{HF} transient');
xlim([0.1,62 * 38*1.3]);
xlabel('Area');
xticks(area_tick);
xscale('log');
ylabel('Sensitivity');
title('Spatital Frequency 1 cpd')
legend('show');
