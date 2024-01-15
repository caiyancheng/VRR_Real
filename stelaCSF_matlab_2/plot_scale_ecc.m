ecc_s = linspace(0,100,100);
scale_s = get_scale_from_ecc_simple(ecc_s);
figure;
plot(ecc_s, scale_s);
xlabel('Eccentricity');
ylabel('Sensitivity Scale');