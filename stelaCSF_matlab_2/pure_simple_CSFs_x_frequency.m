size = 16;
radius = size/2;
area_value = pi*radius^2;
fit_poly_degree = 4;
luminance_value = 2;
s_frequency_s = logspace(log10(0.0001),log10(2),16);
vrr_f_contiuous = logspace(log10(0.2),log10(20),100);

CSF_names = ['stelaCSF', 'stelaCSF_HF', 'Barten_Original', 'Barten_HF', 'castleCSF', 'stelaCSF transient', 'stelaCSF_HF transient'];
S_stelaCSF_all = zeros(length(s_frequency_s),length(vrr_f_contiuous));
S_stelaCSF_HF_all = zeros(length(s_frequency_s),length(vrr_f_contiuous));
S_Barten_HF_all = zeros(length(s_frequency_s),length(vrr_f_contiuous));
S_Barten_Original_all = zeros(length(s_frequency_s),length(vrr_f_contiuous));
S_castleCSF_all = zeros(length(s_frequency_s),length(vrr_f_contiuous));
S_stelaCSF_transient_all = zeros(length(s_frequency_s),length(vrr_f_contiuous));
S_stelaCSF_HF_transient_all = zeros(length(s_frequency_s),length(vrr_f_contiuous));
stelaCSF_model = CSF_stelaCSF();
stelaCSF_HF_model = CSF_stelaCSF_HF();
Barten_Original_model = CSF_Barten_Original();
Barten_HF_model = CSF_Barten_HF();
castleCSF_model = CSF_castleCSF();
stelaCSF_transient_model = CSF_stelaCSF_transient();
stelaCSF_HF_transient_model = CSF_stelaCSF_HF_transient();

for s_f_index = 1:length(s_frequency_s)
    for vrr_f_index = 1:length(vrr_f_contiuous)
        vrr_f_value = vrr_f_contiuous(vrr_f_index);
        s_frequency_value = s_frequency_s(s_f_index);
        csf_pars = struct('s_frequency', s_frequency_value, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance_value, 'area', area_value, 'eccentricity', 0);
        S_stelaCSF_all(s_f_index,vrr_f_index) = stelaCSF_model.sensitivity(csf_pars);
        S_stelaCSF_HF_all(s_f_index,vrr_f_index) = stelaCSF_HF_model.sensitivity(csf_pars);
        S_Barten_Original_all(s_f_index,vrr_f_index) = Barten_Original_model.sensitivity(csf_pars);
        S_Barten_HF_all(s_f_index,vrr_f_index) = Barten_HF_model.sensitivity(csf_pars);
        S_castleCSF_all(s_f_index,vrr_f_index) = castleCSF_model.sensitivity(csf_pars);
        S_stelaCSF_transient_all(s_f_index,vrr_f_index) = stelaCSF_transient_model.sensitivity(csf_pars);
        S_stelaCSF_HF_transient_all(s_f_index,vrr_f_index) = stelaCSF_HF_transient_model.sensitivity(csf_pars);
    end
end

figure;
ha = tight_subplot(4, 4, [.07 .02],[.1 .05],[.035 .01]);
set(ha,'YTick',[0.005, 0.01, 0.05, 0.1]);
set(ha,'YTickLabel',[0.005, 0.01, 0.05, 0.1]);
set(ha,'XTick',[0.5, 1, 2, 4, 8]);
set(ha,'XTickLabel',[0.5, 1, 2, 4, 8]);

for s_f_index = 1:length(s_frequency_s)
    s_frequency_value = s_frequency_s(s_f_index);
    axes(ha(s_f_index));
    xlim([0.25, 20]);
    ylim([0.005, 0.1]);
    plot(vrr_f_contiuous, S_stelaCSF_all(s_f_index,:), 'DisplayName', 'stelaCSF');
    hold on;
    plot(vrr_f_contiuous, S_stelaCSF_HF_all(s_f_index,:), 'DisplayName', 'stelaCSF_{HF}');
    plot(vrr_f_contiuous, S_Barten_Original_all(s_f_index,:), 'DisplayName', 'BartenCSF_{Original}');
    plot(vrr_f_contiuous, S_Barten_HF_all(s_f_index,:), 'DisplayName', 'BartenCSF_{HF}');
    plot(vrr_f_contiuous, S_castleCSF_all(s_f_index,:), 'DisplayName', 'castleCSF');
    plot(vrr_f_contiuous, S_stelaCSF_transient_all(s_f_index,:), 'DisplayName', 'stelaCSF transient');
    plot(vrr_f_contiuous, S_stelaCSF_HF_transient_all(s_f_index,:), 'DisplayName', 'stelaCSF_{HF} transient');
    xlabel('Frequency of RR Switch (Hz)');
    ylabel('Sensitivity')
    title([num2str(size) ' degree diameter, ' num2str(luminance_value) ' cd/m^2, ', num2str(s_frequency_value) ' cpd']);
end

hLegend = legend('show','FontSize',14);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'horizontal', 'NumColumns', 5);
legendPos = get(hLegend, 'Position');
legendPos(1) = 0.5 - legendPos(3)/2;
legendPos(2) = 0.06 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);