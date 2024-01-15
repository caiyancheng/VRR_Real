size = 16;
radius = size/2;
area_value = pi*radius^2;
fit_poly_degree = 4;
luminance_value = 5;
vrr_f_contiuous = logspace(log10(0.2),log10(20),100);
CSF_names = ['stelaCSF', 'stelaCSF_HF', 'Barten_Original', 'Barten_HF', 'castleCSF', 'stelaCSF transient', 'stelaCSF_HF transient'];
E_stelaCSF_all = zeros(1,length(vrr_f_contiuous));
E_stelaCSF_HF_all = zeros(1,length(vrr_f_contiuous));
E_Barten_HF_all = zeros(1,length(vrr_f_contiuous));
E_Barten_Original_all = zeros(1,length(vrr_f_contiuous));
E_castleCSF_all = zeros(1,length(vrr_f_contiuous));
E_stelaCSF_transient_all = zeros(1,length(vrr_f_contiuous));
E_stelaCSF_HF_transient_all = zeros(1,length(vrr_f_contiuous));
stelaCSF_model = CSF_stelaCSF();
stelaCSF_HF_model = CSF_stelaCSF_HF();
Barten_Original_model = CSF_Barten_Original();
Barten_HF_model = CSF_Barten_HF();
castleCSF_model = CSF_castleCSF();
stelaCSF_transient_model = CSF_stelaCSF_transient();
stelaCSF_HF_transient_model = CSF_stelaCSF_HF_transient();
% energy_model = energy_model_spatial;
pow = 1;
for vrr_f_index = 1:length(vrr_f_contiuous)
    vrr_f_value = vrr_f_contiuous(vrr_f_index);
    E_stelaCSF_all(vrr_f_index) = energy_model_spatial(stelaCSF_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value, pow);
    E_stelaCSF_HF_all(vrr_f_index) = energy_model_spatial(stelaCSF_HF_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value, pow);
    E_Barten_Original_all(vrr_f_index) = energy_model_spatial(Barten_Original_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value, pow);
    E_Barten_HF_all(vrr_f_index) = energy_model_spatial(Barten_HF_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value, pow);
    E_castleCSF_all(vrr_f_index) = energy_model_spatial(castleCSF_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value, pow);
    E_stelaCSF_transient_all(vrr_f_index) = energy_model_spatial(stelaCSF_transient_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value, pow);
    E_stelaCSF_HF_transient_all(vrr_f_index) = energy_model_spatial(stelaCSF_HF_transient_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value, pow);
end

figure;
plot(vrr_f_contiuous, E_stelaCSF_all, 'DisplayName', 'stelaCSF');
hold on;
plot(vrr_f_contiuous, E_stelaCSF_HF_all, 'DisplayName', 'stelaCSF_{HF}');
plot(vrr_f_contiuous, E_Barten_Original_all, 'DisplayName', 'BartenCSF_{Original}');
plot(vrr_f_contiuous, E_Barten_HF_all, 'DisplayName', 'BartenCSF_{HF}');
plot(vrr_f_contiuous, E_castleCSF_all, 'DisplayName', 'castleCSF');
plot(vrr_f_contiuous, E_stelaCSF_transient_all, 'DisplayName', 'stelaCSF transient');
plot(vrr_f_contiuous, E_stelaCSF_HF_transient_all, 'DisplayName', 'stelaCSF_{HF} transient');
xlabel('Frequency of RR Switch (Hz)');
ylabel('Energy')
title([num2str(size) ' degree diameter, ' num2str(luminance_value) ' cd/m^2, spatial domain power = ' num2str(pow)]);
xlim([0.1,20]);
legend('show');