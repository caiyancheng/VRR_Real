% size = 1;
% radius = size/2;
% area_value = pi*radius^2;
clear;
clc;
vrr_f_value = 8;
fit_poly_degree = 4;
luminance_value = 5;
area_contiuous = logspace(log10(0.2),log10(63*38),100);
CSF_names = ['stelaCSF', 'stelaCSF_HF', 'Barten_Original', 'Barten_HF', 'castleCSF', 'stelaCSF transient', 'stelaCSF_HF transient'];
E_stelaCSF_all = zeros(1,length(area_contiuous));
E_stelaCSF_HF_all = zeros(1,length(area_contiuous));
E_Barten_HF_all = zeros(1,length(area_contiuous));
E_Barten_Original_all = zeros(1,length(area_contiuous));
E_castleCSF_all = zeros(1,length(area_contiuous));
E_stelaCSF_transient_all = zeros(1,length(area_contiuous));
E_stelaCSF_HF_transient_all = zeros(1,length(area_contiuous));
stelaCSF_model = CSF_stelaCSF();
stelaCSF_HF_model = CSF_stelaCSF_HF();
Barten_Original_model = CSF_Barten_Original();
Barten_HF_model = CSF_Barten_HF();
castleCSF_model = CSF_castleCSF();
stelaCSF_transient_model = CSF_stelaCSF_transient();
stelaCSF_HF_transient_model = CSF_stelaCSF_HF_transient();

for area_index = 1:length(area_contiuous)
    area_value = area_contiuous(area_index);
    radius = (area_value/pi)^0.5;
    E_stelaCSF_all(area_index) = energy_model_fixarea_beta(stelaCSF_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value);
    E_stelaCSF_HF_all(area_index) = energy_model_fixarea_beta(stelaCSF_HF_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value);
    E_Barten_Original_all(area_index) = energy_model_fixarea_beta(Barten_Original_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value);
    E_Barten_HF_all(area_index) = energy_model_fixarea_beta(Barten_HF_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value);
    E_castleCSF_all(area_index) = energy_model_fixarea_beta(castleCSF_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value);
    E_stelaCSF_transient_all(area_index) = energy_model_fixarea_beta(stelaCSF_transient_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value);
    E_stelaCSF_HF_transient_all(area_index) = energy_model_fixarea_beta(stelaCSF_HF_transient_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value);
end

figure;
plot(area_contiuous, E_stelaCSF_all, 'DisplayName', 'stelaCSF');
hold on;
plot(area_contiuous, E_stelaCSF_HF_all, 'DisplayName', 'stelaCSF_{HF}');
% plot(area_contiuous, E_Barten_Original_all, 'DisplayName', 'BartenCSF_{Original}');
plot(area_contiuous, E_Barten_HF_all, 'DisplayName', 'BartenCSF_{HF}');
plot(area_contiuous, E_castleCSF_all, 'DisplayName', 'castleCSF');
plot(area_contiuous, E_stelaCSF_transient_all, 'DisplayName', 'stelaCSF transient');
plot(area_contiuous, E_stelaCSF_HF_transient_all, 'DisplayName', 'stelaCSF_{HF} transient');
xlabel('Area (degree^2)');
ylabel('Energy')
title([num2str(vrr_f_value) ' Hz, ' num2str(luminance_value) 'cd/m^2']);
% xlim([0.1,20]);
legend('show');