%%
clear all; close all;

n = 200; 
n_all = n*6; % number of frames in the gif
frames_all = 1:n_all;
frames = 1:n;
frames_beg_idx = 1:n:n_all;
frames_end_idx = n:n:n_all;

% background colors centred around D65 gray
xy_gray = XYZ2Yxy(whitepoint( 'd65' ));
xy_gray = xy_gray(2:3);
xy_r = sin(2*pi*(1/30).*frames).*0.15;
xy_theta = (2*pi/n).*frames;
xy_x = xy_gray(1) + (xy_r .* cos(xy_theta));
xy_y = xy_gray(2) + (xy_r .* sin(xy_theta));
xy_bck_cols(1:n_all,1) = xy_gray(1);
xy_bck_cols(1:n_all,2) = xy_gray(2);
xy_bck_cols(1:n, :) = [xy_x', xy_y'];
% figure, scatter(xy_bck_cols(:,1), xy_bck_cols(:,2))

% Modulation colors
contrast = [40, 3, 1];
LMS_delta(1, :) = [0.7347	0.3163	0.02082].*contrast(1); %ach
LMS_delta(2,:) = [0.762860489	-0.646494145	-0.009444331].*contrast(2); %rg
LMS_delta(3,:) = [0.450449715	0.274890824	0.849429272].*contrast(3); %yv
points = [LMS_delta; LMS_delta(1, :)]; % Fourth point
X = points(:,1);
Y = points(:,2);
Z = points(:,3);
t = 1:4;  % Assuming 4 points
tq = linspace(1, 4, n);  % 200 points between 1 and 4
Xq = spline(t, X, tq);
Yq = spline(t, Y, tq);
Zq = spline(t, Z, tq);
LMS_delta_cols_sub = [Xq; Yq; Zq]';
LMS_delta_cols = zeros(n_all, 3);
LMS_delta_cols(1:n_all, 1) = LMS_delta_cols_sub(1, 1);
LMS_delta_cols(1:n_all, 2) = LMS_delta_cols_sub(1, 2);
LMS_delta_cols(1:n_all, 3) = LMS_delta_cols_sub(1, 3);
LMS_delta_cols(frames_beg_idx(2):frames_end_idx(2), :) = LMS_delta_cols_sub;

% Area
areas_sub = 2.^sin(2*pi*(1/(n)).*frames);
areas = ones(1, n_all);
areas(frames_beg_idx(3):frames_end_idx(3)) = areas_sub;
% figure, plot(frames_all, areas);

% TF 
tf = [0 2 5 10];
gif_fps = 20; %
tf_array = zeros(n_all, 1);
tf_array_diff = (frames_end_idx(4)-frames_beg_idx(4)+1)./length(tf);
tf_array_beg_idx = frames_beg_idx(4):tf_array_diff:frames_end_idx(4);
tf_array_end_idx = (frames_beg_idx(4)+tf_array_diff-1):tf_array_diff:frames_end_idx(4);

tf_array(tf_array_beg_idx(2):tf_array_end_idx(2)) = tf(2);
tf_array(tf_array_beg_idx(3):tf_array_end_idx(3)) = tf(3);
tf_array(tf_array_beg_idx(4):tf_array_end_idx(4)) = tf(4);
% tf_array = repmat(tf, [n/length(tf), 1]);
tf_array = tf_array(:);
f = tf_array./gif_fps;
tf_contrasts = cos(2*pi.*f.*frames_all');
% figure, plot(frames, tf_contrasts(106:140));
% figure, plot(frames_all, tf_contrasts);

% lum
lums_sub = 10.^((sin(2*pi*(1/n).*frames)+1.6990)./2);
lums = lums_sub(1,n).*ones(1, n_all);
lums(frames_beg_idx(5):frames_end_idx(5)) = lums_sub;
% figure, plot(frames_all, lums);

% ecc
ecc_r = zeros(1, n_all);
ecc_r_sub = sin(2*pi*(1/(n*2)).*frames).*5;
ecc_theta = (2*pi/n).*frames;
ecc_x = (ecc_r_sub .* cos(ecc_theta));
ecc_y = (ecc_r_sub .* sin(ecc_theta));
% figure, scatter(ecc_x, ecc_y)
ecc_r(frames_beg_idx(6):frames_end_idx(6)) = ecc_r_sub;


%% Create gabor


addpath(genpath('E:\OneDrive - University of Cambridge\Github_repos\castleCSF'));

csf_model = CSF_castleCSF();

im_size = [96 96];
pix_per_deg = 10;
s_freq = [1];
orientation = 0;
phase = 90;

gabor_sz = 512;

lw = 3;
h = figure;
set(gca, 'Units', 'pixels');
set(gca, 'Position',  [0 0 gabor_sz gabor_sz])
sz = [gabor_sz gabor_sz];

show_plot = true;

cond_idx = 4;
gifname = sprintf('svg_icon_TCSF.gif', cond_idx);

set(gcf, 'Units', 'inches');
set(gcf, 'Position',  [6 0 7.5 4])
% html_change_figure_print_size( gcf, 39, 50 );
set(gcf, 'defaultAxesFontName', 'Arial');
set(gcf, 'defaultTextFontName', 'Arial');
FontSize = 12;
set(gcf, 'defaultTextFontSize', FontSize);
set(gcf, 'DefaultAxesFontSize', FontSize)

gap = [0.05 0.03];
marg_h = [0.15 0.12]; %lower upper
marg_w = [0.01 0.01]; % left right

ff = 0;

for ii = frames_beg_idx(cond_idx):frames_end_idx(cond_idx)
    
%     clf;
    hold on,
    switch cond_idx
        case 1
            cont_factor = 0.15;
        case 2
            cont_factor = 0.2;
        case 3
            cont_factor = 0.15;
        case 5
            cont_factor = 0.012*lums(ii)+0.0411;
        otherwise
            cont_factor = 0.15;
    end

    bck_col = xyz2lms2006( Yxy2XYZ([1, xy_bck_cols(ii, :)]) );
    
    [G_LMS_gabor, ~] = create_gabor( im_size, pix_per_deg, 1, s_freq, 0,...
        orientation, bck_col.*lums(ii), cont_factor*LMS_delta_cols(ii, :).*tf_contrasts(ii),... 
        areas(ii), ecc_r(ii), phase );
    G_RGB_gabor = cm_xyz2rgb( lms2006_2xyz(G_LMS_gabor) );
    I_gabor = (G_RGB_gabor/22).^(1/2.2);
    I_gabor = real(I_gabor);

    if ~show_plot

        clf, 
        imshow(I_gabor);
        [imind,cm] = rgb2ind(I_gabor,256);

    else
%         clf,
%         subplot(1, 2, 1);
        
        clf, 
        ha = tight_subplot( 1, 2, gap, marg_h, marg_w);

        axes(ha(1));
        imshow(I_gabor);

%         subplot(1,2,2);
        axes(ha(2));
%         lms_background = bck_col.*lums(ii);
        lms_background = bck_col.*(10^(0.1861*lums(ii)-0.9415));
        lms_modulation_delta = (0.3*LMS_delta_cols(ii, :).*lums(ii))-lms_background;
        lms_delta_norm = lms_modulation_delta./norm(lms_modulation_delta);
    
        s_frequency = logspace( log10(0.5), log10(64), 30 );    % Spatial frequency in cycles per degree
        csf_pars = struct( 's_frequency', s_frequency(:), 't_frequency', tf_array(ii),... 
            'orientation', orientation, 'area', areas(ii), 'eccentricity', abs(ecc_r(ii)),...
            'lms_bkg', lms_background,...
            'lms_delta', lms_delta_norm);    
     
        S = csf_model.sensitivity( csf_pars );        
        S = reshape( S, size(s_frequency) );
        sel_y_lim = S < 0.05;
        S(sel_y_lim) = NaN;
        
        plot(log10(s_frequency), log10(S),... 
                'Color', 'b', 'LineWidth', lw,... 
                'LineStyle', '-');  
        axis square
        f_lab = [ 0.1000 0.3  1 3 10 30 100 ];
        xticks = log10(f_lab);
        set( gca, 'XTick', xticks );
        set( gca, 'XTickLabel', f_lab );
%     
        yticks = [0.1 0.3 1 3 10 30 100 300 1000];
        set( gca, 'YTick', log10(yticks) );
        set( gca, 'YTickLabel', yticks );
%       
        switch cond_idx
            case 1
                xlim( log10([0.5, 40]));
                ylim( log10([1 200]) );
                gif_time = 0.05;
            case 2
                xlim( log10([0.5, 64]));
                ylim( log10([1 200]) );
                gif_time = 0.05;
            case 3
                xlim( log10([0.5, 50]));
                ylim( log10([1 200]) );
                gif_time = 0.02;
                sgtitle(sprintf('Size: %g^o (\\sigma)', round(areas(ii),1)));
            case 4
                xlim( log10([0.5, 50]));
                ylim( log10([1 200]) );
                gif_time = 0.05;
                sgtitle(sprintf('Temporal frequency: %g Hz', tf_array(ii)));
            case 5
                xlim( log10([0.5, 50]));
                ylim( log10([1 200]) );
                gif_time = 0.05;
                lum = round(10^round((0.1861*lums(ii)-0.9415), 1),2);
                sgtitle(sprintf('Luminance: %3g cd/m^2', lum));
            case 6
                xlim( log10([0.5, 50]));
                ylim( log10([1 200]) );
                gif_time = 0.02;
                sgtitle(sprintf('Eccentricity: %3g^o', ...
                    round(abs(ecc_r(ii)),1)));
            otherwise
                xlim( log10([0.5, 50]));
                ylim( log10([1 200]) );
                gif_time = 0.05;
        end

        grid on
%         set (gca, 'XMinorGrid', 'off');
%         set (gca, 'MinorGridAlpha', 0);
        
        xlabel('Spatial frequency (cpd)');
        ylabel('Contrast Sensitivity');
        
        % Find all text objects in the figure
        textObjects = findall(gcf, 'Type', 'text');
        set(textObjects, 'FontSize', FontSize);
        
        axesObjects = findall(gcf, 'Type', 'axes');
        set(axesObjects, 'FontSize', FontSize);


        drawnow
        im = frame2im(getframe(gcf));   
        [imind,cm] = rgb2ind(im,256);

    end

    ff = ff+1;

    if 1
        if ff == 1
            imwrite(imind,cm,gifname,'gif', 'Loopcount',inf); 
        else
        
            imwrite(imind,cm,gifname,'gif', 'DelayTime',gif_time, 'WriteMode','append'); 
        end
    end

end

rmpath(genpath('../../../Github_repos/castleCSF/'));


