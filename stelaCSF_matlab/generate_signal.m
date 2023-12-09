function [horizontal_x, horizontal_y, vertical_x, vertical_y] = generate_signal(size_value, luminance, plot_flag)
    % Given constants
    screen_width = 1.2176;
    screen_height = 0.6849;
    distance = 1;

    % Function to generate rectangle signals
    function [x, y] = rectangle_signal(degree_down, degree_up, signal_degree_down, signal_degree_up, signal_I, sample_points)
        x = linspace(degree_down, degree_up, sample_points);
        y = zeros(size(x));
        y((x > signal_degree_down) & (x < signal_degree_up)) = signal_I;
    end

    size_radians = deg2rad(size_value);
    visual_degree_left = -atan(screen_width / (2 * distance));
    visual_degree_right = atan(screen_width / (2 * distance));
    visual_degree_down = -atan(screen_height / (2 * distance));
    visual_degree_up = atan(screen_height / (2 * distance));
    
    % Generate horizontal and vertical signals
    [horizontal_x, horizontal_y] = rectangle_signal(visual_degree_left, visual_degree_right, -size_radians / 2, size_radians / 2, luminance, 1000);
    [vertical_x, vertical_y] = rectangle_signal(visual_degree_down, visual_degree_up, -size_radians / 2, size_radians / 2, luminance, 1000);

    % Plot if required
    if plot_flag
        figure;
        plot(horizontal_x, horizontal_y);
        hold on;
        plot(vertical_x, vertical_y);
        legend('Horizontal', 'Vertical');
        xlabel('Visual Degree (radians)');
        ylabel('Luminance');
        title(['Size = ', num2str(size_value), '° × ', num2str(size_value), '°; Luminance = ', num2str(luminance), ' nits']);
        grid on;
        box on;
        axis tight;
    end
end
