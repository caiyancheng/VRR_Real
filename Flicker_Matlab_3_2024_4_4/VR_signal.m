refresh_rate = 60;
persistence = 0.1;
one_frame_time = 1/refresh_rate;
x_t_slice = linspace(0, one_frame_time,100);
y_luminance_slice = zeros(size(x_t_slice));
y_luminance_slice(0:100*persistence) = 1;

plot(x_t_slice, y_luminance_slice);