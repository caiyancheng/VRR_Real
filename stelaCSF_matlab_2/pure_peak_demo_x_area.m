clear;
clc;
vrr_f_value = 8;
fit_poly_degree = 4;
luminance_value = 5;
area_contiuous = logspace(log10(0.2),log10(63*38),100);
CSF_names = ['stelaCSF', 'stelaCSF_HF', 'Barten_Original', 'Barten_HF', 'castleCSF', 'stelaCSF transient', 'stelaCSF_HF transient'];
S_stelaCSF_all = zeros(1,length(area_contiuous));
S_stelaCSF_HF_all = zeros(1,length(area_contiuous));
S_Barten_HF_all = zeros(1,length(area_contiuous));
S_Barten_Original_all = zeros(1,length(area_contiuous));
S_castleCSF_all = zeros(1,length(area_contiuous));
S_stelaCSF_transient_all = zeros(1,length(area_contiuous));
S_stelaCSF_HF_transient_all = zeros(1,length(area_contiuous));
stelaCSF_model = CSF_stelaCSF();
stelaCSF_HF_model = CSF_stelaCSF_HF();
Barten_Original_model = CSF_Barten_Original();
Barten_HF_model = CSF_Barten_HF();
castleCSF_model = CSF_castleCSF();
stelaCSF_transient_model = CSF_stelaCSF_transient();
stelaCSF_HF_transient_model = CSF_stelaCSF_HF_transient();
peak_spatial_frequency = logspace(log10(0.1), log10(100), 100)';
for area_index = 1:length(area_contiuous)
    area_value = area_contiuous(area_index);
    S_stelaCSF_all(area_index) = S_peak_generate(stelaCSF_model, peak_spatial_frequency, luminance_value, area_value, vrr_f_value);
    S_stelaCSF_HF_all(area_index) = S_peak_generate(stelaCSF_HF_model, peak_spatial_frequency, luminance_value, area_value, vrr_f_value);
    S_Barten_Original_all(area_index) = S_peak_generate(Barten_Original_model, peak_spatial_frequency, luminance_value, area_value, vrr_f_value);
    S_Barten_HF_all(area_index) = S_peak_generate(Barten_HF_model, peak_spatial_frequency, luminance_value, area_value, vrr_f_value);
    S_castleCSF_all(area_index) = S_peak_generate(castleCSF_model, peak_spatial_frequency, luminance_value, area_value, vrr_f_value);
    S_stelaCSF_transient_all(area_index) = S_peak_generate(stelaCSF_transient_model, peak_spatial_frequency, luminance_value, area_value, vrr_f_value);
    S_stelaCSF_HF_transient_all(area_index) = S_peak_generate(stelaCSF_HF_transient_model, peak_spatial_frequency, luminance_value, area_value, vrr_f_value);
end

figure;
plot(area_contiuous, S_stelaCSF_all.^2, 'DisplayName', 'stelaCSF');
hold on;
plot(area_contiuous, S_stelaCSF_HF_all.^2, 'DisplayName', 'stelaCSF_{HF}');
plot(area_contiuous, S_Barten_Original_all.^2, 'DisplayName', 'BartenCSF_{Original}');
plot(area_contiuous, S_Barten_HF_all.^2, 'DisplayName', 'BartenCSF_{HF}');
plot(area_contiuous, S_castleCSF_all.^2, 'DisplayName', 'castleCSF');
plot(area_contiuous, S_stelaCSF_transient_all.^2, 'DisplayName', 'stelaCSF transient');
plot(area_contiuous, S_stelaCSF_HF_transient_all.^2, 'DisplayName', 'stelaCSF_{HF} transient');
xlabel('Area (degree^2)');
ylabel('Sensitivity')
title([num2str(vrr_f_value) ' Hz, ' num2str(luminance_value) ' cd/m^2']);
xlim([0.2,63*38*1.2]);
legend('show');