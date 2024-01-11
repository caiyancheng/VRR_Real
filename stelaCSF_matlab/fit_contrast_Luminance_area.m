jsonText = fileread('B:\Py_codes\VRR_Real\dL_L/fit_dl_L_curve_poly_noabs_size.json');
jsonData = jsondecode(jsonText);
X_vector_filter = jsonData.X_filter;
Y_vector_filter = jsonData.Y_filter;
X_vector = jsonData.X;
Y_vector = jsonData.Y;

degree = 3;
coefficients = polyfitn(X_vector_filter, Y_vector_filter, degree);
disp(coefficients.Coefficients)
error = sum(Y_vector - polyvaln(coefficients, X_vector));
rmse = sqrt(mean(error.^2));
figure;
L_plot_vector = log10(logspace(log10(0.5),log10(10)))';
areas = [pi*0.5^2, pi*1^2, pi*16^2, 62.666 * 37.808];



hold on;
color = ['r', 'g', 'b', 'k'];
for i = 1:4
    area_log_value = log10(areas(i));
    area_plot_vector =  repmat(area_log_value, size(L_plot_vector));
    X_vector_plot = cat(2, L_plot_vector, area_plot_vector);
    Y_predicted = polyvaln(coefficients, X_vector_plot);
    scatter(X_vector((i-1)*30+1:i*30,1), Y_vector((i-1)*30+1:i*30), DisplayName=['area:' num2str(areas(i)) 'degree^2'], MarkerFaceColor=color(i));
    plot(X_vector_plot(:,1), Y_predicted, DisplayName=['area:' num2str(areas(i)) 'degree^2'], Color=color(i));
end
legend('show');

% 如果需要，你可以使用coefficients来计算任何X_vector值的拟合值
% Y_new = polyvaln(coefficients, X_new);

% 如果需要，你可以保存coefficients以供后续使用
save('coefficients.mat', 'coefficients');