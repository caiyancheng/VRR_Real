function plot_pict(x_array, y_array, x_label, y_label, title_str, fig_size, save_flag, save_fig_name)
    if fig_size
        figure('Position', [100, 100, fig_size(1), fig_size(2)]);
    else
        figure;
    end
    plot(x_array, y_array);
    title(title_str);
    xlabel(x_label);
    ylabel(y_label);
    if save_flag
        saveas(gcf, [save_fig_name, '.png']);
        close;
    else
        grid on;
        axis tight;
        drawnow;
    end
end