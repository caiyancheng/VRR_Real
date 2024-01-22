syms W N r a theta rho k n_1;

% 定义信号函数
signal = -a*cos(2*pi/N*k*n_1);

% 设置求和范围
start_value = -N*r/W;
end_value = N*r/W;

% 使用symsum求和
sum_result = symsum(signal, n_1, start_value, end_value);

simplify(sum_result)
