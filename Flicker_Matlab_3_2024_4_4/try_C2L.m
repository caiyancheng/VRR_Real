degree_C2L = 7;
degree_L2C = 7;
CL_transform = Color2Luminance_LG_G1(degree_C2L, degree_L2C);

color_value = linspace(0, 1, 100);
L = zeros(size(color_value));
L_full = zeros(size(color_value));
for cv = 1:length(color_value)
    L(cv) = CL_transform.C2L(color_value(cv));
    L_full(cv) = CL_transform.C2L(color_value(cv), true);
end

figure;
plot(color_value, L);
hold on;
plot(color_value, L_full);
hold off;
xlabel('Color Value');
ylabel('Luminance');
legend('Standard', 'Full Screen');